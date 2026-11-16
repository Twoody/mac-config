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

# Link a repo plist into ~/Library/LaunchAgents and (re)load it.
# @param {path} $1 - Source plist inside the repo (absolute)
# @param {string} $2 - launchd label (also the plist's basename)
install_launch_agent ()
{
  source $CONSTANTS_FILE
  link_launch_agent $1 $LAUNCH_AGENTS/$2.plist

  # Reload so an updated plist takes effect; unload is expected to fail on first run.
  launchctl unload $LAUNCH_AGENTS/$2.plist 2>/dev/null
  if launchctl load $LAUNCH_AGENTS/$2.plist 2>/dev/null;
    then
      printf "\t$2 loaded\n"
    else
      printf "\tFAILED to load $2\n"
      return 1
  fi
  return 0
}

# Idempotent: install two launchd jobs.
# - Hourly disk guard: only NOTIFIES, never deletes. Warns when free space is low or a
#   watched log dir has run away. Context: a runaway third-party log writer filled this disk
#   to 99% and took Docker Desktop down with it (the engine crash-loops when its VM cannot
#   write). The guard turns that from a multi-hour investigation into a notification.
# - Weekly disk cleanup: DELETES stale Chrome code_sign_clone dirs and prunes Docker
#   (never volumes). See bin/disk-cleanup.sh.
setup_diskguard ()
{
  source $CONSTANTS_FILE
  printf "SETTING UP disk guard + weekly cleanup\n"

  mkdir -p $LAUNCH_AGENTS
  chmod +x $DISKGUARD_SCRIPT $DISKCLEANUP_SCRIPT

  install_launch_agent $DISKGUARD_PLIST $DISKGUARD_LABEL || return 1
  install_launch_agent $DISKCLEANUP_PLIST $DISKCLEANUP_LABEL || return 1
  return 0
}

# setup_diskguard
