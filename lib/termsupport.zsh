function title {
  setopt localoptions nopromptsubst

  [[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return

  : ${2=$1}

  case "$TERM" in
    cygwin|xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty*|st*|foot*|contour*|wezterm*)
      print -Pn "\e]2;${2:q}\a" # set window name
      print -Pn "\e]1;${1:q}\a" # set tab name
      ;;
    screen*|tmux*)
      print -Pn "\ek${1:q}\e\\" # set screen hardstatus
      ;;
    *)
      if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        print -Pn "\e]2;${2:q}\a" # set window name
        print -Pn "\e]1;${1:q}\a" # set tab name
      else
        if (( ${+terminfo[fsl]} && ${+terminfo[tsl]} )); then
          print -Pn "${terminfo[tsl]}$1${terminfo[fsl]}"
        fi
      fi
      ;;
  esac
}

ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
ZSH_THEME_TERM_TITLE_IDLE="%n@%m:%~"
if [[ "$TERM_PROGRAM" == Apple_Terminal ]]; then
  ZSH_THEME_TERM_TITLE_IDLE="%n@%m"
fi

function omz_termsupport_precmd {
  [[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
  title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}

function omz_termsupport_preexec {
  [[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0

  emulate -L zsh
  setopt extended_glob

  local -a cmdargs
  cmdargs=("${(z)2}")
  if [[ "${cmdargs[1]}" = fg ]]; then
    local job_id jobspec="${cmdargs[2]#%}"
    case "$jobspec" in
      <->) # %number argument:
        job_id=${jobspec} ;;
      ""|%|+) # empty, %% or %+ argument:
        job_id=${(k)jobstates[(r)*:+:*]} ;;
      -) # %- argument:
        job_id=${(k)jobstates[(r)*:-:*]} ;;
      [?]*) # %?string argument:
        job_id=${(k)jobtexts[(r)*${(Q)jobspec}*]} ;;
      *) # %string argument:
        job_id=${(k)jobtexts[(r)${(Q)jobspec}*]} ;;
    esac

    if [[ -n "${jobtexts[$job_id]}" ]]; then
      1="${jobtexts[$job_id]}"
      2="${jobtexts[$job_id]}"
    fi
  fi

  local CMD="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}"
  local LINE="${2:gs/%/%%}"

  title "$CMD" "%100>...>${LINE}%<<"
}

autoload -Uz add-zsh-hook

if [[ -z "$INSIDE_EMACS" || "$INSIDE_EMACS" = vterm ]]; then
  add-zsh-hook precmd omz_termsupport_precmd
  add-zsh-hook preexec omz_termsupport_preexec
fi


if [[ -n "$INSIDE_EMACS" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
  return
fi

case "$TERM" in
  xterm*|putty*|rxvt*|konsole*|mlterm*|alacritty*|screen*|tmux*) ;;
  contour*|foot*) ;;
  *)
    case "$TERM_PROGRAM" in
      Apple_Terminal|iTerm.app) ;;
      *) return ;;
    esac ;;
esac

function omz_termsupport_cwd {
  setopt localoptions unset
  local URL_HOST URL_PATH
  URL_HOST="$(omz_urlencode -P $HOST)" || return 1
  URL_PATH="$(omz_urlencode -P $PWD)" || return 1

  [[ -z "$KONSOLE_PROFILE_NAME" && -z "$KONSOLE_DBUS_SESSION"  ]] || URL_HOST=""

  printf "\e]7;file://%s%s\e\\" "${URL_HOST}" "${URL_PATH}"
}

add-zsh-hook precmd omz_termsupport_cwd
