#!/bin/bash
# C exercise checker for the Piscine examshell (moulinette-style report).
# Usage: checker.sh <exercise_dir> <rendu_file> <mode>   (mode = exam | guided)
# Portable: bash 3.2 (macOS default) -> bash 5, GNU (Linux) and BSD (macOS) tools.
#   -> no mapfile / assoc arrays, no "${empty[@]}" under set -u, no GNU-only flags.
set -u
GREEN="\033[0;32m"; RED="\033[0;31m"; YELLOW="\033[0;33m"; CYAN="\033[0;36m"
BLUE="\033[0;34m"; BOLD="\033[1m"; DIM="\033[2m"; RESET="\033[0m"

EX_DIR="$(cd "$1" && pwd)"; RENDU="$2"; MODE="${3:-exam}"   # absolute: we cd later
EXO="$(basename "$EX_DIR")"
FLAGS="-Wall -Wextra -Werror"
CC="gcc"; command -v gcc >/dev/null 2>&1 || CC="cc"   # macOS: gcc = clang (Xcode CLT)
CAT="${EXO#ft_}"                     # generic test-category label (never leaks inputs)

TYPE="program"; ALLOWED=""
[ -f "$EX_DIR/meta" ] && {
    TYPE="$(sed -n 's/^type=//p' "$EX_DIR/meta")"
    ALLOWED="$(sed -n 's/^allowed=//p' "$EX_DIR/meta")"
}
[ "$ALLOWED" = "None" ] && ALLOWED=""
ALLOWED="${ALLOWED//,/ }"

OK="${GREEN}OK${RESET}"; KO="${RED}${BOLD}KO${RESET}"
prereq(){ printf "${BOLD}%-22s${RESET}: %b\n" "$1" "$2"; }
assignment_pass(){ echo; echo -e "${GREEN}${BOLD}\xE2\x9C\x85 Assignment: $EXO${RESET}"; }
assignment_fail(){ echo; echo -e "${RED}${BOLD}\xE2\x9D\x8C Assignment: $EXO${RESET}"; }

# print a captured output verbatim (indented); empty shows nothing but a marker
# (read loop instead of sed: BSD sed adds a final newline, GNU sed does not)
RENDER_MAX=4096                      # bytes shown at most (runaway output guard)
render_out(){
    local l size
    if [ ! -s "$1" ]; then echo -e "        ${DIM}(no output)${RESET}"; return; fi
    head -c "$RENDER_MAX" "$1" | while IFS= read -r l || [ -n "$l" ]; do
        printf '        %s\n' "$l"
    done
    size=$(wc -c < "$1" | tr -d ' ')
    [ "$size" -gt "$RENDER_MAX" ] && echo -e "        ${DIM}... (output truncated: $size bytes)${RESET}"
    return 0
}
# subtle hint only for the sneaky cases (empty / trailing-newline-only difference)
diff_hint(){
    if [ ! -s "$2" ]; then :
    elif [ "$(cat "$1")" = "$(cat "$2")" ]; then
        echo -e "        ${YELLOW}Note: only a trailing newline differs.${RESET}"
    fi
}

echo -e "${BOLD}${CYAN}=== Prerequisites ===${RESET}"

# --- Expected files: the rendu .c must exist, and no garbage next to it -------
if [ ! -f "$RENDU" ]; then
    prereq "Expected files" "$KO ${RED}($EXO.c is missing)${RESET}"
    assignment_fail; exit 1
fi
code_dir="$(cd "$(dirname "$RENDU")" && pwd)"
garbage=""
shopt -s dotglob nullglob          # include hidden files (.swp, etc.) in the check
for f in "$code_dir"/*; do
    b="$(basename "$f")"
    [ "$b" = "." ] || [ "$b" = ".." ] && continue
    [ "$b" = "$EXO.c" ] && continue
    garbage="$b"; break
done
shopt -u dotglob nullglob
if [ -n "$garbage" ]; then
    prereq "Expected files" "$KO ${RED}(garbage file: $garbage)${RESET}"
    assignment_fail; exit 1
fi
prereq "Expected files" "$OK"

# --- build (needed for allowed-functions + prototype + tests) -----------------
WORK="$(mktemp -d "${TMPDIR:-/tmp}/examshell.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
cp "$RENDU" "$WORK/$EXO.c"
cp "$EX_DIR/solution.c" "$WORK/solution.c"
EXTRA=""
[ "$TYPE" = "function" ] && { cp "$EX_DIR/main.c" "$WORK/main.c"; EXTRA="main.c"; }
cd "$WORK" || { assignment_fail; exit 1; }

"$CC" -fno-builtin -c "$EXO.c" -o rendu.o 2>/dev/null; obj_ok=$?
"$CC" $FLAGS "$EXO.c" $EXTRA -o stu 2> cc_err; build_ok=$?

# --- Allowed functions --------------------------------------------------------
if [ $obj_ok -eq 0 ]; then
    # compiler/libc internals (Linux + macOS: nm prefixes C symbols with "_" there)
    INTERNAL=" __stack_chk_fail __stack_chk_guard _GLOBAL_OFFSET_TABLE_ __errno_location __assert_fail"
    INTERNAL="$INTERNAL __error __chkstk_darwin __bzero dyld_stub_binder "
    undef="$(nm rendu.o 2>/dev/null | awk '$1=="U"{print $2} $2=="U"{print $3}' | sort -u)"
    forbidden=""
    for sym in $undef; do
        s="${sym#_}"
        case " $ALLOWED $INTERNAL " in
            *" $sym "*|*" $s "*) continue ;;
        esac
        # clang (= gcc on macOS) turns `int tab[256] = {0};` or a struct copy
        # into a hidden memset/memcpy call: only a KO if the student wrote it
        case "$s" in
            memset|memcpy|memmove|bzero)
                grep -Eq "(^|[^A-Za-z0-9_])$s([^A-Za-z0-9_]|\$)" "$EXO.c" || continue ;;
        esac
        forbidden="$sym"; [ "$(uname -s)" = "Darwin" ] && forbidden="$s"   # _printf -> printf
        break
    done
    if [ -n "$forbidden" ]; then
        prereq "Allowed functions" "$KO ${RED}(forbidden: $forbidden)${RESET}"
        echo -e "    ${DIM}Allowed for this exercise: ${ALLOWED:-none}${RESET}"
        assignment_fail; exit 1
    fi
    prereq "Allowed functions" "$OK"
else
    prereq "Allowed functions" "$OK"
fi

# --- Prototype (function exercises only) --------------------------------------
if [ "$TYPE" = "function" ] && [ $build_ok -eq 0 ]; then
    prereq "Prototype" "$OK"
fi

echo
echo -e "${BOLD}${CYAN}=== Test results ===${RESET}"
echo -e "${BOLD}${BLUE}[standard]${RESET}"

# --- Compilation --------------------------------------------------------------
if [ $build_ok -ne 0 ]; then
    prereq "Compilation" "$KO"
    echo -e "    ${RED}$CC $FLAGS reported:${RESET}"
    sed 's/^/    /' cc_err | head -25
    assignment_fail; exit 1
fi
prereq "Compilation" "$OK"
if ! "$CC" "solution.c" $EXTRA -o ref 2> ref_err; then
    echo -e "${RED}internal error: reference does not compile${RESET}"; assignment_fail; exit 1
fi
echo

# describe a crash from an exit code (signal numbers differ between Linux and
# macOS, e.g. SIGBUS = 7 vs 10, so resolve the NAME with the local `kill -l`)
crash_desc(){
    local rc="$1" name
    [ "$rc" = "124" ] && { echo "Timeout (possible infinite loop)"; return; }
    [ "$rc" -gt 128 ] 2>/dev/null || { echo ""; return; }
    name="$(kill -l $((rc - 128)) 2>/dev/null)"; name="${name#SIG}"
    case "$name" in
        SEGV) echo "Segmentation fault (core dumped)" ;;
        BUS)  echo "Bus error (core dumped)" ;;
        ABRT) echo "Aborted (core dumped)" ;;
        FPE)  echo "Floating point exception (core dumped)" ;;
        ILL)  echo "Illegal instruction (core dumped)" ;;
        ALRM|KILL|XCPU) echo "Timeout (possible infinite loop)" ;;
        XFSZ) echo "Output too large (possible infinite loop)" ;;
        *)    echo "" ;;
    esac
}

# 5 s time limit. GNU `timeout` is missing on macOS: use gtimeout (brew
# coreutils) or perl (always shipped with macOS) -> SIGALRM (rc 142 = Timeout).
TLIMIT=5
if command -v timeout >/dev/null 2>&1; then
    limited(){ timeout "$TLIMIT" "$@"; }
elif command -v gtimeout >/dev/null 2>&1; then
    limited(){ gtimeout "$TLIMIT" "$@"; }
elif command -v perl >/dev/null 2>&1; then
    limited(){ perl -e 'alarm shift @ARGV; exec { $ARGV[0] } @ARGV or exit 127' "$TLIMIT" "$@"; }
else
    limited(){ "$@"; }               # no way to limit time: run as is
fi

run_one(){
    local args="$1" stdin="$2" arr
    eval "arr=($args)"
    # ${arr[@]+"${arr[@]}"}: an empty array is "unbound" under set -u in bash < 4.4
    # ulimit -f: a runaway printf loop cannot fill the disk (~20 MB max)
    { printf '%s' "$stdin" | ( ulimit -f 40000 2>/dev/null; limited ./stu ${arr[@]+"${arr[@]}"} ) > stu_out 2>/dev/null; } 2>/dev/null; rc_stu=$?
    { printf '%s' "$stdin" | ( ulimit -f 40000 2>/dev/null; limited ./ref ${arr[@]+"${arr[@]}"} ) > ref_out 2>/dev/null; } 2>/dev/null
}

# read the tests (no mapfile: absent from bash 3.2, the macOS default)
if [ ! -s "$EX_DIR/tests" ]; then
    echo -e "${RED}internal error: no tests for $EXO${RESET}"; assignment_fail; exit 1
fi
TESTS=()
while IFS= read -r line || [ -n "$line" ]; do
    TESTS[${#TESTS[@]}]="$line"
done < "$EX_DIR/tests"
total=0; passed=0; failed=0; idx=0

for line in ${TESTS[@]+"${TESTS[@]}"}; do
    [ -z "$line" ] && continue
    total=$((total+1)); idx=$((idx+1))
    name="${line%%|*}"; rest="${line#*|}"; args="${rest%%|*}"; stdin="${rest#*|}"
    [ "$stdin" = "$rest" ] && stdin=""
    tname="${CAT}__#${idx}"
    run_one "$args" "$stdin"
    tcrash="$(crash_desc "$rc_stu")"
    if diff -q stu_out ref_out >/dev/null 2>&1; then ok=1; else ok=0; fi

    if [ "$MODE" = "guided" ]; then
        # guided: show the outcome AND the output of EVERY test (pass or fail)
        if [ $ok -eq 1 ]; then
            echo -e "${BOLD}$tname${RESET}: $OK"
            passed=$((passed+1))
        else
            echo -e "${BOLD}$tname${RESET}: $KO"
            failed=$((failed+1))
        fi
        [ -n "$args" ] && printf "    ${CYAN}Input:${RESET} %s\n" "$args"
        if [ $ok -eq 1 ]; then
            echo -e "    ${GREEN}Output:${RESET}"; render_out stu_out
        else
            echo -e "    ${RED}Your stdout:${RESET}"; render_out stu_out
            echo -e "    ${GREEN}Expected stdout:${RESET}"; render_out ref_out
            [ -n "$tcrash" ] && echo -e "    ${RED}${BOLD}$tcrash${RESET}"
            diff_hint ref_out stu_out
        fi
        echo
    else
        # exam: list OK tests by name only; on the FIRST fail, show details and stop
        if [ $ok -eq 1 ]; then
            echo -e "${BOLD}$tname${RESET}: $OK"
            passed=$((passed+1))
        else
            echo -e "${BOLD}$tname${RESET}: $KO"
            echo
            [ -n "$args" ] && printf "    ${CYAN}Input:${RESET} %s\n" "$args"
            echo -e "    ${RED}Your stdout:${RESET}"; render_out stu_out
            echo -e "    ${GREEN}Expected stdout:${RESET}"; render_out ref_out
            [ -n "$tcrash" ] && echo -e "    ${RED}${BOLD}$tcrash${RESET}"
            diff_hint ref_out stu_out
            failed=1; break
        fi
    fi
done

echo
echo -e "${YELLOW}Valid tests: $passed${RESET}"
if [ "${failed:-0}" != "0" ]; then assignment_fail; exit 1; fi
assignment_pass; exit 0
