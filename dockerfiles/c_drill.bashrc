
# --- c-drill -----------------------------------------------------------------
alias examshell='bash ~/c-drill/examshell'
# Launch the simulator automatically once, when the terminal opens.
if [ -z "${CDRILL_STARTED:-}" ] && [ -t 0 ]; then
    export CDRILL_STARTED=1
    bash ~/c-drill/examshell
    echo
    echo "Tape 'examshell' pour relancer / type 'examshell' to restart."
    echo "Deux terminaux cote a cote / two panes side by side : tmux"
fi
