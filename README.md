# dotfiles

Ubuntu 24.04 + self-built Hyprland. Berserk palette (black / `#8b0000` red).

| package    | what                                                        |
|------------|-------------------------------------------------------------|
| `hypr`     | Hyprland, hyprpaper, hyprlock, hypridle, portal config      |
| `waybar`   | bar                                                         |
| `mako`     | notifications                                               |
| `fuzzel`   | launcher (Super+D) and clipboard picker (Super+Shift+V)     |
| `ghostty`  | terminal                                                    |
| `tmux`     | plugin-free tmux, prefix `C-Space`                          |
| `nvim`     | Neovim (lazy.nvim, fff, blink.cmp, native LSP config)       |
| `fish`     | shell config                                                |
| `starship` | prompt                                                      |
| `git`      | `~/.gitconfig`, global gitignore                            |
| `bin`      | `~/.local/bin` scripts (`tmux-sessionizer`)                 |
| `cursors`  | Dragon Slayer hyprcursor theme (compiled, not linked)       |
| `scripts`  | `update-desktop.sh`: build/update the Hyprland stack        |

## Install

```sh
sudo apt install stow fish tmux zoxide fzf ripgrep playerctl brightnessctl \
  cliphist wl-clipboard thunar
git clone <this repo> ~/dotfiles
~/dotfiles/install.sh        # -n for a dry run, or name packages: install.sh nvim tmux
```

`install.sh` stows every package into `$HOME`. Files that are in the way get
moved to `~/.dotfiles-backup/<timestamp>/`. Running it again is safe.

Neovim comes from the snap (`sudo snap install nvim --classic`). Plugins install
on first start; Mason installs the LSP servers and formatters.

## Desktop stack

Hyprland, its libraries, hyprlock, hypridle, waybar, ghostty and hyprshot are
built from source, because Ubuntu 24.04's packages are too old:

```sh
scripts/update-desktop.sh            # installed vs latest
scripts/update-desktop.sh --install  # build + install whatever is outdated
```

See the header of the script for the apt build dependencies. Log out and back in
(Super+Shift+M) after a Hyprland update.

## Keys

| key                     | action                               |
|-------------------------|--------------------------------------|
| Super+Q / D / E         | terminal / launcher / file manager   |
| Super+C                 | close window                         |
| Super+H/J/K/L           | move focus                           |
| Super+Ctrl / Alt+HJKL   | resize / move window                 |
| Super+F / Shift+F       | fullscreen / maximize                |
| Super+V                 | toggle floating                      |
| Super+S / Alt+S         | toggle scratchpad / send window to it |
| Super+Shift+L           | lock                                 |
| Super+Shift+S           | screenshot region to clipboard       |
| Super+Ctrl+S / Print    | screenshot region / monitor to `~/Pictures/Screenshots` |
| Super+Shift+V           | clipboard history                    |
| Super+Shift+M           | exit Hyprland                        |
| prefix f (tmux), C-f (nvim) | tmux-sessionizer                 |
| Alt+1..5 (tmux)         | jump to window                       |
| Ctrl+R / Ctrl+T / Alt+C (fish) | fzf history / insert path / cd |

The screen locks after 10 min idle and the monitor turns off after 15 min. The
waybar idle-inhibitor button pauses both.
