WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

# Check to see if working directory setup right
has_general_setup ()
{
  if [ ! -d $WORKING_DIR ];
    then
      printf "\nERROR: $WORKING_DIR not found: Aborting script"
      return 1
  fi
  
  if [ ! -f $CONSTANTS_FILE ];
    then
      printf "ERROR: $CONSTANTS_FILE not found: Aborting script"
      return 1
  fi

  source $CONSTANTS_FILE
  source $UTILS

  printf "CHECKING vpn AND wifi  CONNECTION...\n"
  needs_vpn_connection
  NEEDS_VPN=$?
  if [ $NEEDS_VPN -ne 0 ];
  then
    printf "ERROR: Please connect to the vpn or wifi\n"
    return 1
  fi
  printf "\tConnection okay\n"

  return 0
}

is_setup ()
{
  if has_general_setup;
    then
      source $CONSTANTS_FILE
      if [ -d $td ];
        then
          printf "ERROR: $td MUST NOT BE A DIRECTORY...\n"
          return 1
        else
          printf "\tAll setup goog to go\n"
          return 0
      fi
  fi
  return 1
}

# TODO: wrap in its own method to take a dir/file
# TODO: Make sure the file/dir exists before chown'ing
manage_owners ()
{
  sudo chown -R $(whoami) /usr/local/Homebrew
  sudo chown -R $(whoami) /usr/local/etc/bash_completion.d
  sudo chown -R $(whoami) /usr/local/share/doc
  sudo chown -R $(whoami) /usr/local/share/man
  sudo chown -R $(whoami) /usr/local/share/zsh
  sudo chown -R $(whoami) /usr/local/var/homebrew/locks
  sudo chown -R $(whoami) /usr/local/share/fish/vendor_completions.d
}

# STRONGLY suggest a few apps that cannot be brew installed are installed
# Microsoft remote desktop
extracurriculars ()
{
  if [ ! -d /Applications/Microsoft\ remote\ destop ];
  then
    printf "WARNING: PLEASE INSTALL microsoft remote desktop"
  fi
}

# Remove all of the garbage from the dock
clean_dock ()
{
  source $CONSTANTS_FILE

  # TODO: Wrap in a confirmation
  cp -a $DOCK_LIST $ATTIC/dock_preference_list
  defaults delete com.apple.dock persistent-apps; killall Dock
}

make_dirs ()
{
  source $CONSTANTS_FILE
  source $UTILS

  make_dir $ATTIC
  make_dir $PATTIC
  make_dir $WORKSPACE
  make_dir $PWORKSPACE
}

# clean_dock
# manage_owners
# make_dirs
# is_setup
