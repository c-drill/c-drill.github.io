#!/bin/bash
# Lets you launch the simulator by simply typing:  examshell
# Safe to re-run after moving the folder: it refreshes the symlink and the alias.
DIR="$(cd "$(dirname "$0")" && pwd)"
LAUNCH="$DIR/examshell"
chmod +x "$LAUNCH" 2>/dev/null

# 1) refresh the symlink in ~/.local/bin
mkdir -p "$HOME/.local/bin"
ln -sf "$LAUNCH" "$HOME/.local/bin/examshell"

# 2) refresh the alias in the shell rc files (remove any stale one first)
#    Make sure the rc file of the CURRENT shell exists (a fresh Mac has no
#    ~/.zshrc; macOS Terminal opens bash as a login shell -> ~/.bash_profile).
case "${SHELL:-}" in
  *zsh)  touch "$HOME/.zshrc" ;;
  *bash) if [ "$(uname -s)" = "Darwin" ]; then touch "$HOME/.bash_profile"
         else touch "$HOME/.bashrc"; fi ;;
esac
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  [ -e "$rc" ] || continue
  # strip any previous examshell alias line (pointing to an old/dead path)
  sed -i.bak '/alias examshell=/d' "$rc" 2>/dev/null
  rm -f "$rc.bak" 2>/dev/null
  printf '\nalias examshell=%q\n' "$LAUNCH" >> "$rc"
done

echo "Installed. Symlink + 'examshell' alias now point to:"
echo "  $LAUNCH"
echo
echo "Reload your shell then launch it:"
echo "  source ~/.zshrc   (or: source ~/.bashrc / ~/.bash_profile)"
echo "  examshell"
