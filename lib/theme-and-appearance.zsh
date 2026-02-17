autoload -U colors && colors

setopt prompt_subst

ZSH_THEME_GIT_PROMPT_PREFIX="git:("   # Beginning of the git prompt, before the branch name
ZSH_THEME_GIT_PROMPT_SUFFIX=")"       # End of the git prompt
ZSH_THEME_GIT_PROMPT_DIRTY="*"        # Text to display if the branch is dirty
ZSH_THEME_GIT_PROMPT_CLEAN=""         # Text to display if the branch is clean
ZSH_THEME_RUBY_PROMPT_PREFIX="("
ZSH_THEME_RUBY_PROMPT_SUFFIX=")"


if command diff --color /dev/null{,} &>/dev/null; then
  function diff {
    command diff --color "$@"
  }
fi

[[ "$DISABLE_LS_COLORS" != true ]] || return 0

export LSCOLORS="Gxfxcxdxbxegedabagacad"

if [[ -z "$LS_COLORS" ]]; then
  if (( $+commands[dircolors] )); then
    [[ -f "$HOME/.dircolors" ]] \
      && source <(dircolors -b "$HOME/.dircolors") \
      || source <(dircolors -b)
  else
    export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
  fi
fi

function test-ls-args {
  command "$@" /dev/null &>/dev/null
}

case "$OSTYPE" in
  netbsd*)
    test-ls-args gls --color && alias ls='gls --color=tty'
    ;;
  openbsd*)
    test-ls-args gls --color && alias ls='gls --color=tty'
    test-ls-args colorls -G && alias ls='colorls -G'
    ;;
  (darwin|freebsd)*)
    test-ls-args ls -G && alias ls='ls -G'
    zstyle -t ':omz:lib:theme-and-appearance' gnu-ls \
      && test-ls-args gls --color \
      && alias ls='gls --color=tty'
    ;;
  *)
    if test-ls-args ls --color; then
      alias ls='ls --color=tty'
    elif test-ls-args ls -G; then
      alias ls='ls -G'
    fi
    ;;
esac

unfunction test-ls-args
