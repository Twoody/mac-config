#!/bin/sh
#***************************************************************************#
#***************************************************************************#
#                            FIRST DAY INSTALLS                             #
#***************************************************************************#
#***************************************************************************#
#                                                                           #
# Author: Tanner Woody                                                      #
# Date: 2019-10-01                                                          #
# Last Update: 2021-10-02                                                   #
#                                                                           #
#***************************************************************************#
WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

source $CONSTANTS_FILE
source $SETUP

### Ensure directory files setup right; If not, bail and do not mess up someone elses files
if ! is_setup;
  then
    printf "\nENDING SCRIPT: PLEASE RUN AFTER ERRORS RESOLVED\n"
    exit 1
  else
    printf "INITIAL FILE CHECK PASSED\n"
    printf "Changing owners for a bunch of stuff\n"
    printf "Continuing with Installation\n"
fi

source $CONSTANTS_FILE
source $UTILS
source $VIM_INSTALL
source $PRECOA_INSTALL
source $PROGRAMS_INSTALL
source $APPLICATIONS_INSTALL

make_confirmation \
  "Cleanup the bottom dock bar?"\
  "Cleaning dock"\
  "Maintaining current dock"
CONFIRMED=$?
if [ $CONFIRMED -eq 0 ];
then
  clean_dock
fi
manage_owners
make_dirs

is_setup
IS_SETUP=$?
if [ $IS_SETUP -eq 0 ];
then
  printf "\nRESUMING first-day-install PROCESS\n"
  install_bash
  setup_zsh
  install_vim
  # Install docker first to see if we can still install some CLI commands
  # Might need some `brew link --overwrite docker` too
  install_app $APP_DOCKER docker
  install_programs
  install_applications

  # Precoa specific
  setup_hosts
  setup_projects
  setup_dependencies
  setup_arcanist
else
  printf "\nENDING first-day-install CAUSE NOT PROPERLY SETUP\n"
fi

#### TODOS
# Make sure we write a general .profile, check POSIX ensurability, and create a .zshrc and .bashrc file both pointing and sourcing from .profile
## https://stackoverflow.com/questions/764600/how-can-you-export-your-bashrc-to-zshrc
# Support node, php, vue-cal, and other versions in constants.sh
# If version number exists, confirm-read if user wants to install applications, one at a time
## Maybe a force option in confirm-read to bypass this
# Write a version number in a .log file if success
## Do not run script if version number exists and is same
