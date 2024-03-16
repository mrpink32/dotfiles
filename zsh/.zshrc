
# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename '/home/mikkel/.zshrc'

autoload -Uz compinit promptinit
compinit
promptinit

PROMPT='[%F{green}%n%f@%F{magenta}%m%f] {%F{blue}%B%~%b%f}> '
RPROMPT='[%F{yellow}%?%f]'

# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
#
alias ls='ls -al --color=auto'
alias grep='grep --color=auto'
alias repos='cd /mnt/data/repositories'
alias notes='cd /mnt/data/notes'
PATH=$PATH:/mnt/data/repositories/euclid/target/release
PATH=$PATH:/mnt/data/repositories/zig/zig-out/bin
PATH=$PATH:~/Downloads/zig-linux-x86_64-0.12.0-dev
PATH=$PATH:/mnt/data/repositories/zls/zig-out/bin

neofetch
