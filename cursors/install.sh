#!/usr/bin/env sh
# Compile the Dragon Slayer hyprcursor theme into ~/.local/share/icons.
# Hyprland picks it up via HYPRCURSOR_THEME=theme_dragon-slayer (hyprland.conf).
set -e
src="$(cd "$(dirname "$0")" && pwd)/dragon-slayer"
out="$HOME/.local/share/icons"
mkdir -p "$out"
rm -rf "$out/theme_dragon-slayer"
hyprcursor-util --create "$src" --output "$out"
hyprctl setcursor theme_dragon-slayer 24 >/dev/null 2>&1 || true
echo "installed $out/theme_dragon-slayer"
