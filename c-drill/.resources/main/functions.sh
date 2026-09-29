#!/bin/bash
# Small shared helpers (loading animation + paths)

frames=("◐" "◓" "◑" "◒")
duration=0.08
loop_count=2

clear_screen() { printf "\033c"; }

display_animation() {
    for i in $(seq 1 $loop_count); do
        for frame in "${frames[@]}"; do
            clear_screen
            printf "\033[1;32mPlease wait... %s\033[0m\n\n" "$frame"
            sleep $duration
        done
    done
}

# Absolute path to the .resources directory (this file lives in main/)
res_root() { cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd; }
# Absolute path to the project root (parent of .resources)
project_root() { cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd; }
