# echo "loading nsh()"
nanosh () {
  mkdir ~/repos/dotfiles/env/$(approot)
  if [ -z "$1" ]
  then
    nano ~/repos/dotfiles/zsh/config.d/core.zsh
  else
    nano ~/repos/dotfiles/zsh/config.d/$1.zsh
  fi
}
alias nsh="nanosh"

nanossh () {
  nano ~/repos/dotfiles/ssh/config
}

mate () { # ubuntu mate panel reset
  sudo mate-panel --replace &
}

bru () {
  brew update
  brew upgrade
}

jump () {
  repos
  $1
}

ngrok () {
  ~/ngrok http 3000
}

nshrb () {
  nano ~/.irbrc
}

mkdirenv () {
  mkdir ~/repos/dotfiles/env/$(basename $PWD)
}

nanoenv () {
  nano ~/repos/dotfiles/env/$(basename $PWD)/.env.$1
}

lala () {
  ls -la $1
}

# echo "loading sauce()"
sauce () {
  zshlns
#  envlns
  rblns
  jslns
}

echo "loading zshlns()"
zshlns () {
#  echo "refreshing .zshrc..."
  rm ~/.zshrc
  ln -s ~/repos/dotfiles/zsh/.zshrc ~
  source ~/.zshrc
 # echo "refreshing ssh config..."
  rm ~/.ssh/config
  ln -s ~/repos/dotfiles/ssh/config ~/.ssh/config
}

envlns () {
   if  ! [ -d ~/repos/dotfiles/env/$(approot) ]
  then
  #  echo "Making project directory with new envs..."	
    mkdir ~/repos/dotfiles/env/$(approot)
    if [ -f ./.env.development ]
    then
      cp ./.env* ~/repos/dotfiles/$(approot)/
    fi
  fi

  if [ -f ~/repos/dotfiles/env/$(approot)/.env.development ]
  then
   # echo ".env.development found! refreshing..."
    rm .env.development
    ln -s ~/repos/dotfiles/env/$(approot)/.env.development $(pwd)/.env.development
  fi

  if [ -f ~/repos/dotfiles/env/$(approot)/.env.staging ]
  then
   # echo ".env.staging found! refreshing..."
    rm .env.staging
    ln -s ~/repos/dotfiles/env/$(approot)/.env.staging $(pwd)/.env.staging
  fi
  if [ -f ~/repos/dotfiles/env/$(approot)/.env.production ]
  then
   # echo ".env.production found! refreshing..."
    rm .env.production
    ln -s ~/repos/dotfiles/env/$(approot)/.env.production $(pwd)/.env.production
  fi
}

rblns () {
  if [ -f ./.ruby-version ]
  then
   # echo "ruby version found. reloading"
    rbenv local $(cat .ruby-version)
  fi
}

jslns () {
  if [ -f ./.nvmrc  ]
  then
    nvm use
  fi
}

# echo "loading catrc()"
catrc () {
  dir=`pwd`
  cd ~/repos/dotfiles/zsh/config.d
  for conf in *.zsh; do
    # echo "searching ${conf}"
    cat "${conf}" | grep $1
  done
  cd $dir
}

# echo "loading dots()"
dots () {
  ~/repos/dotfiles
}

# echo "loading kaboom()"
nuke () {
  git checkout .
}

approot () {
  basename "$PWD"
}

getrb () {
  rbenv install $(cat .ruby-version)
}


#rbenv () {
#	local command
#	command="${1:-}"
#	if [ "$#" -gt 0 ]
#	then
#		shift
#	fi
#	case "$command" in
#		(rehash | shell) eval "$(rbenv "sh-$command" "$@")" ;;
#		(*) command rbenv "$command" "$@" ;;
#	esac
#}
