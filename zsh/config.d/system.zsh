pax () {
  ps aux | grep $1
}

sapt () {
  sudo apt update
  sudo apt upgrade -y
  if ! [ -z "$1" ]
  then
    sudo apt install $1
  fi
}

# echo "loading dack()"
dack () {
  lsof -i:$1
}

# echo "loading sack()"
sack () {
  kill -9 $1
}

# echo "loading hist()"
hist () {
  cat ~/.zsh_history | grep $1
}
