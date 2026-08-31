# ERA:MANAGED:START (era-codex)
#
# `era-codex` -> Era-provisioned Codex with full host access and approval prompts.
# Managed by `era-code setup`; edit via that command, not by hand.
era-codex() {
  era-code codex -- -s danger-full-access -a on-request "$@"
}
# ERA:MANAGED:END (era-codex)

# ERA:MANAGED:START (era-claude)
# `era-claude` -> Era-provisioned Claude Code with permission prompts skipped.
# Managed by `era-code setup`; edit via that command, not by hand.
era-claude() {
  era-code claude --dangerously-skip-permissions "$@"
}
# ERA:MANAGED:END (era-claude)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/jackhogan/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gnzh"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting poetry)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export LDFLAGS="-L/opt/homebrew/opt/openssl/lib"
export CPPFLAGS="-L/opt/homebrew/opt/openssl/include"
export PATH="/opt/homebrew/bin:$PATH:/Users/jackhogan/Library/Android/sdk/platform-tools:/Users/jackhogan/.cargo/bin:/Users/jackhogan/vcpkg"

export VCPKG_HOME="$HOME/vcpkg"
alias ls=eza
alias cat="bat --theme 'Monokai Extended'"
alias bcat="/bin/cat"
alias zrc="nvim ~/.zshrc && . ~/.zshrc"
alias sbcd="cd ~/.config/sketchybar"
alias sbr="brew services restart sketchybar"
alias rsync="rsync -zap"
alias cb="cargo build"
alias cbr="cargo build --release"
alias cr="cargo run"
alias crr="cargo run --release"
alias crud="cargo +nightly udeps"
alias speedtest="cf_speedtest"
alias man="qman"
alias claude="claude --dangerously-skip-permissions --allow-dangerously-skip-permissions"

svenv() {
    source "$1/bin/activate"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init zsh)"


[ -f "/Users/jackhogan/.ghcup/env" ] && source "/Users/jackhogan/.ghcup/env" # ghcup-env
export PATH="/Users/jackhogan/.mozbuild/git-cinnabar:$PATH"

# Only load zoxide if in interactive terminal (TTY)
# ClaudeCode and other agentic software is weird otherwise
if [ -t 0 ]; then
eval "$(zoxide init zsh --cmd cd)"
fi

. "$HOME/.cargo/env"
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
. /Users/jackhogan/export-esp.sh
source <(fzf --zsh)
eval "$(direnv hook zsh)"
eval $(thefuck --alias)

# Created by `pipx` on 2024-11-22 23:23:09
export PATH="$PATH:/Users/jackhogan/.local/bin"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-unknown-linux-gnu-gcc

function ollama-update() {
    ollama list | awk 'NR>1 {print $1}' | xargs -I {} sh -c 'echo "Updating model: {}"; ollama pull {}; echo "--"' && echo "All models updated."
}
function sshwatch() {
    while ssh $1 ps -ax | grep $2 > /dev/null; do
        sleep 5
    done
    
    osascript -e "display notification \"SSH process $2 on host $1 exited\" with title \"SSH Watcher\""
}
function mkcd() {
    mkdir $1
    cd $1
}
fix_quotes() {
    if [ -z "$1" ]; then
        echo "Usage: fix_quotes <filename>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found"
        return 1
    fi

    sed -i '' \
        -e 's/”/"/g' \
        -e 's/“/"/g' \
        -e "s/’/'/g" \
        -e "s/‘/'/g" \
        "$1"

    echo "Smart quotes replaced in '$1'"
}
nsh() {
    nix-shell -p $@
}

# Machine-local secrets, kept out of the dotfiles repo.
[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"

export SCCACHE_DIR="$HOME/Library/Caches/sccache"
export SCCACHE_CACHE_SIZE="50G"
export EDITOR=nvim
export OLLAMA_ORIGINS="*"
export CLAUDE_CODE_NO_FLICKER=1

# Drop duplicate PATH entries, keeping the first (highest-priority) occurrence.
typeset -U path
export PATH
