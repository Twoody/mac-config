WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

# Symlink one repo file into ~/.claude, backing up any real file first
# @param {path} $1 - Source file inside the repo (absolute)
# @param {path} $2 - Target path under ~/.claude
link_claude_file ()
{
  source $CONSTANTS_FILE
  NAME=$(basename $2)

  if [ -L $2 ] && [ "$(readlink $2)" = "$1" ];
    then
      printf "\t$NAME already linked\n"
      return 0
  fi

  mkdir -p $ATTIC
  if [ -e $2 ] || [ -L $2 ];
    then
      BACKUP=$ATTIC/claude-backup-$NAME.$(date +%Y%m%d%H%M%S)
      printf "\tBacking up existing $NAME to $BACKUP\n"
      mv $2 $BACKUP
  fi

  printf "\tLinking $2 -> $1\n"
  ln -s $1 $2
  return 0
}

# Idempotent: symlink canonical Claude config from the repo into ~/.claude.
# Editing ~/.claude/CLAUDE.md (etc.) edits the repo through the symlink;
# commit + push here, `git pull` on other machines to sync.
setup_claude ()
{
  source $CONSTANTS_FILE
  printf "SETTING UP claude CONFIG\n"

  # commands dir stays a REAL dir so machine-local commands coexist
  mkdir -p ~/.claude/commands

  link_claude_file $CLAUDE_DIR/CLAUDE.md ~/.claude/CLAUDE.md

  for f in $CLAUDE_DIR/commands/*.md;
  do
    link_claude_file $f ~/.claude/commands/$(basename $f)
  done

  # First-run bootstrap only; settings accumulate machine-local state
  if [ ! -e ~/.claude/settings.json ];
    then
      printf "\tInstalling settings.json from template\n"
      cp $WORKING_DIR/templates/claude-settings.json ~/.claude/settings.json
    else
      printf "\tsettings.json exists: leaving untouched\n"
  fi
}

# setup_claude
