# Author: 	   Tanner.L.Woody@gmail.com
# Date: 		   2019-03-29
# Last Update: 2021-10-07

#Import (i.e. `source`) all files in ~/bin/
#for f in ~/bin/*; do source $f --source-only; echo "imported ~/bin/$f"; done

source ~/install-scripts/src/rc_files/sources

### ### ### BASH HISTORY ### ### ### 
export HISTFILESIZE=20000
export HISTSIZE=10000
shopt -s histappend
# Combine multiline commands into one in history
shopt -s cmdhist
# Ignore duplicates, ls without options and builtin commands
HISTCONTROL=ignoredups
#export HISTIGNORE="&:ls:sl:[bf]g:exit:q:attic:"

### ### ### BASH PROMPT CONFIG ### ### ### 
###[12:17][useralpha:~/foo/bar]$ 
function __setprompt {
  #https://unix.stackexchange.com/questions/381113/how-do-i-shorten-the-current-directory-path-shown-on-terminal
  local BLUE="\[\033[0;34m\]"
  local NO_COLOUR="\[\033[0m\]"
  local SSH_IP=`echo $SSH_CLIENT | awk '{ print $1 }'`
  local SSH2_IP=`echo $SSH2_CLIENT | awk '{ print $1 }'`
  if [ $SSH2_IP ] || [ $SSH_IP ] ; then
    local SSH_FLAG="@\h"
  fi
  #PS1='\u@\h: \W:\$'
  #PS1="\[\033[42m\]\[\033[31m\]\u@\h:\w\$ "
  #PS1="\[\033[42m\]\[\033[31m\]\u@\h:\W\\[\033[00m\]\$ "
  PS1="\[\033[4;41m\]\[\033[33m\][\$(date +%H:%M)][\u:\W]\\$ \[\033[00m\]"

  #PS1="\e[41;4;33m[\$(date +%H:%M)][\u$SSH_FLAG:\W]\$ $NO_COLOUR"
  #PS1="\\[$(tput setaf 1)\\]\\u@\\h:\\w #\\[$(tput sgr0)\\]"
  #PS2="\e[41;4;33m$NO_COLOUR "
  #PS4="\e[41;4;33m$NO_COLOUR "
}
__setprompt
