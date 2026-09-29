#!/bin/bash
# Shared session logic. Expects: MAIN, RES, PROJECT, APP_LANG set by caller.
source "$MAIN/colors.sh"
source "$MAIN/i18n.sh"

shuffle_list(){ local arr=($1) i j t; for((i=${#arr[@]}-1;i>0;i--)); do j=$((RANDOM%(i+1))); t=${arr[i]}; arr[i]=${arr[j]}; arr[j]=$t; done; echo "${arr[@]}"; }
rand_pick(){ local arr=($1); echo "${arr[$((RANDOM%${#arr[@]}))]}"; }
fmt_hms(){ local s=$1; [ "$s" -lt 0 ] && s=0; printf "%02d:%02d:%02d" $((s/3600)) $(((s%3600)/60)) $((s%60)); }

cleanup_rendu(){
  if [ -d "$PROJECT/rendu" ]; then
    mkdir -p "$PROJECT/trace"
    cp -r "$PROJECT/rendu" "$PROJECT/trace/rendu_backup_$(date +%s)" 2>/dev/null
    rm -rf "$PROJECT/rendu"
  fi
}

# run_exercise <exo> <level> <checker_mode> <is_exam>
#   checker_mode = exam | guided
#   is_exam = 1 -> countdown via $EXAM_DEADLINE, no skip
# Returns: 0 passed, 10 next, 255 exit, 200 time-up
run_exercise(){
  local exo="$1" level="$2" cmode="$3" is_exam="$4"
  local ex_dir="$RES/exercises/level$level/$exo"
  local rdir="$PROJECT/rendu/$exo"
  local cfile="$rdir/code/$exo.c"
  local subj input rc now remaining
  mkdir -p "$rdir/code" "$rdir/subject"
  # empty .c to fill (exam-like); never overwrite existing student work
  [ -f "$cfile" ] || : > "$cfile"
  subj="$ex_dir/subject.$APP_LANG.txt"; [ -f "$subj" ] || subj="$ex_dir/subject.en.txt"
  # copy of the subject next to the code (handy for copy-pasting write strings)
  cp "$subj" "$rdir/subject/$exo.txt" 2>/dev/null

  while true; do
    clear; bash "$MAIN/label.sh"
    if [ "$is_exam" = "1" ] && [ -n "${EXAM_DEADLINE:-}" ]; then
      now=$(date +%s); remaining=$((EXAM_DEADLINE-now))
      [ $remaining -le 0 ] && return 200
      printf "${RED}${BOLD}\xE2\x8F\xB3 %s : %s${RESET}   ${CYAN}%s : %s/%s${RESET}\n" "$T_TIME_LEFT" "$(fmt_hms $remaining)" "$T_CURRENT_SCORE" "${EXAM_SCORE:-0}" "$MAX_SCORE"
    fi
    echo -e "${CYAN}${BOLD}$T_EDIT_IN${RESET} rendu/$exo/code/$exo.c"
    echo -e "${BLUE}==================================================${RESET}"
    cat "$subj"
    echo -e "${BLUE}==================================================${RESET}"
    if [ "$is_exam" = "1" ]; then echo -e "${YELLOW}$T_TYPE_CMDS_EXAM${RESET}"
    else echo -e "${YELLOW}$T_TYPE_CMDS${RESET}"; fi

    if [ "$is_exam" = "1" ] && [ -n "${EXAM_DEADLINE:-}" ]; then
      now=$(date +%s); remaining=$((EXAM_DEADLINE-now)); [ $remaining -le 0 ] && return 200
      if ! read -t $remaining -rp "/> " input; then now=$(date +%s); [ $now -ge $EXAM_DEADLINE ] && return 200 || return 255; fi
    else
      read -rp "/> " input || return 255
    fi

    case "$input" in
      grademe|test)
        clear
        echo -e "${GREEN}$T_RUNNING${RESET}"
        echo "--------------------------------------------------"
        bash "$RES/checker.sh" "$ex_dir" "$cfile" "$cmode"
        rc=$?
        echo "--------------------------------------------------"
        if [ $rc -eq 0 ] && [ "$is_exam" = "1" ]; then sleep 1; return 0; fi
        read -rp "$T_PRESS_CONTINUE" _
        ;;
      exit) return 255 ;;
      "" ) : ;;
      *) echo -e "${RED}$T_UNKNOWN_CMD${RESET}"; sleep 1 ;;
    esac
  done
}
