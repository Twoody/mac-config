######
## Author: Tanner.L.Woody@gmail.com
## Date: 2021-10-03
## Purpose:
### Isolate all of the common git commands aliases to share between different shells
######
alias ga="git add"
alias gs='git status'
alias gb='git branch' 
alias gd='git diff' 
alias gc='git commit' 
alias gcm='git commit -message ' 
alias gl='git log --stat' 
alias gm='git merge' 
alias gp='git pull' 
#alias gch='git checkout' 
alias gchl='git checkout @{-1}' 
alias gitreset='git reset --hard head' 

### Get the changes done by a Git commit ##
gdc () {
  git diff $1~ $1
  true
}

# Delete all branches matching the parameter
# @param $1 - pattern to match
gdel () {
   WORKING_DIR=~/install-scripts
   CONSTANTS_FILE=$WORKING_DIR/src/constants.sh
   source $CONSTANTS_FILE
   source $UTILS
   if [ $# -eq 0 ] ;
   then
      echo "No argument supplied"
      return 1
   fi
   #command git branch -D $matches

   branches=()
   eval "$(git for-each-ref --shell --format='branches+=(%(refname))' refs/heads/)"
   for branch in "${branches[@]}"; do
      mb=$(echo $branch | cut -d '/' -f 3)
      mb2=$(echo $branch | cut -d '/' -f 4)

      if [ ! -z $mb2 ]
      then
         mb=$mb/$mb2
      fi

      if [[ $mb == 'stage' ]] ;
      then
         continue
      fi
      if [[ $mb == *$1* ]];
      then
         make_confirmation \
           "PERMANENTLY DELETE BRANCH $mb?"\
           "DELETING $mb\n"\
           "SKIPPING $mb\n"
         CONFIRMED=$?
         if [ $CONFIRMED -eq 0 ];
         then
           git branch -D $mb
           echo "\n"
         fi
      fi
   done
   return 0
}

# Checkout a branch but easy
# @param $1 - pattern to match
gch () {
   WORKING_DIR=~/install-scripts
   CONSTANTS_FILE=$WORKING_DIR/src/constants.sh
   source $CONSTANTS_FILE
   source $UTILS
   #TODO: Write a force flag to skip over while loop and reads
   if [ $# -eq 0 ] ;
   then
      echo "No argument supplied"
      return 1
   fi

   branches=()
   eval "$(git for-each-ref --shell --format='branches+=(%(refname))' refs/heads/)"

   if [ ${#branches[@]} -eq 0 ] ;
   then
      printf "No branches matching '$1'\n"
      return 1
   fi

   for branch in "${branches[@]}"; do
      mb=$(echo $branch | cut -d '/' -f 3)
      mb2=$(echo $branch | cut -d '/' -f 4)

      if [ ! -z $mb2 ]
      then
         mb=$mb/$mb2
      fi

      if [[ $mb == *$1* ]];
      then
         make_confirmation \
           "Switch to branch $mb?"\
           "Checking out $mb\n"\
           "SKIPPING $mb\n"
         CONFIRMED=$?
         if [ $CONFIRMED -eq 0 ];
         then
           git checkout $mb
           break
         fi
      fi
   done
   return 0
}

git-reset () {
   git reset --hard head
}
