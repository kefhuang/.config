# powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#########################
# oh-my-zsh configuration
#########################
export ZSH="$HOME/.oh-my-zsh"
# theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# plugins
plugins=(
        git
        z
        history
        extract
        sudo
        zsh-syntax-highlighting
        zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
bindkey '^y' autosuggest-accept # zsh-autosuggestions

#####################
# powerlevel10k setup
#####################
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

##########
# WezTerm
##########
export XDG_CONFIG_HOME="$HOME/.config"
