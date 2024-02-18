#!/bin/bash
#set up env

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.zsh_aliases -O /home/$USER/.zsh_aliases

echo 'if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi' >> ~/.zshrc

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.vimrc -O /home/$USER/.vimrc

doc() {
    mkdir -p ~/Documents/HackTheBox/.env
    mkdir -p ~/Documents/HackTheBox/exploit
    mkdir -p ~/Documents/TryHackMe/.env
}

tools(){
    sudo apt-get install gobuster
    sudo apt-get install dirsearch
    sudo apt-get install docker.io
    sudo chown $USER:docker /var/run/docker.sock
    
}

#synclient VertScrollDelta=-79 if mousepad is inverted

doc
