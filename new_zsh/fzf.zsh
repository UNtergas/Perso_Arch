# fzf: Ctrl-R history, Ctrl-P files, Ctrl-O cd. Needs fzf 0.48+ and fd.
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# rebind: Ctrl-P files (like VSCode), Ctrl-O cd; free Ctrl-T and Alt-C
bindkey -r '^T' '\ec'
bindkey '^P' fzf-file-widget
bindkey '^O' fzf-cd-widget
