pprint (){
  printf "############ ############ ############ ############ ############ ############\n"
  true
}

# bool function to test if the user is root or not (POSIX only)
is_user_root () { [ "$(id -u)" -eq 0 ]; }

# Install an application via homebrew
install_app ()
{
  if [ -d $1 ];
    then
      printf "\t$2 APP  exists\n"
    else
      printf "\tINSTALLING $2 APP\n"
      brew install --cask $2
  fi
}

# See if user needs to have proper connections to run script
needs_vpn_connection ()
{
  if [ ! -d "$APP_SONIC_WALL" ];
  then
    printf "ERROR: Need to install Sonic wall via app store\n"
    return 1
  fi

  # Retired option, but could be used later
  # curl --max-time 1 http://foo.com/ > /dev/null 2>&1;

  # Just check for internet connection
  wget -q --spider http://google.com

  IS_CONNECTED=$?
  if [ $IS_CONNECTED -ne 0 ];
  then
    printf "\nERROR $IS_CONNECTED: NOT CONNECTED TO vpn OR HQ wifi\n"
    return 1
  else
    return 0
  fi
}

make_dir ()
{
  if [ ! -d $1 ];
    then
      printf "\tMaking $1 directory\n"
      mkdir $1
		return 0
    else
      printf "\t$1 already exists\n"
		return 1
  fi
}

# Go through a confirmation process to accept/reject $1
# @param {string} $1 - Question to be read to user
# @param {string} $2 - Success message
# @param {string} $3 - Rejection message
# @return {int} 0 if confirming/accepting; Else 1
make_confirmation ()
{
    printf "$1 (Y/N): \n"
    read confirm
    case $confirm in
      [yY]*)
        printf "\t$2\n"
        return 0
      ;;
      [nN]*)
        printf "\t$3\n"
        return 1
        break
      ;;
      *)
        printf "\tBAD INPUT: Try again;\n"
        make_confirmation $1 $2 $3
    esac
}

# Install an oh-my-zsh theme powerlevel9k
force_powerlevel10k ()
{
  sed -i -e 's/ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
}

