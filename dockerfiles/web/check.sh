#!/bin/bash
# c-drill web: build-time generation + verification (fails the image build on error)
# usage: check.sh <c-drill dir>
set -u
D="$1"; RES="$D/.resources"; T="$(dirname "$0")/tests"; ok=0; ko=0
fail(){ echo "CHECK FAILED: $*"; ko=$((ko+1)); }
gcc -c "$RES/watchdog.c" -o "$RES/watchdog.o" || fail "watchdog.o"
# 1) expected outputs, computed by the reference solutions
for d in "$RES"/exercises/level*/*/; do d="${d%/}"
  g="$(mktemp -d)"; mkdir "$g/code"; cp "$d/solution.c" "$g/code/$(basename "$d").c"
  CDRILL_GEN_EXPECTED=1 bash "$RES/checker.sh" "$d" "$g/code/$(basename "$d").c" exam >/dev/null 2>&1 || true
  [ -s "$d/tests" ] && [ -d "$d/expected" ] || fail "expected $(basename "$d")"
done
# helper: run checker on a file as rendu -> 0 pass / 1 fail
run(){ local exo="$1" src="$2" t; t="$(mktemp -d)"; mkdir "$t/code"; cp "$src" "$t/code/$exo.c"
  local d; d="$(ls -d "$RES"/exercises/level*/"$exo")"
  bash "$RES/checker.sh" "$d" "$t/code/$exo.c" exam > "$t/out" 2>&1; local rc=$?; LAST="$t/out"; return $rc; }
# 2) every reference solution passes
for d in "$RES"/exercises/level*/*/; do d="${d%/}"; e="$(basename "$d")"
  if run "$e" "$d/solution.c"; then ok=$((ok+1)); else fail "solution $e"; tail -5 "$LAST"; fi
done
# 3) classic 'long' versions pass like on a 64-bit exam machine
for e in ft_putnbr ft_itoa ft_atoi ft_range; do
  if run "$e" "$T/$e.c"; then ok=$((ok+1)); else fail "long version $e"; tail -8 "$LAST"; fi
done
# 4) infinite loop -> Timeout, not a frozen VM
if run ulstr "$T/ulstr_loop.c"; then fail "loop accepted"; elif grep -q Timeout "$LAST"; then ok=$((ok+1)); else fail "loop no Timeout"; tail -5 "$LAST"; fi
echo "web check: $ok ok, $ko failed"
[ $ko -eq 0 ]
