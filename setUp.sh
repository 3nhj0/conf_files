#!/bin/bash
#set up env

echo 'test'

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.zsh_aliases
mv .zsh_aliases ~/.zsh_aliases

echo 'if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi' >> ~/.zshrc

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.vimrc

mv .vimrc ~/.vimrc


doc() {
    mkdir -p ~/Documents/HackTheBox/.env
    mkdir -p ~/Documents/HackTheBox/exploit
    mkdir -p ~/Documents/TryHackMe/.env
}

doc
