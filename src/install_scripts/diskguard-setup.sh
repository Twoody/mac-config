WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

# Symlink a LaunchAgent plist from the repo into ~/Library/LaunchAgents,
# backing up any real file already there.
# @param {path} $1 - Source plist inside the repo (absolute)
# @param {path} $2 - Target path under ~/Library/LaunchAgents
link_launch_agent ()
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
      BACKUP=$ATTIC/launchagent-backup-$NAME.$(date +%Y%m%d%H%M%S)
      printf "\tBacking up existing $NAME to $BACKUP\n"
      mv $2 $BACKUP
  fi

  printf "\tLinking $2 -> $1\n"
  ln -s $1 $2
  return 0
}

# Idempotent: install the hourly disk guard. It only NOTIFIES - it never deletes -
# warning when free space is low or a watched log dir has run away.
#
# Context: a runaway third-party log writer filled this disk to 99% and took Docker
# Desktop down with it (the engine crash-loops when its VM cannot write). The guard
# turns that from a multi-hour investigation into a notification.
setup_diskguard ()
{
  source $CONSTANTS_FILE
  printf "SETTING UP disk guard\n"

  mkdir -p $LAUNCH_AGENTS
  chmod +x $DISKGUARD_SCRIPT

  link_launch_agent $DISKGUARD_PLIST $LAUNCH_AGENTS/$DISKGUARD_LABEL.plist

  # Reload so an updated plist takes effect; unload is expected to fail on first run.
  launchctl unload $LAUNCH_AGENTS/$DISKGUARD_LABEL.plist 2>/dev/null
  if launchctl load $LAUNCH_AGENTS/$DISKGUARD_LABEL.plist 2>/dev/null;
    then
      printf "\t$DISKGUARD_LABEL loaded (runs hourly)\n"
    else
      printf "\tFAILED to load $DISKGUARD_LABEL\n"
      return 1
  fi
  return 0
}

# setup_diskguard
