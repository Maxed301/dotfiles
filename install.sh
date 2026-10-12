#!/usr/bin/env bash
# Symlink the dotfiles into $HOME with GNU stow.
#
#   ./install.sh              stow every package
#   ./install.sh nvim tmux    stow only these
#   ./install.sh -n           dry run: show what would happen
#
# A file in $HOME that would block a link (a real file, or a symlink that
# points somewhere else) is moved to
# ~/.dotfiles-backup/<timestamp>/ first. Re-running is safe.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
ALL=(bin fish fuzzel ghostty git hypr mako nvim starship tmux waybar)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

dry=0
[ "${1:-}" = "-n" ] && { dry=1; shift; }
pkgs=("$@")
[ ${#pkgs[@]} -eq 0 ] && pkgs=("${ALL[@]}")

command -v stow >/dev/null || { echo "stow is not installed (sudo apt install stow)" >&2; exit 1; }

# true if $1 already resolves into this repo (a link stow made, or an older
# hand-made link to the same place)
ours() { [ -L "$1" ] && [[ "$(readlink -f "$1" 2>/dev/null)" == "$DOTFILES"/* ]]; }

backup() { # path relative to $HOME
  local src="$HOME/$1"
  if [ $dry -eq 1 ]; then echo "would back up ~/$1"; return; fi
  mkdir -p "$BACKUP/$(dirname "$1")"
  mv "$src" "$BACKUP/$1"
  echo "backed up ~/$1 -> ${BACKUP/#$HOME/\~}/$1"
}

for pkg in "${pkgs[@]}"; do
  [ -d "$DOTFILES/$pkg" ] || { echo "no such package: $pkg" >&2; exit 1; }
  # walk the package; stop descending as soon as a path in $HOME is ours
  # or missing, since stow takes it from there
  while IFS= read -r -d '' f; do
    rel="${f#"$DOTFILES/$pkg/"}"
    tgt="$HOME/$rel"
    skip=0
    p="$rel"
    while [ "$p" != . ]; do
      if ours "$HOME/$p"; then skip=1; break; fi
      p="$(dirname "$p")"
    done
    [ $skip -eq 1 ] && continue
    if [ -L "$tgt" ] || { [ -e "$tgt" ] && [ ! -d "$tgt" ]; }; then
      backup "$rel"
    fi
  done < <(find "$DOTFILES/$pkg" -mindepth 1 ! -type d -print0)

  if [ $dry -eq 1 ]; then
    stow -n -v -d "$DOTFILES" -t "$HOME" "$pkg" 2>&1 | grep -v '^WARNING: in simulation mode' || true
  else
    stow -d "$DOTFILES" -t "$HOME" "$pkg"
    echo "stowed $pkg"
  fi
done

# the hyprcursor theme is compiled, not linked
if [[ " ${pkgs[*]} " == *" hypr "* ]] && [ $dry -eq 0 ] && command -v hyprcursor-util >/dev/null; then
  "$DOTFILES/cursors/install.sh"
fi
