WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

# TODO: Probably validate directories
install_git_bin ()
{
  source $CONSTANTS_FILE
  source $UTILS

  # Params
  TARGET_DIR=$1
  TARGET_BRANCH=$2
  TARGET_NAME=$3
  TARGET_URL=$4

  # Config and local
  PREV_DIR=$PWD
  IS_SETTING_UP=0
  DOES_EXIST=1

  if [ ! -d $TARGET_DIR  ];
    then
      printf "\t$3 NOT FOUND: Cloning repo; Changing branch\n"
    else

      make_confirmation \
		  "Overwrite and update $3 ($1)?  "\
        "Overwriting $1"\
        "Maintaining original $3"
      IS_SETTING_UP=$?
      DOES_EXIST=0
  fi

  if [ $IS_SETTING_UP -eq 0 ];
    then
  	   cd $1
		# Remove directory if user confirmed rewrite
		if [ $DOES_EXIST -eq 0 ]; then
        printf "\tDELETING\n\t\t$1/$3\n"
        rm -rf $TARGET_DIR/$TARGET_NAME
      fi
  	   git clone $4
		# TODO: Confirm target name and created repo match...
  	   cd $TARGET_NAME
  	   git checkout $2
		cd $PREV_DIR
      printf "\tCREATED $3\n"
  fi
}

setup_arcanist ()
{
  # TARGET_DIR=$1
  # TARGET_BRANCH=$2
  # TARGET_NAME=$3
  # TODO: Basically isntall phabricator git repo too
  install_git_bin \
			 /usr/local/bin \
			 stable \
			 arcanist \
			 https://github.com/phacility/arcanist.git

  install_git_bin \
			 /usr/local/bin \
			 stable \
			 libphutil \
			 https://github.com/phacility/libphutil.git

  install_git_bin \
			 /usr/local/bin \
			 stable \
			 phabricator \
			 https://github.com/phacility/phabricator.git

  # TODO: Check for .arcconfig file before running?
  arc install-certificate
}

#setup_arcanist
