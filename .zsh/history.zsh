HIST_STAMPS="yyyy-mm-dd"

## History wrapper (taken from oh-my-zsh)
function custom_history {
  # parse arguments and remove from $@
  local clear list stamp
  zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp

  if [[ -n "$clear" ]]; then
    # if -c provided, clobber the history file
    echo -n >| "$HISTFILE"
    fc -p "$HISTFILE"
    echo >&2 History file deleted.
  elif [[ $# -eq 0 ]]; then
    # if no arguments provided, show full history starting from 1
    builtin fc $stamp -l 1
  else
    # otherwise, run `fc -l` with a custom format
    builtin fc $stamp -l "$@"
  fi
}

# Timestamp format
case ${HIST_STAMPS-} in
  "mm/dd/yyyy") alias history='custom_history -f' ;;
  "dd.mm.yyyy") alias history='custom_history -E' ;;
  "yyyy-mm-dd") alias history='custom_history -i' ;;
  "") alias history='custom_history' ;;
  *) alias history="custom_history -t '$HIST_STAMPS'" ;;
esac

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data