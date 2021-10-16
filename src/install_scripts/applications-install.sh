WORKING_DIR=~/install-scripts/src
CONSTANTS_FILE=$WORKING_DIR/constants.sh

# @dependent TODO
install_applications ()
{
  source $CONSTANTS_FILE
  source $UTILS

  install_app $APP_SLACK slack
  install_app $APP_ZOOM zoomus
  install_app $APP_SPOTIFY spotify
  install_app $APP_ITERM2 iterm2

  if subl -v > /dev/null 2>&1 ;
    then
      printf "\tsublime exists\n"
    else
      printf "\tINSTALLING sublime\n"
      brew install --cask sublime-text
      printf "\tINSTALLED sublime\n"
  fi
}
