

autoload -Uz is-at-least

function omz_diagnostic_dump() {
  emulate -L zsh

  builtin echo "Generating diagnostic dump; please be patient..."

  local thisfcn=omz_diagnostic_dump
  local -A opts
  local opt_verbose opt_noverbose opt_outfile
  local timestamp=$(date +%Y%m%d-%H%M%S)
  local outfile=omz_diagdump_$timestamp.txt
  builtin zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
  local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose}
  (( verbose = 1 + n_verbose - n_noverbose ))

  if [[ ${#*} > 0 ]]; then
    opt_outfile=$1
  fi
  if [[ ${#*} > 1 ]]; then
    builtin echo "$thisfcn: error: too many arguments" >&2
    return 1
  fi
  if [[ -n "$opt_outfile" ]]; then
    outfile="$opt_outfile"
  fi

  _omz_diag_dump_one_big_text &> "$outfile"
  if [[ $? != 0 ]]; then
    builtin echo "$thisfcn: error while creating diagnostic dump; see $outfile for details"
  fi

  builtin echo
  builtin echo Diagnostic dump file created at: "$outfile"
  builtin echo
  builtin echo To share this with OMZ developers, post it as a gist on GitHub
  builtin echo at "https://gist.github.com" and share the link to the gist.
  builtin echo
  builtin echo "WARNING: This dump file contains all your zsh and omz configuration files,"
  builtin echo "so don't share it publicly if there's sensitive information in them."
  builtin echo

}

function _omz_diag_dump_one_big_text() {
  local program programs progfile md5

  builtin echo oh-my-zsh diagnostic dump
  builtin echo
  builtin echo $outfile
  builtin echo

  command date
  command uname -a
  builtin echo OSTYPE=$OSTYPE
  builtin echo ZSH_VERSION=$ZSH_VERSION
  builtin echo User: $USERNAME
  builtin echo umask: $(umask)
  builtin echo
  _omz_diag_dump_os_specific_version
  builtin echo

  programs=(sh zsh ksh bash sed cat grep ls find git posh)
  local progfile="" extra_str="" sha_str=""
  for program in $programs; do
    extra_str="" sha_str=""
    progfile=$(builtin which $program)
    if [[ $? == 0 ]]; then
      if [[ -e $progfile ]]; then
        if builtin whence shasum &>/dev/null; then
          sha_str=($(command shasum $progfile))
          sha_str=$sha_str[1]
          extra_str+=" SHA $sha_str"
        fi
        if [[ -h "$progfile" ]]; then
          extra_str+=" ( -> ${progfile:A} )"
        fi
      fi
      builtin printf '%-9s %-20s %s\n' "$program is" "$progfile" "$extra_str"
    else
      builtin echo "$program: not found"
    fi
  done
  builtin echo
  builtin echo Command Versions:
  builtin echo "zsh: $(zsh --version)"
  builtin echo "this zsh session: $ZSH_VERSION"
  builtin echo "bash: $(bash --version | command grep bash)"
  builtin echo "git: $(git --version)"
  builtin echo "grep: $(grep --version)"
  builtin echo

  _omz_diag_dump_check_core_commands || return 1
  builtin echo

  builtin echo Process state:
  builtin echo pwd: $PWD
  if builtin whence pstree &>/dev/null; then
    builtin echo Process tree for this shell:
    pstree -p $$
  else
    ps -fT
  fi
  builtin set | command grep -a '^\(ZSH\|plugins\|TERM\|LC_\|LANG\|precmd\|chpwd\|preexec\|FPATH\|TTY\|DISPLAY\|PATH\)\|OMZ'
  builtin echo
  builtin echo Exported:
  builtin echo $(builtin export | command sed 's/=.*//')
  builtin echo
  builtin echo Locale:
  command locale
  builtin echo

  builtin echo Zsh configuration:
  builtin echo setopt: $(builtin setopt)
  builtin echo
  builtin echo zstyle:
  builtin zstyle
  builtin echo
  builtin echo 'compaudit output:'
  compaudit
  builtin echo
  builtin echo '$fpath directories:'
  command ls -lad $fpath
  builtin echo

  builtin echo oh-my-zsh installation:
  command ls -ld ~/.z*
  command ls -ld ~/.oh*
  builtin echo
  builtin echo oh-my-zsh git state:
  (builtin cd $ZSH && builtin echo "HEAD: $(git rev-parse HEAD)" && git remote -v && git status | command grep "[^[:space:]]")
  if [[ $verbose -ge 1 ]]; then
    (builtin cd $ZSH && git reflog --date=default | command grep pull)
  fi
  builtin echo
  if [[ -e $ZSH_CUSTOM ]]; then
    local custom_dir=$ZSH_CUSTOM
    if [[ -h $custom_dir ]]; then
      custom_dir=$(builtin cd $custom_dir && pwd -P)
    fi
    builtin echo "oh-my-zsh custom dir:"
    builtin echo "   $ZSH_CUSTOM ($custom_dir)"
    (builtin cd ${custom_dir:h} && command find ${custom_dir:t} -name .git -prune -o -print)
    builtin echo
  fi

  if [[ $verbose -ge 1 ]]; then
    builtin echo "bindkey:"
    builtin bindkey
    builtin echo
    builtin echo "infocmp:"
    command infocmp -L
    builtin echo
  fi

  local zdotdir=${ZDOTDIR:-$HOME}
  builtin echo "Zsh configuration files:"
  local cfgfile cfgfiles
  cfgfiles=( /etc/zshenv /etc/zprofile /etc/zshrc /etc/zlogin /etc/zlogout
    $zdotdir/.zshenv $zdotdir/.zprofile $zdotdir/.zshrc $zdotdir/.zlogin $zdotdir/.zlogout
    ~/.zsh.pre-oh-my-zsh
    /etc/bashrc /etc/profile ~/.bashrc ~/.profile ~/.bash_profile ~/.bash_logout )
  command ls -lad $cfgfiles 2>&1
  builtin echo
  if [[ $verbose -ge 1 ]]; then
    for cfgfile in $cfgfiles; do
      _omz_diag_dump_echo_file_w_header $cfgfile
    done
  fi
  builtin echo
  builtin echo "Zsh compdump files:"
  local dumpfile dumpfiles
  command ls -lad $zdotdir/.zcompdump*
  dumpfiles=( $zdotdir/.zcompdump*(N) )
  if [[ $verbose -ge 2 ]]; then
    for dumpfile in $dumpfiles; do
      _omz_diag_dump_echo_file_w_header $dumpfile
    done
  fi

}

function _omz_diag_dump_check_core_commands() {
  builtin echo "Core command check:"
  local redefined name builtins externals reserved_words
  redefined=()
  reserved_words=( do done esac then elif else fi for case if while function
    repeat time until select coproc nocorrect foreach end '!' '[[' '{' '}'
    )
  builtins=( alias autoload bg bindkey break builtin bye cd chdir command
    comparguments compcall compctl compdescribe compfiles compgroups compquote comptags
    comptry compvalues continue dirs disable disown echo echotc echoti emulate
    enable eval exec exit false fc fg functions getln getopts hash
    jobs kill let limit log logout noglob popd print printf
    pushd pushln pwd r read rehash return sched set setopt shift
    source suspend test times trap true ttyctl type ulimit umask unalias
    unfunction unhash unlimit unset unsetopt vared wait whence where which zcompile
    zle zmodload zparseopts zregexparse zstyle )
  if is-at-least 5.1; then
    reserved_word+=( declare export integer float local readonly typeset )
  else
    builtins+=( declare export integer float local readonly typeset )
  fi
  builtins_fatal=( builtin command local )
  externals=( zsh )
  for name in $reserved_words; do
    if [[ $(builtin whence -w $name) != "$name: reserved" ]]; then
      builtin echo "reserved word '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done
  for name in $builtins; do
    if [[ $(builtin whence -w $name) != "$name: builtin" ]]; then
      builtin echo "builtin '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done
  for name in $externals; do
    if [[ $(builtin whence -w $name) != "$name: command" ]]; then
      builtin echo "command '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done

  if [[ -n "$redefined" ]]; then
    builtin echo "SOME CORE COMMANDS HAVE BEEN REDEFINED: $redefined"
  else
    builtin echo "All core commands are defined normally"
  fi

}

function _omz_diag_dump_echo_file_w_header() {
  local file=$1
  if [[ ( -f $file || -h $file ) ]]; then
    builtin echo "========== $file =========="
    if [[ -h $file ]]; then
      builtin echo "==========    ( => ${file:A} )   =========="
    fi
    command cat $file
    builtin echo "========== end $file =========="
    builtin echo
  elif [[ -d $file ]]; then
    builtin echo "File '$file' is a directory"
  elif [[ ! -e $file ]]; then
    builtin echo "File '$file' does not exist"
  else
    command ls -lad "$file"
  fi
}

function _omz_diag_dump_os_specific_version() {
  local osname osver version_file version_files
  case "$OSTYPE" in
    darwin*)
      osname=$(command sw_vers -productName)
      osver=$(command sw_vers -productVersion)
      builtin echo "OS Version: $osname $osver build $(sw_vers -buildVersion)"
      ;;
    cygwin)
      command systeminfo | command head -n 4 | command tail -n 2
      ;;
  esac

  if builtin which lsb_release >/dev/null; then
    builtin echo "OS Release: $(command lsb_release -s -d)"
  fi

  version_files=( /etc/*-release(N) /etc/*-version(N) /etc/*_version(N) )
  for version_file in $version_files; do
    builtin echo "$version_file:"
    command cat "$version_file"
    builtin echo
  done
}

