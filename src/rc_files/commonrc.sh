#!/bin/bash

### Typos & short-hands
alias q='exit'
alias v='vim'
alias g='grep -ri '
alias sl='ls'
alias gim="vim"

### Most convenient aliases
alias c='clear && ls && echo -e "\n" && gs'
alias clint='clear && ls && echo -e "\n" && npm run lint && echo -e "\n" && gs'

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
alias profile-local="vim ~/.profile"
alias vrc-local="vim ~/.vimrc"
alias zrc-local="vim ~/.zshrc"
alias sbrc="source ~/install-scripts/src/rc_files/sources && source ~/.bashrc"
alias szrc="source ~/install-scripts/src/rc_files/sources && source ~/.zshrc"
alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias wanip4='dig @resolver4.opendns.com myip.opendns.com +short -4'
alias update-fork="git fetch upstream && git checkout master && git merge upstream/master"
alias get-devices="arp -a"
alias prompt-query="cp ~/install-scripts/templates/prompt-query-file.txt q.txt && vim q.txt"
alias prompt-test="cp ~/install-scripts/templates/prompt-test-error.txt error.txt && vim error.txt"
alias prompt-test-new="cp ~/install-scripts/templates/prompt-generate-test.txt test.txt && vim test.txt"
alias prompt-diff="cp ~/install-scripts/templates/prompt-diff.txt d.txt && vim d.txt"

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
alias dpsa='(echo "CONTAINER ID,IMAGE,COMMAND,STATUS,PORTS,NAMES" && docker ps -a --format "{{.ID}},{{.Image}},{{.Command}},{{.Status}},{{.Ports}},{{.Names}}")'
alias dockstop='docker stop $(docker ps -q)'
alias dockrm='docker rm $(docker ps -aq)'
alias dockkill='dockstop && dockrm'


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
function gvue () {
	# Skip over node_modules/ and .git/ + Follow sylinks on recursion;
	#grep --exclude-dir={node_modules,.git} -Ri "$1" ./src/
   grep --exclude-dir={node_modules,.git,coverage,public,logs,build,.attic,playwright-report} --exclude=diff --exclude=log --exclude=q.txt --exclude=package-lock.json -Ri "$1" .
	true
}

### Very Liberal Search for somethign that looks like what we want ###
function search () {
	find . -iname "*$1*"
	true
}

### Replace all spaces with underscores within parent
function strip_spaces () {
	find . -depth -name '* *' \
	| while IFS= read -r f ; do mv -i "$f" "$(dirname "$f")/$(basename "$f"|tr ' ' _)" ; done
}

function search_replace () {
	perl -i -pe 's/$1/$2/g' $3
}

### Execute an sqlite3 file on a given db
function sql3_exec () {
  # TODO: Ensure that $1 is a db
  # TODO: Ensure that $2 is a .sql file
  # TODO: Probably store a backup...
  # TODO: write a  --help flag
  sqlite3 $1 ".read $2"
  true
}

### Get the latest file by timestamp
# @param $1 - Target dir
function get_newest_in_dir ()
{
	RET="$(ls $1 | sort -n -t _ -k 2 | tail -1)"
	#printf "\t\t$RET\n\n"
	echo "$RET"
}

### Upgrade file if not match to newest file in target dir
# $1 target directory to either be saved or written over
# $2 target directory to parse against
function upgrade_file_on_no_match ()
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
#
# Log messages inside a function
function log_message() {
  local log_dir="$1"
  local log_prefix="$2"
  local message="$3"

  # Ensure the log directory exists
  mkdir -p "$log_dir"

  # Create a timestamped log file
  local timestamp=$(date +%Y%m%d%H%M%S)
  local log_file="${log_dir}/${log_prefix}_${timestamp}.log"

  # Write the message to the log file
  echo "$message" > "$log_file"
  echo "$log_file"  # Return the created log file path
}

# Garbage collection inside a function
function garbage_collect_logs() {
  local log_dir="$1"
  local max_files="$2"

  # Ensure the directory exists
  [ -d "$log_dir" ] || return

  # Count the number of files in the directory
  local file_count=$(ls "$log_dir" | wc -l)

  # If the number of files exceeds the limit, delete the oldest
  if (( file_count > max_files )); then
    ls -t "$log_dir" | tail -n +$((max_files + 1)) | xargs -I {} rm -f "$log_dir/{}"
  fi
}

function run_and_average_npm_test() {
  local num_runs=10
  local total_time=0
  local successful_runs=0

  echo "Starting $num_runs runs of 'npm run test' to calculate average time..."

  for i in $(seq 1 $num_runs); do
    echo "--- Run $i/$num_runs ---"
    # Use command grouping { ... } 2>&1 | ... to redirect both stdout and stderr of the timed command
    # and then grep for the 'total' time line.
    # The 'time' command's output is usually sent to stderr, so we redirect stderr to stdout.
    output=$( { time npm run test; } 2>&1 )
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
      # Extract the 'total' time. The format is 'X.YYYs total'.
      # We look for the line ending with 'total' and extract the number before it.
      total_duration=$(echo "$output" | grep 'total$' | awk '{print $(NF-1)}' | sed 's/s$//')

      if [[ -n "$total_duration" ]]; then
        # Convert to a common unit for summation (e.g., milliseconds for precision, or keep seconds and use bc)
        # Using bc for floating point arithmetic
        total_time=$(echo "$total_time + $total_duration" | bc)
        successful_runs=$((successful_runs + 1))
        echo "Run $i successful. Duration: ${total_duration}s"
      else
        echo "Warning: Could not extract total time from run $i. Output was:"
        echo "$output"
      fi
    else
      echo "Error: 'npm run test' failed on run $i with exit code $exit_code."
      echo "Output was:"
      echo "$output"
      echo "Aborting averaging process."
      return 1 # Indicate failure
    fi
  done

  if [ $successful_runs -gt 0 ]; then
    average_time=$(echo "scale=3; $total_time / $successful_runs" | bc)
    echo "-------------------------------------"
    echo "All $num_runs runs completed successfully."
    echo "Average 'npm run test' time over $successful_runs successful runs: ${average_time}s"
  else
    echo "No successful runs were completed. Cannot calculate average time."
    return 1
  fi
}

# @parm $1 {string} filepath - Path to a txt file that contains the whole prompt
# @retunrs {string} - The first ChatGPT reply from the Open AI route response
function chatgpt() {
  # Paths and configuration
  KEY_FILE="$HOME/.chatgpt-tanner/key.txt"
  DEBUG_DIR="$HOME/.chatgpt-tanner/debugs"
  MAX_DEBUG_FILES=100  # Maximum number of debug files to retain

  # Ensure the key file exists
  if [[ ! -f "$KEY_FILE" ]]; then
    echo "Error: API key file not found at $KEY_FILE"
    return 1
  fi

  # Read the API key from the key file
  OPENAI_KEY=$(<"$KEY_FILE")

  # Ensure the debug directory exists
  mkdir -p "$DEBUG_DIR"

  # Check if the input file exists
  FILEPATH="$1"
  if [[ ! -f "$FILEPATH" ]]; then
    echo "Error: File not found: $FILEPATH"
    return 1
  fi

  # Read the input file content
  QUESTION="$(<"$FILEPATH")"

  # Escape the content safely for JSON
  ESCAPED_QUESTION=$(node -e "const fs = require('fs'); const data = fs.readFileSync('$FILEPATH', 'utf-8'); console.log(JSON.stringify(data));")

  local fs="'fs'"
  local utf="'utf8'"
  local gpt="'gpt-4'"
  local user="'user'"
  local filepath="'$FILEPATH'"
  BAR="const fs = require($fs); const content = fs.readFileSync($filepath, $utf).trim().replace(/[\u0000-\u001F]/g, char => '\\\\u' + char.charCodeAt(0).toString(16).padStart(4, '0')); console.log(JSON.stringify({ model: $gpt, messages: [{ role: $user, content }] }));"

  JSON_PAYLOAD=$(node -e "$BAR")

  echo "$BAR" > out.txt
  echo "$JSON_PAYLOAD" > out.json

  # Validate the JSON payload
  if ! echo "$JSON_PAYLOAD" | yq eval '.' - > /dev/null 2>&1; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    echo "Error: Invalid JSON payload. Check your input file for problematic content."
    echo "$JSON_PAYLOAD" > "$DEBUG_DIR/debug_invalid_payload_${TIMESTAMP}.json"
    garbage_collect_logs "$DEBUG_DIR" "$MAX_DEBUG_FILES"
    return 1
  fi

  # Save the valid payload for inspection
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  echo "$JSON_PAYLOAD" > "$DEBUG_DIR/debug_valid_payload_${TIMESTAMP}.json"

  # Send the content to the OpenAI API and preprocess the response
  RAW_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_KEY" \
    -d "$JSON_PAYLOAD")

  echo "$RAW_RESPONSE" > response.txt

  # Save the raw response
  echo "$RAW_RESPONSE" > "$DEBUG_DIR/debug_response_${TIMESTAMP}.json"

  # Extract the "content" field using yq
  MESSAGE_CONTENT=$(echo "$RAW_RESPONSE" | yq eval '.choices[0].message.content' -)

  # Handle empty content
  if [[ -z "$MESSAGE_CONTENT" ]]; then
    echo "Error: API returned an empty response."
    echo "$RAW_RESPONSE" > "$DEBUG_DIR/debug_empty_response_${TIMESTAMP}.json"
    garbage_collect_logs "$DEBUG_DIR" "$MAX_DEBUG_FILES"
    return 1
  fi

  # Output the message content
  echo "$MESSAGE_CONTENT"

  # Perform garbage collection on the debug directory
  garbage_collect_logs "$DEBUG_DIR" "$MAX_DEBUG_FILES"
}

terraform -install-autocomplete
