#!/bin/bash
#set up env

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.zsh_aliases -O /home/$USER/.zsh_aliases

echo 'if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi' >> ~/.zshrc

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.vimrc -O /home/$USER/.vimrc

update(){
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential
}

doc() {
    mkdir -p /home/$USER/Documents/HackTheBox/.env
    mkdir -p /home/$USER/Documents/TryHackMe/.env
    mkdir -p /home/$USER/Documents/HackTheBox/exploit
    wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -O /home/$USER/Documents/TryHackMe/.env/linpeas.sh
}

tools(){
    sudo apt-get install gdb -y
    git clone https://github.com/pwndbg/pwndbg /home/$USER/pwndbg
    #bash -c /home/$USER/pwndbg/setup.sh
    sudo apt-get install gobuster -y
    sudo apt-get install dirsearch -y

    # docker
    sudo apt-get install docker.io -y
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done 
    sudo chown $USER:docker /var/run/docker.sock
    

    # pwntools
    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade pwntools
    echo "export PATH=/home/$USER/.local/bin:$PATH" >> /home/$USER/.zshrc 
    
}

#synclient VertScrollDelta=-79 if mousepad is inverted

doc
