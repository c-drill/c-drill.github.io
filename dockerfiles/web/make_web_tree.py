#!/usr/bin/env python3
"""Build the WEB variant of the examshell from an untouched copy of the local one.

usage: make_web_tree.py <dir containing .resources>   (modified in place)

Web-only changes (the local program is never modified):
  * checker: watchdog build for infinite loops, long -> long long (32-bit VM),
    precomputed expected outputs, far fewer processes per test (speed),
    generation mode (CDRILL_GEN_EXPECTED=1) used at image build time;
  * menus: no `clear` / `bash label.sh` per screen (cached header);
  * 'vim' command inside an exercise (one terminal only in the page);
  * builtin clock instead of `date +%s`.
Every replacement is asserted: if the local program changed, this fails loudly.
"""
import sys, os, shutil

root = os.path.join(sys.argv[1], '.resources')
here = os.path.dirname(os.path.abspath(__file__))

def edit(rel, pairs):
    p = os.path.join(root, rel)
    s = open(p).read()
    for a, b, n in pairs:
        c = s.count(a)
        assert c == n, f'{rel}: expected {n} x {a!r}, found {c}'
        s = s.replace(a, b)
    open(p, 'w').write(s)

shutil.copy(os.path.join(here, 'watchdog.c'), os.path.join(root, 'watchdog.c'))
shutil.copy(os.path.join(here, 'long64.pl'), os.path.join(root, 'long64.pl'))

# ---------------------------------------------------------------- checker ---
edit('checker.sh', [
('set -u\n',
 'set -u\n'
 '# WEB VERSION (c-drill): see dockerfiles/web/make_web_tree.py\n'
 'WD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\n'
 'ulimit -f 40000 2>/dev/null        # runaway output guard, once for the whole run\n', 1),
# long is 4 bytes in the 32-bit VM, 8 at the exam: compile a rewritten copy
# i386: 64-bit arithmetic (long long) is done by libgcc helpers, not user calls
('    INTERNAL="$INTERNAL __error __chkstk_darwin __bzero dyld_stub_binder "\n',
 '    INTERNAL="$INTERNAL __error __chkstk_darwin __bzero dyld_stub_binder "\n'
 '    INTERNAL="$INTERNAL __divdi3 __moddi3 __udivdi3 __umoddi3 __divmoddi4 __udivmoddi4 __muldi3 __ashldi3 __ashrdi3 __lshrdi3 __negdi2 __cmpdi2 __ucmpdi2 "   # web: i386 libgcc\n', 1),
('cp "$RENDU" "$WORK/$EXO.c"\n',
 'cp "$RENDU" "$WORK/$EXO.c"\n'
 'perl "$WD_DIR/long64.pl" "$WORK/$EXO.c" 2>/dev/null   # web: long -> long long (32-bit VM)\n', 1),
# the reference solutions also assume a 64-bit long (e.g. ft_itoa with INT_MIN)
('cp "$EX_DIR/solution.c" "$WORK/solution.c"\n',
 'cp "$EX_DIR/solution.c" "$WORK/solution.c"\n'
 'perl "$WD_DIR/long64.pl" "$WORK/solution.c" 2>/dev/null   # web: 64-bit long semantics\n', 1),
('"$CC" $FLAGS "$EXO.c" $EXTRA -o stu 2> cc_err; build_ok=$?',
 '# web: WebVM cannot kill a busy loop -> self-stopping build (watchdog.c, 5 s)\n'
 'WD_O="$WD_DIR/watchdog.o"\n'
 '[ -f "$WD_O" ] || { "$CC" -c "$WD_DIR/watchdog.c" -o wd.o 2>/dev/null; WD_O=wd.o; }\n'
 '"$CC" $FLAGS -fsanitize-coverage=trace-pc "$EXO.c" $EXTRA "$WD_O" -o stu 2> cc_err; build_ok=$?', 1),
# reference: precomputed outputs when present (no compile, no run)
('if ! "$CC" "solution.c" $EXTRA -o ref 2> ref_err; then',
 'EXPECTED="$EX_DIR/expected"\n'
 'if [ -d "$EXPECTED" ] && [ -z "${CDRILL_GEN_EXPECTED:-}" ]; then :\n'
 'elif ! "$CC" "solution.c" $EXTRA -o ref 2> ref_err; then', 1),
('''run_one(){
    local args="$1" stdin="$2" arr
    eval "arr=($args)"''',
 '''run_one(){
    local args="$1" stdin="$2" arr
    eval "arr=($args)"
    # web: one process per test (watchdog replaces timeout, ulimit set once)
    if [ -n "$stdin" ]; then printf '%s' "$stdin" > stdin_in; else : > stdin_in; fi
    if [ -n "${CDRILL_GEN_EXPECTED:-}" ]; then
        { timeout 5 ./ref ${arr[@]+"${arr[@]}"} < stdin_in > "$EXPECTED/$idx" 2>/dev/null; } 2>/dev/null
        return
    fi
    { ./stu ${arr[@]+"${arr[@]}"} < stdin_in > stu_out 2>/dev/null; } 2>/dev/null; rc_stu=$?
    REF_OUT="$EXPECTED/$idx"
    [ -f "$REF_OUT" ] && return
    REF_OUT=ref_out''', 1),
('total=0; passed=0; failed=0; idx=0\n',
 'total=0; passed=0; failed=0; idx=0\n'
 'if [ -n "${CDRILL_GEN_EXPECTED:-}" ]; then rm -rf "$EXPECTED"; mkdir -p "$EXPECTED"; fi\n', 1),
('''    run_one "$args" "$stdin"
    tcrash="$(crash_desc "$rc_stu")"
    if diff -q stu_out ref_out >/dev/null 2>&1; then ok=1; else ok=0; fi''',
 '''    run_one "$args" "$stdin"
    [ -n "${CDRILL_GEN_EXPECTED:-}" ] && continue
    if cmp -s stu_out "$REF_OUT"; then ok=1; tcrash=""; else ok=0; tcrash="$(crash_desc "$rc_stu")"; fi''', 1),
('render_out ref_out', 'render_out "$REF_OUT"', 2),
('diff_hint ref_out stu_out', 'diff_hint "$REF_OUT" stu_out', 2),
('echo\necho -e "${YELLOW}Valid tests: $passed${RESET}"',
 '[ -n "${CDRILL_GEN_EXPECTED:-}" ] && { echo "generated $idx expected outputs"; exit 0; }\n'
 'echo\necho -e "${YELLOW}Valid tests: $passed${RESET}"', 1),
])

# ------------------------------------------------------------------ menus ---
HEADER = ('\n# web: cached header instead of `clear; bash label.sh` on every screen\n'
          'cdrill_header(){\n'
          '  if [ -z "${CDRILL_LABEL:-}" ]; then\n'
          '    CDRILL_LABEL="$(bash "$(dirname "${BASH_SOURCE[0]}")/label.sh")"; export CDRILL_LABEL\n'
          '  fi\n'
          "  printf '\\033[H\\033[2J\\033[3J%s\\n' \"$CDRILL_LABEL\"\n"
          '}\n')
p = os.path.join(root, 'main/colors.sh'); open(p, 'a').write(HEADER)

edit('main/exam.sh', [
 ('clear; bash "$MAIN/label.sh"', 'cdrill_header', 3),
 ('export EXAM_DEADLINE=$(( $(date +%s) + EXAM_DURATION ))',
  "printf -v _now '%(%s)T' -1; export EXAM_DEADLINE=$(( _now + EXAM_DURATION ))", 1)])
edit('main/intro.sh', [
 ('clear; bash "$MAIN/label.sh"', 'cdrill_header', 2),
 ('"$(meta_level_name "$lvl")"', '"$T_LEVEL $lvl"', 1),
 ("q|Q|exit) clear;", "q|Q|exit) printf '\\033[H\\033[2J\\033[3J';", 1)])
edit('main/training.sh', [
 ('clear; bash "$MAIN/label.sh"', 'cdrill_header', 3),
 ('"$(meta_level_name "$lvl")"', '"$T_LEVEL $lvl"', 1)])
edit('main/lang.sh', [
 ('    clear\n    bash "$main_dir/label.sh"\n', '    cdrill_header\n', 1)])
edit('main/session_lib.sh', [
 ('    clear; bash "$MAIN/label.sh"', '    cdrill_header', 1),
 ('        clear\n', "        printf '\\033[H\\033[2J\\033[3J'\n", 1),
 ('now=$(date +%s)', "printf -v now '%(%s)T' -1", 3),
 ('      exit) return 255 ;;',
  '      vim|vi|edit) "${EDITOR:-vim}" "$cfile" ;;   # web: only one terminal\n'
  '      exit) return 255 ;;', 1)])
edit('main/i18n.sh', [
 ("pour tester, 'exit'", "pour tester, 'vim' pour éditer ton code, 'exit'", 2),
 ("to test, 'exit'", "to test, 'vim' to edit your code, 'exit'", 2)])
print('web tree ready')
