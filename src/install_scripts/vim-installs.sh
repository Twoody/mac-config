# Terminal Config
WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

install_bash ()
{
  source $CONSTANTS_FILE
  if [ ! -f ~/.bashrc ];
    then
      printf "\tWriting over ~/.bashrc from $RC_DIR\n"
    	cp $RC_DIR/.bashrc ~/
  	   source ~/.bashrc
    else
      printf "\t~/.bashrc already exists\n"
  fi

  if [ ! -f ~/.bash_profile ];
    then
      printf "\tWriting over ~/.bash_profile from gist.github.com/twoody/\n"
      # git clone https://gist.github.com/4cff66d92ca89324cdfb5858540c4296.git $td
      curl http://phabricator.preliant.local/file/data/mjke7yo6nf75bkwmjwbk/PHID-FILE-ceua46rgzzwqte6joawk/.bash_profile > $td/.bash_profile
  	   mv $td/.bash_profile ~/
  	   rm -rf $td
      printf "\tWrote over ~/.bash_profile from gist.github.com/twoody/\n"
    else
      printf "\t~/.bash_profile already exists\n"
  fi
}

install_vim ()
{
  source $CONSTANTS_FILE
  if [ ! -d ~/.vim/ ];
    then
      printf "\tMaking a ~/.vim/ directory\n"
      mkdir ~/.vim/
    else
      printf "\t.vim already exists\n"
  fi
  
  if [ ! -d ~/.vim/bundle ];
    then
      printf "\tMaking a ~/.vim/bundle/ directory\n"
      mkdir ~/.vim/bundle/
    else
      printf "\t.vim/bundle already exists\n"
  fi
  
  if [ ! -d ~/.vim/bundle/Vundle.vim/ ];
    then
      printf "\tMaking a ~/.vim/bundle/VundleVim directory\n"
  	 git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    else
      printf "\t.vim/bundle/Vundle.vim already exists\n"
  fi
  
  if [ ! -d ~/.vim/bundle/vim-vue/ ];
    then
      printf "\tMaking a ~/.vim/bundle/vim-vue directory\n"
      git clone https://github.com/posva/vim-vue.git ~/.vim/bundle/vim-vue
    else
      printf "\t.vim/bundle/vim-vue already exists\n"
  fi
  
  if [ ! -f ~/.vimrc ];
    then
      # Phabricator paste currently does not accept vimscript files;
      # Going to just pull from `gist` until up and running.
      printf "\tWriting over ~/.vimrc from local $WORKING_DIR\n"
		cp $RC_DIR/.vimrc ~/.vimrc
    else
      printf "\t~/.vimrc already exists\n"
  fi
}

setup_zsh ()
{
  source $CONSTANTS_FILE
  source $UTILS

  if [ ! -d $OH_MY_ZSH ];
  then
    # Install oh-my-zsh
    printf "\tRunning install script from robbyrussel for oh-my-zsh\n"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    printf "\t\tContinuing zsh setup\n"
  else
    printf "\tOh-my-zsh already installed: Continuing zsh setup\n"
  fi
  # Install a better theme
  if [ ! -d $POWERLEVEL10K ];
  then 
	 git clone --depth=1 \
		 https://github.com/romkatv/powerlevel10k.git \
		 ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # Append theme to file if DNE
    force_powerlevel10k
  else
    make_confirmation \
      "ZSH theme already installed: Overwrite configuration to use powerlevel10k?"\
      "Overwriting ZSH_THEME:"\
      "Maintaining current ZSH_THEME"
    CONFIRMED=$?
    if [ $CONFIRMED -eq 0 ];
    then
      force_powerlevel10k
    fi
  fi

  if [ ! -d $ZSH_SYNTAX_HIGHLIGHTER ];
  then 
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGHTER
    printf "\t\tSyntax hihglighter now setup\n"
  else
    printf "\t\tSyntax hihglighter for the shell already exists\n"
  fi

  if [ ! -f ~/.zshrc ];
    then
      printf "\tWriting over ~/.zshrc from $RC_DIR\n"
    	cp $RC_DIR/.zshrc ~/
  	   source ~/.zshrc
    else
      printf "\t~/.zshrc already exists\n"
  fi

  printf "\tSee following link for common missing ascii characters:\n"
  printf "\t\thttps://apple.stackexchange.com/questions/368603/how-to-make-powerline-fonts-work-with-iterm2\n"
}

setup_git_config ()
{
  source $CONSTANTS_FILE
  source $UTILS
  make_confirmation \
			 "Set Terminal config for git?"\
			 "Overwriting Git Config:"\
			 "Maintaining current/default git config"
  CONFIRMED=$?
  if [ $CONFIRMED -eq 0 ];
  then
    git config --global core.pager 'less -x1,3'
  fi
}

#install_bash
setup_zsh
#install_vim
#setup_git_config
