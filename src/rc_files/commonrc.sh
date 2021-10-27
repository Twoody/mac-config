#!/bin/bash

### Typos & short-hands
alias q='exit'
alias v='vim'
alias g='grep -ri '
alias sl='ls'
alias gim="vim"

### Most convenient aliases
alias c='clear && ls && echo -e "\n" && gs'

alias findy='find . -name'
alias hosts="vim /etc/hosts/"
# Might need mogrify
#alias make-pngs="find . -name "*.jpg" -exec mogrify -format png {} \;"
alias :q="echo \"THIS IS NOT vim, DUMMY\""
alias :w="echo \"THIS IS NOT vim, DUMMY\""
alias la='ls -la'
alias lsd="du -h | sort -n -r"           ## List all contents in dir by file size;
alias hgrep="history | grep "
alias bhist="vim ~/.bash_history"
alias zhist="vim ~/.zsh_history"
alias brc="vim ~/install-scripts/src/rc_files/.bashrc"
alias vrc="vim ~/install-scripts/src/rc_files/.vimrc"
alias zrc="vim ~/install-scripts/src/rc_files/.zshrc"
alias brc-local="vim ~/.bashrc"
alias vrc-local="vim ~/.vimrc"
alias zrc-local="vim ~/.zshrc"
alias sbrc="source ~/install-scripts/src/rc_files/sources && source ~/.bashrc"
alias szrc="source ~/install-scripts/src/rc_files/sources && source ~/.zshrc"
alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias update-fork="git fetch upstream && git checkout master && git merge upstream/master"
alias get-devices="arp -a"

### Fun
alias shrug="echo '¯\_(ツ)_/¯'";
alias fight="echo '(ง'̀-'́)ง'";

### Show just the directories contained in current dir;
alias folders='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'

### ### ### TRAVERSAL ALIASES ### ### ### 
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

### Docker
alias dockup="docker-compose --compatibility up --force-recreate"
alias dockpatch="docker-compose pull && docker-compsoe build --pull"
alias dockdown="docker-compose down --remove-orphans"

### Misc
alias art="php artisan"
#find . -type f -name '*.log' -print0 | xargs -0 grep "fo"

### For all of the extraction conveniences
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1     ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
}

### Get grep results for vue build ###
gvue () {
	# Skip over node_modules/ and .git/ + Follow sylinks on recursion;
	#grep --exclude-dir={node_modules,.git} -Ri "$1" ./src/
   grep --exclude-dir={node_modules,.git} -Ri "$1" ./
	true
}

### Very Liberal Search for somethign that looks like what we want ###
search () {
	find . -iname *$1*
	true
}

### Ensure that git hook messages are not suppressed by arcanist
arc () {
	if [ -f .git/hooks/post-checkout ] && [[ $1 == "patch" ]]; then
		command arc "$@" && sh ./.git/hooks/post-checkout
	else
		command arc "$@"
	fi
}

### Replace all spaces with underscores within parent
strip-spaces () {
	find . -depth -name '* *' \
	| while IFS= read -r f ; do mv -i "$f" "$(dirname "$f")/$(basename "$f"|tr ' ' _)" ; done
}

search-replace () {
	perl -i -pe 's/$1/$2/g' $3
}

### Execute an sqlite3 file on a given db
sql3-exec () {
  # TODO: Ensure that $1 is a db
  # TODO: Ensure that $2 is a .sql file
  # TODO: Probably store a backup...
  # TODO: write a  --help flag
  sqlite3 $1 ".read $2"
  true
}

### Get the latest file by timestamp
# @param $1 - Target dir
get-newest-in-dir ()
{
	RET="$(ls $1 | sort -n -t _ -k 2 | tail -1)"
	#printf "\t\t$RET\n\n"
	echo "$RET"
}

### Upgrade file if not match to newest file in target dir
# $1 target directory to either be saved or written over
# $2 target directory to parse against
upgrade-file-on-no-match ()
{
  LATEST_FILE=$(get-newest-in-dir $1)
  printf "$LATEST_FILE\n\n"
  printf "starting...\n"
  if [ ! -d $1 ];
  then
	  printf "\tDIRECTORY $1 DOES NOT EXIST; ABORT 1\n"
	  return 1
  fi
  if [ ! -d $2 ];
  then
	  printf "\tDIRECTORY $2 DOES NOT EXIST; ABORT 2\n"
	  return 2
  fi
  if [ -f $2/$LATEST_FILE ];
  then
	  printf "\tFILE $LATEST_FILE already exists\n"
	  return 3
  else
	  printf "\tFILE MGMT ON $LATEST_FILE\n"
	  # Probs dont want to copy 2GBs over routinely
	  #cp -a $2/* ~/.attic/
	  cp $1/$LATEST_FILE $2/
	  return 0
  fi
}
