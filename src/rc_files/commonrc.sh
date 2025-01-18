#!/bin/bash

### Typos & short-hands
alias q='exit'
alias v='vim'
alias g='grep -ri '
alias sl='ls'
alias gim="vim"

### Most convenient aliases
alias c='clear && ls && echo -e "\n" && gs'

alias findy='find . -iname'
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
alias commonrc="vim ~/install-scripts/src/rc_files/commonrc.sh"
alias gitrc="vim ~/install-scripts/src/rc_files/gitrc.sh"
alias brc="vim ~/install-scripts/src/rc_files/.bashrc"
alias vrc="vim ~/install-scripts/src/rc_files/.vimrc"
alias zrc="vim ~/install-scripts/src/rc_files/.zshrc"
alias brc-local="vim ~/.bashrc"
alias vrc-local="vim ~/.vimrc"
alias zrc-local="vim ~/.zshrc"
alias sbrc="source ~/install-scripts/src/rc_files/sources && source ~/.bashrc"
alias szrc="source ~/install-scripts/src/rc_files/sources && source ~/.zshrc"
alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias wanip4='dig @resolver4.opendns.com myip.opendns.com +short -4'
alias update-fork="git fetch upstream && git checkout master && git merge upstream/master"
alias get-devices="arp -a"

# Get weather locally
alias get-weather="curl wttr.in"

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
alias dockpatch="docker-compose pull && docker-compose build --pull"
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
	find . -iname "*$1*"
	true
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

# @parm $1 {string} filepath - Path to a txt file that contains the whole prompt
# @retunrs {string} - The first ChatGPT reply from the Open AI route response
# @todo Move over to `install scripts` so it is version controlled;
# @todo Read the `key` from env or hidden file in the home directory
function chatgpt() {
  OPENAI_KEY="todo: get from working home directory"
  OPENAI_MODEL="gpt-4"
  FILEPATH="$1"

  # Check if the file exists
  if [[ ! -f "$FILEPATH" ]]; then
    echo "Error: File not found: $FILEPATH"
    return 1
  fi

  # Read the file content
  QUESTION="$(<"$FILEPATH")"

  # Sanitize slashes, quotes, and newlines
  QUESTION=$(echo "$QUESTION" | 
  awk 'BEGIN { ORS="" } {
      gsub(/\\/, "\\\\");  # Escape backslashes
      gsub(/"/, "\\\"");  # Escape double quotes
      gsub(/\n/, "\\n");  # Convert newlines to \n
      gsub(/\"\"\"/, "\\\"\\\"\\\"");  # Escape triple quotes explicitly
      print
    }'
  )

  # Build the JSON payload
  JSON_PAYLOAD=$(cat <<EOF
{
  "model": "$OPENAI_MODEL",
  "messages": [{"role": "user", "content": "$QUESTION"}]
}
EOF
)

  # Validate the JSON payload
  if ! echo "$JSON_PAYLOAD" | jq . > /dev/null 2>&1; then
    echo "Error: Invalid JSON payload. Check your input file for problematic content."
    echo "$JSON_PAYLOAD" > debug_invalid_payload.json
    return 1
  fi

  # Debugging step: Save the valid payload for inspection
  echo "$JSON_PAYLOAD" > debug_valid_payload.json

  # Send the content to the OpenAI API and preprocess the response
  RAW_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_KEY" \
    -d "$JSON_PAYLOAD")

  # Clean the raw response to remove invalid characters
  CLEAN_RESPONSE=$(echo "$RAW_RESPONSE" | tr -d '\000-\037')

  # Validate and parse the cleaned response
  if echo "$CLEAN_RESPONSE" | jq -e . >/dev/null 2>&1; then
    # Extract content from the response
    MESSAGE_CONTENT=$(echo "$CLEAN_RESPONSE" | jq -r '.choices[0].message.content')

    # Handle empty content
    if [[ -z "$MESSAGE_CONTENT" ]]; then
      echo "Error: API returned an empty response."
      echo "$CLEAN_RESPONSE" > debug_response.json
      return 1
    fi

    echo "$MESSAGE_CONTENT"
  else
    echo "Error: Invalid API response. Check debug_response.json for details."
    echo "$CLEAN_RESPONSE" > debug_response.json
    return 1
  fi
}
