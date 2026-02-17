
function chruby_prompt_info \
  rbenv_prompt_info \
  hg_prompt_info \
  pyenv_prompt_info \
  svn_prompt_info \
  vi_mode_prompt_info \
  virtualenv_prompt_info \
  jenv_prompt_info \
  azure_prompt_info \
  tf_prompt_info \
  conda_prompt_info \
{
  return 1
}

function rvm_prompt_info() {
  [ -f $HOME/.rvm/bin/rvm-prompt ] || return 1
  local rvm_prompt
  rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${=ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null)
  [[ -z "${rvm_prompt}" ]] && return 1
  echo "${ZSH_THEME_RUBY_PROMPT_PREFIX}${rvm_prompt:gs/%/%%}${ZSH_THEME_RUBY_PROMPT_SUFFIX}"
}

ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"


function ruby_prompt_info() {
  echo "$(rvm_prompt_info || rbenv_prompt_info || chruby_prompt_info)"
}
