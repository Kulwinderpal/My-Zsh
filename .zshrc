# Commands to Execute at Startup
fastfetch

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Install and Configure the Pure Prompt
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/Pure
autoload -U promptinit; promptinit
zstyle ':prompt:pure:prompt:*' color '#F667BD'

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Add Plugins Here
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-auto-notify

# Add Snippets Here
zinit snippet OMZP::gh
zinit snippet OMZP::git
zinit snippet OMZP::history
zinit snippet OMZP::man
zinit snippet OMZP::npm
zinit snippet OMZP::pip
zinit snippet OMZP::python
zinit snippet OMZP::zoxide

# Load the Zsh Completions
autoload -U compinit && compinit

# Configure Zsh History
HISTFILE=7000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

# Configure Auto Notify
export AUTO_NOTIFY_THRESHOLD=90
export AUTO_NOTIFY_TITLE="Hey Lil Bro, %command Finished."

# Set Options for History

setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion Styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' 
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Define Aliases
alias cat='bat --paging=never'
alias bat='bat --paging=never'
alias cp='cp -i'
alias mkdir='mkdir -p'
alias mv='mv -i'
alias grep=rg
alias chown='sudo chown'
alias ls='ls --color'
alias cd=z
alias vim=nvim
alias ls='ls -hA'
alias ll='ls -lhA'
alias $EDITOR='f(){ if [ -w "$1" ] || [ ! -e "$1" ]; then command $EDITOR "$@"; else sudoedit "$@"; fi; }; f'

# Shell Integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

# Define Variables Here
EDITOR=nvim

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
