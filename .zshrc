if [[ ! -d "$HOME/.zgen" ]]; then
    git clone https://github.com/tarjoilija/zgen.git $HOME/.zgen
fi

if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

source "${HOME}/.zgen/zgen.zsh"
# if the init scipt doesn't exist
if ! zgen saved; then

  # specify plugins here
  zgen oh-my-zsh
  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/battery
  zgen oh-my-zsh plugins/sudo
  zgen oh-my-zsh plugins/command-not-found
  zgen load zsh-users/zsh-syntax-highlighting
  # generate the init script from plugins above
  vim +PluginInstall +qall
  zgen save
fi

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="bmarty"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.zsh/custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#WORKON_HOME=$HOME/.env

plugins=(git battery) # vi-mode battery virtualenvwrapper)

source $ZSH/oh-my-zsh.sh
# User configuration
#export PATH=$HOME/.zsh/scripts:$PATH
#export PATH=/usr/local/Cellar:$PATH
#export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH
#export MANPATH="/usr/local/man:$MANPATH"

bindkey "^R" history-incremental-search-backward

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#alias mm="make minimal"
#source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
### Added by the Heroku Toolbelt
#export PATH="/usr/local/heroku/bin:$PATH"
#source ~/perl5/perlbrew/etc/bashrc
export SSH_AUTH_SOCK=/Users/bryanmarty/.gnupg/S.gpg-agent.ssh
#source /usr/local/share/zsh/site-functions/_aws

#export PYTHONPATH="/usr/local/google_appengine:$PYTHONPATH"
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"

# The next line updates PATH for the Google Cloud SDK.
#if [ -f '/Users/bryanmarty/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/bryanmarty/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
#if [ -f '/Users/bryanmarty/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/bryanmarty/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
#[[ -s "$HOME/.avn/bin/avn.sh" ]] && source "$HOME/.avn/bin/avn.sh" # load avn
