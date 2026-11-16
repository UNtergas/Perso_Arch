# Long-command notification inside tmux: a command that ran for TMUX_NOTIFY_SECS (default 30) or more, in a window you
# are not looking at, gives the tab a green (ok) or red (failed) dot and a desktop notification. Uses ~/.tmux/notify.sh.
# Interactive programs and Ctrl-C are skipped. Copy of new_zsh/notify.zsh, appended to ~/.zshrc.
if [[ -n $TMUX_PANE ]]; then
  zmodload zsh/datetime
  autoload -Uz add-zsh-hook
  : ${TMUX_NOTIFY_SECS:=30}
  _tmux_notify_preexec() { _tn_cmd=${${(z)1}[1]:t}; _tn_start=$EPOCHSECONDS }
  _tmux_notify_precmd() {
    local rc=$?
    [[ -n $_tn_start ]] || return
    local secs=$(( EPOCHSECONDS - _tn_start )) cmd=$_tn_cmd
    _tn_start=
    (( secs >= TMUX_NOTIFY_SECS )) || return
    (( rc == 130 )) && return
    case $cmd in
      nvim|kvim|vim|vi|less|man|ssh|htop|btop|top|tmux|fzf|claude|watch|tail|journalctl|lazygit) return ;;
    esac
    local kind=done; (( rc == 0 )) || kind=fail
    ~/.tmux/notify.sh $kind "$cmd" </dev/null &>/dev/null &!
  }
  add-zsh-hook preexec _tmux_notify_preexec
  add-zsh-hook precmd _tmux_notify_precmd
fi
