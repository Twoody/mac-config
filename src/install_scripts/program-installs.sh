### Install all of the languages and shell dependencies
### Resources:
#### https://stackoverflow.com/questions/3987683/homebrew-install-specific-version-of-formula

install_brew ()
{
  # Package Manager of Choice
  if brew --version > /dev/null 2>&1;
    then
      printf "\tbrew already installed\n"
    else
      printf "\tINSTALLING HOMEBREW\n"
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      printf "\tINSTALLED HOMEBREW\n"
  fi
}

# Executables Setup
# @param $1 - Casket/tap/formula to install
# @param $2 - Program name
# @param $3 - Version to install
install_prog_brew ()
{
  printf "\tTRYING $1\n"
  if $2 --version > /dev/null 2>&1 ;
    then
      printf "\t\t$1 exists\n"
      return 1
    elif $2 -v > /dev/null 2>&1 ;
    then
      printf "\t\t$1 exists\n"
      return 1
    elif $2 -V > /dev/null 2>&1 ;
    then
      printf "\t\t$1 exists\n"
      return 1
    elif [ ! -z "$3" ] > /dev/null 2>&1 ;
    then
      printf "\t\tINSTALLING $1 at version $2\n"
      brew install $1@$3
      return 0
    else
      printf "\t\tINSTALLING $1\n"
      brew install $1
      return 0
  fi
}

install_programs ()
{
  printf "BEGINNING INSTALLATION OF PROGRAMS\n"
  install_brew
  # TODO: PHP version
  install_prog_brew php php
  install_prog_brew python3 python3

  # Docker wants to be linked up; Nothing else seems to complain
  if install_prog_brew docker docker;
    then
      brew link docker
      install_prog_brew docker-compose docker-composee
    else
      printf "\t\tnot linking docker\n"
      printf "\t\tnot installing docker-compose\n"
  fi

  install_prog_brew npm npm
  install_prog_brew vue-cli vue
  npm i -g ttab
}

#install_programs
