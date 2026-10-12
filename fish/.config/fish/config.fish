# fish config

set -g fish_greeting
set -g fish_history_max_size 10000

fish_add_path ~/.local/bin ~/.npm-global/bin
if test -d /usr/local/NVIDIA-Nsight-Compute-2025.4/host/target-linux-x64
    fish_add_path /usr/local/NVIDIA-Nsight-Compute-2025.4/host/target-linux-x64
end

set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-interactive
    abbr -a ll 'ls -l'
    abbr -a la 'ls -la'
    abbr -a g git
    abbr -a ts tmux-sessionizer

    # syntax highlighting
    set -g fish_color_command "#A6E3A1"
    set -g fish_color_error red
    set -g fish_color_param normal
    set -g fish_color_comment brblack
    set -g fish_color_quote yellow
    set -g fish_color_redirection cyan

    command -q zoxide; and zoxide init fish | source
    # Ctrl+R history, Ctrl+T insert path, Alt+C cd (from Ubuntu's fzf package)
    functions -q fzf_key_bindings; and fzf_key_bindings
    command -q starship; and starship init fish | source
end
