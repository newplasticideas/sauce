jot () {
  if ! [ -s "$1" ]
  then
    nano ~/jots/notes_$1_$(date +%s).txt
  else
    nano ~/jots/notes_$(date +%s).txt
  fi
}


# echo "loading nuke()"
drop () {
  rake db:drop db:create db:migrate db:seed
}

# echo "loading gcdev()"
gcdev () {
  git checkout develop
}

# echo "loading kiq()"
kiqdev () {
  dotenv -f ".env.development" bundle exec sidekiq -C ./config/sidekiq.yml
}
alias kiq="kiqdev"

kiqloc () {
  dotenv -f ".env.local" bundle exec sidekiq -C ./config/sidekiq.yml 
}

# echo "loading kiq2()"
kiq2 () {
  dotenv -f ".env.local" bundle exec sidekiq -C ./config/sidekiq.yml
}

# echo "loading wp()"
wp () {
  nvm use $(cat .nvmrc)
  yarn install
  ./bin/webpack-dev-server
}

# echo "loading yarnup()"
yarnup () {
  nvm install $(cat .nvmrc)
  nvm use $(cat .nvmrc)
  npm install yarn webpack webpack-dev-server -g
}

# echo "loading nvmi()"
nvmi () {
  nvm install $(cat .nvmrc)
}

# echo "loading rai() # alias rey()"
rai () {
  bundle
  rails s
}
alias rey="rai"
