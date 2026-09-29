#!/bin/bash
MAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RES="$(cd "$MAIN/.." && pwd)"; PROJECT="$(cd "$RES/.." && pwd)"
source "$MAIN/colors.sh"; source "$MAIN/functions.sh"
source "$MAIN/lang.sh"; load_language
source "$MAIN/i18n.sh"; source "$MAIN/meta.sh"; source "$MAIN/session_lib.sh"
trap cleanup_rendu EXIT INT TERM HUP

choose_mode(){          # sets global CMODE (exam|guided) or empty
  CMODE=""
  clear; bash "$MAIN/label.sh"
  printf "${BLUE}%s${RESET}\n\n" "$T_CHOOSE_MODE"
  printf "${YELLOW}${BOLD}1.${RESET} %s\n" "$T_MODE_EXAMLIKE"
  printf "${YELLOW}${BOLD}2.${RESET} %s\n" "$T_MODE_GUIDED"
  printf "${YELLOW}${BOLD}b.${RESET} %s\n" "$T_BACK"
  printf "${GREEN}${BOLD}%s${RESET}" "$T_CHOICE"
  local c; read c || return
  case "$c" in 1) CMODE=exam ;; 2) CMODE=guided ;; *) CMODE="" ;; esac
}

pick_exercise(){   # $1=level $2=cmode ; numbered exercise menu
  local level="$1" cmode="$2"; local exos=($(meta_level_subjects "$level")); local i c
  while true; do
    clear; bash "$MAIN/label.sh"
    printf "${BLUE}%s %s${RESET}\n\n" "$T_LEVEL" "$level"
    for i in "${!exos[@]}"; do printf "${YELLOW}${BOLD}%d.${RESET} %s\n" $((i+1)) "${exos[$i]}"; done
    printf "${YELLOW}${BOLD}b.${RESET} %s\n" "$T_BACK"
    printf "${GREEN}${BOLD}%s${RESET}" "$T_CHOICE"
    read c || return
    case "$c" in
      b|B) return ;;
      ''|*[!0-9]*) echo -e "${RED}$T_INVALID${RESET}"; sleep 1 ;;
      *)
        if [ "$c" -ge 1 ] && [ "$c" -le "${#exos[@]}" ]; then
          mkdir -p "$PROJECT/rendu"
          run_exercise "${exos[$((c-1))]}" "$level" "$cmode" 0
        else echo -e "${RED}$T_INVALID${RESET}"; sleep 1; fi ;;
    esac
  done
}

while true; do
  clear; bash "$MAIN/label.sh"
  printf "${BLUE}%s${RESET}\n\n" "$T_CHOOSE_LEVEL"
  for lvl in $META_LEVELS; do
    printf "${YELLOW}${BOLD}%s.${RESET} %s\n" "$lvl" "$(meta_level_name "$lvl")"
  done
  printf "${YELLOW}${BOLD}b.${RESET} %s\n" "$T_BACK"
  printf "${GREEN}${BOLD}%s${RESET}" "$T_CHOICE"
  read lvl || exit 0
  case "$lvl" in
    b|B) exit 0 ;;
    *)
      if echo " $META_LEVELS " | grep -q " $lvl "; then
        choose_mode; mode="$CMODE"; [ -z "$mode" ] && continue
        pick_exercise "$lvl" "$mode"
      else echo -e "${RED}$T_INVALID${RESET}"; sleep 1; fi ;;
  esac
done
