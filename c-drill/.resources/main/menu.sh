#!/bin/bash
MAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RES="$(cd "$MAIN/.." && pwd)"
chmod +x "$RES/checker.sh" 2>/dev/null
source "$MAIN/lang.sh"
if [ ! -f "$MAIN/.applang" ]; then choose_language; else load_language; fi
bash "$MAIN/intro.sh"
