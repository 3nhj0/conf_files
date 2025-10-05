#!/bin/bash
#set up env
user=enhj0

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.zsh_aliases -O /home/$user/.zsh_aliases
#wget https://gist.githubusercontent.com/noahbliss/4fec4f5fa2d2a2bc857cccc5d00b19b6/raw/db5ceb8b3f54b42f0474105b4a7a138ce97c0b7a/kali-zshrc -O /home/$user/.zshrc

echo 'source /home/'$user'/.venvs/MyEnv/bin/activate' >> /home/$user/.zshrc

echo 'if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi' >> ~/.zshrc

wget https://raw.githubusercontent.com/3nhj0/conf_files/main/.vimrc -O /home/$user/.vimrc

update(){
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y python3 python3-pip python3-dev git libssl-dev libffi-dev build-essentiali
}

doc() {
    mkdir -p /home/$user/Documents/HackTheBox/.env
    mkdir -p /home/$user/Documents/TryHackMe/.env
    mkdir -p /home/$user/Documents/HackTheBox/exploit
    mkdir -p /home/$user/ghidra
    wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -O /home/$user/Documents/exploit/linpeas.sh
}

tools(){
    sudo apt install zsh -y
    sudo apt install snap -y
    sudo apt install ropper -y
    sudo apt-get install gdb -y
    git clone https://github.com/pwndbg/pwndbg /home/$user/pwndbg
    /home/$user/pwndbg/setup.sh
    
    #bash -c /home/$USER/pwndbg/setup.sh
    
    sudo apt-get install gobuster -y
    sudo apt-get install dirsearch -y
    sudo snap install ghidra -y
    sudo apt install code-oss -y

    # docker
    sudo apt-get install docker.io -y
    sudo apt-get install docker-compose -y
    sudo chown $user:docker /var/run/docker.sock
    

    # pwntools
    mkdir -p ~/.venvs/MyEnv
    python3 -m venv /home/$user/.venvs/MyEnv
    source /home/$user/.venvs/MyEnv/bin/activate
    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade pwntools
    echo "export PATH=/home/$user/.local/bin:$PATH" >> /home/$user/.zshrc 
    
    # pwndbg
    git clone https://github.com/pwndbg/pwndbg.git /home/$user/pwndbg
    sudo /bin/sh /home/$user/pwndbg/setup.sh
}

#synclient VertScrollDelta=-79 if #mousepad is inverted

#update
doc
tools

chsh -s $(which zsh)
