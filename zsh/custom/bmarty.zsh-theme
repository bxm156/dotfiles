## Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

## GIT 

ZSH_THEME_GIT_PROMPT_PREFIX="[git:"
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}+"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}?"

function git_prompt_info() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

## VI Mode

VI_NORMAL_MODE="NORMAL"
VI_INSERT_MODE="INSERT"


function vi_mode_prompt_info() {
  echo "${${KEYMAP/vicmd/$VI_NORMAL_MODE}/(main|viins)/$VI_INSERT_MODE}"
}

## YELP STUFF

function get_sandbox_info() {
	if [ x"$YELP_MYSQL_RW_PORT" = x ]; then
		return
	else
		echo RW:$YELP_MYSQL_RW_PORT $PGNAME 
	fi
}

## Python

function virtualenv_info {
        [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

## Unix

function get_pwd() {
    echo "${PWD/$HOME/~}"
}

## Build Prompt

build_prompt() {
    prompt_host
    prompt_directory
    prompt_git
    prompt_new_line
    prompt_end
}

build_right_prompt() {
    prompt_vi_mode
    prompt_segment default magenta $(get_sandbox_info)
    prompt_battery
    prompt_end
}

prompt_host() {
    prompt_segment default cyan
    echo -n "%m:"
}

prompt_directory() {
    prompt_segment default yellow " $(get_pwd)"
}

prompt_vi_mode() {
    prompt_segment green black " $(vi_mode_prompt_info)"
}

prompt_git() {
    prompt_segment default default " $(git_prompt_info)"    
}

prompt_battery() {
    echo -n "$(battery_pct_prompt)"
}

prompt_new_line() {
    prompt_segment default magenta "
 $"
}
RPROMPT='$(build_right_prompt)'
PROMPT='$(build_prompt)'
