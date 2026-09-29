#!/bin/bash
MAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RES="$(cd "$MAIN/.." && pwd)"; PROJECT="$(cd "$RES/.." && pwd)"
source "$MAIN/colors.sh"; source "$MAIN/lang.sh"; load_language
source "$MAIN/i18n.sh"; source "$MAIN/meta.sh"

show_index(){
  clear; bash "$MAIN/label.sh"
  printf "${CYAN}${BOLD}%s${RESET}\n\n" "$T_INDEX"
  for lvl in $META_LEVELS; do
    printf "${YELLOW}${BOLD}%s${RESET}\n" "$(meta_level_name "$lvl")"
    for exo in $(meta_level_subjects "$lvl"); do printf "   ${GREEN}\xE2\x80\xA2${RESET} %s\n" "$exo"; done
    echo
  done
  read -rp "$T_PRESS_RETURN" _
}

while true; do
  source "$MAIN/i18n.sh"
  clear; bash "$MAIN/label.sh"
  printf "${CYAN}╔═══════════════════════════════════════════════════════════╗${RESET}\n"
  printf "${CYAN}║   ${GREEN}%-56s${CYAN}║${RESET}\n" "$T_MAIN_MENU"
  printf "${CYAN}╚═══════════════════════════════════════════════════════════╝${RESET}\n"
  printf "${YELLOW}${BOLD}1.${RESET} %s ${WHITE}%s${RESET}\n" "$T_TRAINING" "$T_TRAINING_SUB"
  printf "${YELLOW}${BOLD}2.${RESET} %s ${WHITE}%s${RESET}\n" "$T_EXAM" "$T_EXAM_SUB"
  printf "${YELLOW}${BOLD}i.${RESET} %s\n" "$T_INDEX"
  printf "${YELLOW}${BOLD}o.${RESET} %s\n" "$T_OPEN_RENDU"
  printf "${YELLOW}${BOLD}l.${RESET} %s\n" "$T_LANGUAGE"
  printf "${YELLOW}${BOLD}q.${RESET} %s\n" "$T_QUIT"
  printf "${GREEN}${BOLD}%s${RESET}" "$T_CHOICE"
  read choice || exit 0
  case "$choice" in
    1) bash "$MAIN/training.sh" ;;
    2) bash "$MAIN/exam.sh" ;;
    i|I) show_index ;;
    o|O) mkdir -p "$PROJECT/rendu"; echo -e "${CYAN}$PROJECT/rendu${RESET}"
         if [ "$(uname -s)" = "Darwin" ]; then open "$PROJECT/rendu" 2>/dev/null
         elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$PROJECT/rendu" >/dev/null 2>&1 &
         fi
         read -rp "$T_PRESS_CONTINUE" _ ;;
    l|L) choose_language; load_language ;;
    q|Q|exit) clear; echo -e "${MAGENTA}$T_GOODBYE${RESET}"; exit 0 ;;
    *) echo -e "${RED}$T_INVALID${RESET}"; sleep 1 ;;
  esac
done
