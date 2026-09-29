# 42 Piscine C — Final Exam Simulator (examshell)

Training + exam simulator for the 42 **Piscine** final exam (C, compiled with
`-Wall -Wextra -Werror`), with super-reliable testers so that **what passes here
passes on grademe**.

## Launch

```bash
bash examshell       # or:  make
```

To type just `examshell` (like in the real exam), run once:

```bash
bash install.sh
```
then open a new terminal and type:  `examshell`

## Compatibility

Linux (any distro, 42 clusters included), **macOS** (default bash 3.2, BSD tools,
`gcc` = clang from the Xcode Command Line Tools: `xcode-select --install`) and
Windows through **WSL**. Needs only `bash`, `gcc`/`cc` and `nm`; the 5 s time
limit uses `timeout`, or `gtimeout`/`perl` when it is missing (macOS).

## Menu

- **Training Mode** — pick a level (0–10), then a sub-mode, then **choose the exercise
  by number**:
  - *Exam mode* — strict like grademe: passed tests shown as a ticked list, it
    **stops at the first failing test** and shows only Input / Your output /
    Expected output.
  - *Guided mode* — shows every test in detail, to help you perfect an exercise.
  In an exercise, type **`grademe`** to test, `exit` to leave.
- **Exam Mode** — the real thing: an **8-hour** countdown, one random exercise per
  level (0 → 10), you must pass it to move up, and your **cumulative score** grows
  (final total for the current set = 68/100). Type `grademe` to test, and `exit`
  anytime to quit and see your **final grade** (like leaving the real 8h exam).

## Testers (fidelity)

- Compile with `-Wall -Wextra -Werror` (a warning = fail, like the exam).
- **Allowed functions are checked** (via `nm`): using a forbidden function (e.g.
  `printf` when only `write` is allowed) fails the exercise, as on grademe.
- Output is compared **byte-for-byte** on stdout only (exit code ignored), matching
  grademe for these exercises.
- No norminette, leaks are **not** checked (matches the exam).
- 20+ tests on parameterised exercises; fixed-output programs have the exact test.
- Function exercises are compiled with a hidden `main` (like grademe): an empty /
  non-compiling file shows the compiler/link error; a wrong body shows your
  (possibly garbage) output vs the expected one.

## Levels (0 → 10, 37 exercises)

- 0: hello, ft_countdown, maff_alpha, ft_stars, ft_print_numbers
- 1: fizzbuzz, buzzfizz, ft_putnbr
- 2: ft_add, ft_sub, ft_mul, ft_add_n, ft_swap
- 3: ft_strlen, ft_putstr, occ_z, occ_a
- 4: aff_first_param, aff_last_param
- 5: ft_atoi, ft_itoa
- 6: ft_split
- 7: print_odd, replace_3_5, rot_13, rotone, search_and_replace, ulstr, first_word,
  last_word, alpha_mirror
- 8: inter, union, wdmatch
- 9: ft_range, ft_rrange
- 10: count_alpha

## Note on reconstructed subjects

`ft_stars, buzzfizz, print_odd, occ_z, occ_a` and `replace_3_5` were reconstructed
from descriptions and student feedback. `replace_3_5` (formerly named "three_five")
was corrected against a confirmed reference and real examples — the rule is
position-based: a position multiple of 3 -> '5', else multiple of 5 -> '3', else the
character unchanged (`"abcdef"` -> `ab5d35`, `"HelloWorld!"` -> `He5l35or53!`).

*Unofficial student tool for 42 piscine practice.*
