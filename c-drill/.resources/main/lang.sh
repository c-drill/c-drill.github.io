#!/bin/bash
# Language handling: choose / load / persist the UI + subject language.
# Exposes $APP_LANG (en|fr) and the i18n strings via i18n.sh.

LANG_FILE="$(dirname "${BASH_SOURCE[0]}")/.applang"

load_language() {
    if [ -f "$LANG_FILE" ]; then
        APP_LANG="$(cat "$LANG_FILE" 2>/dev/null)"
    fi
    case "$APP_LANG" in en|fr) ;; *) APP_LANG="en" ;; esac
    export APP_LANG
}

save_language() {
    echo "$APP_LANG" > "$LANG_FILE" 2>/dev/null
}

choose_language() {
    local main_dir; main_dir="$(dirname "${BASH_SOURCE[0]}")"
    source "$main_dir/colors.sh"
    clear
    bash "$main_dir/label.sh"
    printf "${CYAN}╔═══════════════════════════════════════════════════════════╗${RESET}\n"
    printf "${CYAN}║${GREEN}            Choose language  /  Choisis la langue          ${CYAN}║${RESET}\n"
    printf "${CYAN}╚═══════════════════════════════════════════════════════════╝${RESET}\n"
    printf "${YELLOW}${BOLD}1.${RESET} English\n"
    printf "${YELLOW}${BOLD}2.${RESET} Français\n"
    printf "${GREEN}${BOLD}> ${RESET}"
    local c; read c || c=1
    case "$c" in
        2) APP_LANG="fr" ;;
        *) APP_LANG="en" ;;
    esac
    export APP_LANG
    save_language
}
