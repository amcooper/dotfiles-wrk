# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

HISTFILE=$ZDOTDIR/.zsh_history

# terminal colors
export COLORTERM=24bit

# Setting some opts
# setopt correct_all
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt long_list_jobs
setopt interactivecomments

# Initialize the completion system
# fpath=(~/config/zsh/.zsh $fpath)
autoload -U compinit ; compinit

## Vi keybindings for the shell ##
bindkey -v

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

## History navigation by search pattern
autoload history-search-end
zle -N history-beginning-search-backward-end \
       history-search-end
zle -N history-beginning-search-forward-end \
       history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

## Aliases
source ~/.config/zsh/aliases.zsh

source ~/.config/zsh/completion.zsh
source ~/.config/zsh/termsupport.zsh
source ~/.config/zsh/theme-and-appearance.zsh

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Starship
eval "$(starship init zsh)"

## FZF ##
source <(fzf --zsh)
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# source ~/.vim/plugged/fzf/shell/completion.zsh
# source ~/.vim/plugged/fzf/shell/key-bindings.zsh

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --no-ignore --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --no-ignore --type d --hidden --follow --exclude ".git" . "$1"
}

# FZF | Dracula theme
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Block and beam cursors for vim mode
cursor_mode() {
    # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}

cursor_mode

## zoxide ##
eval "$(zoxide init zsh)"

# nvm
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.config/nvm"
source $NVM_DIR/nvm.sh
source $NVM_DIR/bash_completion
# source /usr/share/nvm/install-nvm-exec

# Call `nvm use` when entering a directory with `.nvmrc`
# Source: https://github.com/nvm-sh/nvm#deeper-shell-integration
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

# ripgrep-all
rga-fzf() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	xdg-open "$file"
}


# pnpm
export PNPM_HOME="/Users/adamcooper/.config/local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home

# samizdat
source $HOME/code/samizdat-core/.env

# secrets
source $HOME/dotfiles/zsh/secrets.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/adamcooper/builds/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/adamcooper/builds/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/adamcooper/builds/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/adamcooper/builds/google-cloud-sdk/completion.zsh.inc'; fi
