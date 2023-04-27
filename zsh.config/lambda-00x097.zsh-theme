autoload colors

# use `spectrum_ls` command for getting color scale

export WHITE="251"
export GRAY="244"
export GREEN="002"
export YELLOW="190"
export RED="196"

prompt() {
   if [[ $EUID -ne 0 ]]; then
      echo "%F{$GRAY}╭ %F{$GREEN}%n%F{$GRAY}@%F{$GREEN}%M%F{$GRAY}:%~\n╰ %F{$GREEN}λ%f"
   else
      echo "%F{$GRAY}╭ %F{$RED}%n%F{$GRAY}@%F{$RED}%M%F{$GRAY}:%~\n╰ %F{$RED}λ%f"
   fi
}

# returns 👾 if there are errors, nothing otherwise
return_status() {
   echo "%(?..👾)"
}

# set the git_prompt_info text
ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%B$(prompt)%b '
RPROMPT='$(git_prompt_info)'
