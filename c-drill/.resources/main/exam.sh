#!/bin/bash
MAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RES="$(cd "$MAIN/.." && pwd)"; PROJECT="$(cd "$RES/.." && pwd)"
source "$MAIN/colors.sh"; source "$MAIN/functions.sh"
source "$MAIN/lang.sh"; load_language
source "$MAIN/i18n.sh"; source "$MAIN/meta.sh"; source "$MAIN/session_lib.sh"
trap cleanup_rendu EXIT INT TERM HUP

export EXAM_SCORE=0
export EXAM_DEADLINE=$(( $(date +%s) + EXAM_DURATION ))

show_grade(){
  clear; bash "$MAIN/label.sh"
  echo -e "${MAGENTA}${BOLD}$1${RESET}"
  echo "=================================================="
  echo -e "${GREEN}${BOLD}$T_YOUR_GRADE : $EXAM_SCORE / $MAX_SCORE${RESET}"
  echo "=================================================="
  read -rp "$T_PRESS_RETURN" _
}

clear; bash "$MAIN/label.sh"
echo -e "${GREEN}${BOLD}$T_EXAM_WELCOME${RESET}"
echo -e "${WHITE}$T_EXAM_RULES${RESET}"
echo -e "${RED}${BOLD}\xE2\x8F\xB3 $T_TIME_LIMIT : $(fmt_hms $EXAM_DURATION)${RESET}"
echo "=================================================="
read -rp "$T_PRESS_CONTINUE" _

mkdir -p "$PROJECT/rendu"
for level in $META_LEVELS; do
  exo="$(rand_pick "$(meta_level_subjects "$level")")"
  while true; do
    run_exercise "$exo" "$level" "exam" 1; rc=$?
    case $rc in
      0)
        EXAM_SCORE=$(( EXAM_SCORE + $(meta_level_points "$level") )); export EXAM_SCORE
        clear; bash "$MAIN/label.sh"
        echo -e "${GREEN}${BOLD}$T_LEVEL_VALIDATED  ($T_LEVEL $level, +$(meta_level_points "$level"))${RESET}"
        echo -e "${CYAN}$T_CURRENT_SCORE : $EXAM_SCORE / $MAX_SCORE${RESET}"
        sleep 2; break ;;
      200) show_grade "$T_TIME_UP"; exit 0 ;;
      255) show_grade "$T_EXAM_DONE"; exit 0 ;;
    esac
  done
done
show_grade "$T_ALL_DONE"
exit 0
