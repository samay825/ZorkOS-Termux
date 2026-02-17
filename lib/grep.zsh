__GREP_CACHE_FILE="$ZSH_CACHE_DIR"/grep-alias

__GREP_ALIAS_CACHES=("$__GREP_CACHE_FILE"(Nm-1))
if [[ -n "$__GREP_ALIAS_CACHES" ]]; then
    source "$__GREP_CACHE_FILE"
else
    grep-flags-available() {
        command grep "$@" "" &>/dev/null <<< ""
    }

    EXC_FOLDERS="{.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}"

    if grep-flags-available --color=auto --exclude-dir=.cvs; then
        GREP_OPTIONS="--color=auto --exclude-dir=$EXC_FOLDERS"
    elif grep-flags-available --color=auto --exclude=.cvs; then
        GREP_OPTIONS="--color=auto --exclude=$EXC_FOLDERS"
    fi

    if [[ -n "$GREP_OPTIONS" ]]; then
        alias grep="grep $GREP_OPTIONS"
        alias egrep="grep -E"
        alias fgrep="grep -F"

        if [[ -w "$ZSH_CACHE_DIR" ]]; then
            alias -L grep egrep fgrep >| "$__GREP_CACHE_FILE"
        fi
    fi

    unset GREP_OPTIONS EXC_FOLDERS
    unfunction grep-flags-available
fi

unset __GREP_CACHE_FILE __GREP_ALIAS_CACHES
