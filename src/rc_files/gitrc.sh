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
alias gch='git checkout' 
alias gitreset='git reset --hard head' 

### Get the changes done by a Git commit ##
gdc () {
  git diff $1~ $1
  true
}

# Delete all branches matching the parameter
# @param $1 - pattern to match
gdel () {
   #TODO: Write a help flag
   #TODO: Write a force flag to skip over while loop and reads
   #TODO: git checkout stage; If previous branch not deleted, recheckout previous branch;
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
      if [[ $mb == 'stage' ]] ;
      then
         continue
      fi
      if [[ $mb == *$1* ]];
      then
         while true; do
         read -p "PERMANENTLY DELETE BRANCH $mb? (Y/N): " confirm
            case $confirm in
               [yY]*)
                  printf "\tDELETING: $mb\n"
                  git branch -D $mb
                  break
                  ;;
            [nN]*)
               printf "\tSKIPPING: $mb\n"
               break
               ;;
            *)
               printf "\tBAD INPUT\n"
            esac
         done
      fi
   done
   return 0
}

git-reset () {
	git reset --hard head
}
