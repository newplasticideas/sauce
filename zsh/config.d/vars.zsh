export ZSH="$HOME/.oh-my-zsh"
#export PATH=$PATH:$HOME/.rbenv/bin:$HOME/.rbenv/shims
ENABLE_CORRECTION="true"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

plugins=(git ruby rails yarn bundler docker docker-compose brew)
source $ZSH/oh-my-zsh.sh

# ZSH_THEME_RANDOM_CANDIDATES=( "wuffers" "half-life" "lambda" )
# EDITOR="VIM"
# COMPLETION_WAITING_DOTS="true"
# HIST_STAMPS="dd/mm/yyyy"

[[ ":$PATH:" != *":$HOME/.rbenv/shims:"* ]] && PATH="$HOME/.rbenv/shims:${PATH}"
[[ ":$PATH:" != *":$HOME/.rbenv/bin:"* ]] && PATH="$HOME/.rbenv/bin:${PATH}"
[[ ":$PATH:" != *":/usr/local/opt/postgresql@13/bin:"* ]] && PATH="/usr/local/opt/postgresql@13/bin:${PATH}"
