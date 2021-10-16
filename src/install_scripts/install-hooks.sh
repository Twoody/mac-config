WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

download_hooks ()
{
  source $CONSTANTS_FILE
  source $UTILS

  #### Githook function for papi
  if [ ! -f /usr/local/bin/composer-post-checkout ];
  	then
  		printf "\t\tInstalling git hook script to validate \`composer.lock\`\n"
		# TODO: Copy over local file
  		chmod +x /usr/local/bin/composer-post-checkout
  	else
  		printf "\t\tGit hook script \`composer-post-checkout\` already installed\n"
  fi
  #### Githook function for node projects
  if [ ! -f /usr/local/bin/node-modules-post-checkout ];
  	then
  		printf "\t\tInstalling git hook script to validate \`package-lock.json\`\n"
		# TODO: Copy over local file
  		chmod +x /usr/local/bin/node-modules-post-checkout
  	else
  		printf "\t\tGit hook script \`node-modules-post-checkout\` already installed\n"
  fi
}

# @param {path} $1 - Path to check hook on
# @param {path} $2 - Description of project (e.g. PAPI)
# @example $pp/grandpapi
validate_hook ()
{
  HOOK=.git/hooks/post-checkout
  TARGET=$1/$2
  #### Validate that git hook post-checkout exists for papi...
  if [ -f $1/.git/hooks/post-checkout ] ;
  	then
  		printf "$2: $HOOK already exists\n"
		return 1
  	else
  		printf "$2: $HOOK  DOES NOT exist\n"
  		touch $TARGET
  		chmod +x $TARGET
  		echo "#!/bin/sh" >> $TARGET
		return 0
  fi
}

#### Validate that git hook post-checkout references composer-post-checkout...
validate_composer ()
{
  TARGET=$1/.git/hooks/post-checkout
  if grep -q "^sh /usr/local/bin/composer-post-checkout" $TARGET
  	then
  		printf "\t$2: composer-post-checkout already being wrapped in .git/hooks/post-checkout\n"
		return 1
  	else
  		printf "\t$2: composer-post-checkout being updated to use local sh file\n"
  		echo "sh /usr/local/bin/composer-post-checkout" >> $TARGET
		return 0
  fi
}

#### Install githook function for planner app
validate_npm ()
{
  TARGET=$1/.git/hooks/post-checkout ;
  if grep -q "^sh /usr/local/bin/node-modules-post-checkout" $TARGET
  	then
  		printf "\t$2: node-modules-post-checkout already being wrapped in .git/hooks/post-checkout\n"
		return 1
  	else
  		printf "\t$2: node-modules-post-checkout being put in post-checkout git hook \n"
  		echo "sh /usr/local/bin/node-modules-post-checkout" >> $TARGET
		return 0
  fi
}

install_hooks ()
{
  source $CONSTANTS_FILE
  source $UTILS

  validate_hook $PAPI "PAPI"
  validate_hook $PLANNER_APP "PlannerApp"
  validate_hook $PWA "PWA"

  validate_composer $PAPI "PAPI"
  validate_npm $PLANNER_APP "Planner App"
  validate_npm $PWA "PWA"

  download_hooks
}

# download_hooks
# install_hooks
