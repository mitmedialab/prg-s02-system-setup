#!/bin/bash

G='\033[0;32m'
N='\033[0m'

source s06-empathy-interactions/s06-machine-commands.sh

ROOT_DIR=$PWD

echo
echo -e "${G}Set user to execute sudo commands without password${N}"
line="$USER ALL=(ALL) NOPASSWD: ALL"
sudo grep -qxF "$line" /etc/sudoers || sudo sed -i '27i '"$line"'' /etc/sudoers  &&
echo "OK"

LOC_SCHOOL="1"
LOC_HOME="2"
LOC_DHA="3"
echo "Select from the following option:"
echo "[1] School Deployment"
echo "[2] Home Deployment"
echo "[3] DHA Deployment"
read LOCATION

if [ "$LOCATION" = "$LOC_SCHOOL" ]; then
   SWARM_TOKEN="SWMTKN-1-4qtr77cbney2t4f81rj7qlz61fq78l4wyv3infn4d5lz1ct1g1-4ryfnlja84ovm2da412rk0xe2 18.27.79.165:2377"
   SHEET_URL="https://docs.google.com/spreadsheets/d/1LyPBXvrFj7XT9vVZTdyXslW371ttndbsb-SnG8kh-2M/edit?usp=sharing"
elif [ "$LOCATION" = "$LOC_HOME" ]; then
   SWARM_TOKEN="SWMTKN-1-3r1kuhl9wrgka8pce4slulizgo0elx8m81plxsxct31md3tbgd-by06dq1top1x9wfm3mxwn6z5b 18.27.78.195:2377" 
   SHEET_URL="https://docs.google.com/spreadsheets/d/135a5wF63Tt_AUOSR7NvoM1jeysmoccADIUxwsIcF2c0/edit?usp=sharing"
elif [ "$LOCATION" = "$LOC_DHA" ]; then
   SWARM_TOKEN="SWMTKN-1-3mh14xm7y74su3jcoym339t7n562bzossrfn0fksdv5wm2qnxm-ex4dblke9q3os5o2i1cixlv88 18.27.79.58:2377" 
   SHEET_URL="https://docs.google.com/spreadsheets/d/135a5wF63Tt_AUOSR7NvoM1jeysmoccADIUxwsIcF2c0/edit?usp=sharing"   
else
   exit
fi


echo
echo -e "${G}Setup Reboot Timer${N}"
# reboot_cmd="00 7 \* \* \*      /sbin/reboot"
# if ! sudo grep -q "\*/1 \* \* \* \*    /bin/bash /usr/local/jibo-station-wifi-service/check_and_run.sh" /var/spool/cron/crontabs/root; then 
#    echo -e "$(sudo crontab -u root -l)\n*/1 * * * *    /bin/bash /usr/local/jibo-station-wifi-service/check_and_run.sh" | sudo crontab -u root -
# fi
if ! sudo grep -q "\*/1 \* \* \* \* \+/bin/systemctl start docker" /var/spool/cron/crontabs/root; then 
   echo -e "$(sudo crontab -u root -l)\n*/1 * * * *    /bin/systemctl start docker" | sudo crontab -u root -
fi
if ! sudo grep -q "00 7 \* \* \* \+/bin/systemctl restart docker" /var/spool/cron/crontabs/root; then 
   echo -e "$(sudo crontab -u root -l)\n00 7 * * *    /bin/systemctl restart docker" | sudo crontab -u root -
fi
if ! sudo grep -q "#00 7 \* \* \* \+/sbin/reboot" /var/spool/cron/crontabs/root; then 
   echo -e "$(sudo crontab -u root -l)\n#00 7 * * *    /sbin/reboot" | sudo crontab -u root -
fi
echo
sudo cat /var/spool/cron/crontabs/root
echo
echo "OK"

echo
echo -e "${G}Add ssh keys${N}"
   mkdir -p ~/.ssh
   echo "adding haewon's ssh key"
   sudo grep -qxF "$haewons_ssh_key" ~/.ssh/authorized_keys || echo "$haewons_ssh_key" >> ~/.ssh/authorized_keys
   echo "adding brayden's ssh key"
   sudo grep -qxF "$braydens_ssh_key" ~/.ssh/authorized_keys || echo "$braydens_ssh_key" >> ~/.ssh/authorized_keys
   echo "adding sam's ssh key"
   sudo grep -qxF "$sams_ssh_key" ~/.ssh/authorized_keys || echo "$sams_ssh_key" >> ~/.ssh/authorized_keys
   echo "adding jon's ssh key"
   sudo grep -qxF "$jons_ssh_key" ~/.ssh/authorized_keys || echo "$jons_ssh_key" >> ~/.ssh/authorized_keys

echo
echo -e "${G}apt-get update${N}"
sudo apt-get update &&

echo
echo -e "${G}install packages${N}"
sudo apt-get -y install vim-gnome apt-transport-https ca-certificates curl gnupg-agent software-properties-common xclip hostapd haveged dnsmasq &&

echo
echo -e "${G}Install openssh-server${N}"
sudo apt-get -y install openssh-server &&
sudo systemctl enable ssh
sudo systemctl start ssh

echo
echo -e "${G}Install low version Chromium for Jibo Console${N}"
FILE="/home/prg/chrome-linux.zip"
if [[ ! -f "$FILE" ]]; then
   wget http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/629479/chrome-linux.zip -P ~/ 
fi
unzip -qq ~/chrome-linux.zip -d ~/ &&
cp -R -u -p s06-empathy-interactions/JiboChromium_logo.png ~/chrome-linux &&
cp -R -u -p s06-empathy-interactions/JiboChromium.desktop ~/Desktop &&
echo "OK"

echo
echo -e "${G}Create Rosbag Data Tardis folder${N}"
mkdir -p ~/rosbags/data-tardis
echo "OK"

# Docker setup
echo
echo -e "${G}Add Docker's official GPG key${N}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&

echo
echo -e "${G}Setup Docker stable repository${N}"
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" &&

echo
echo -e "${G}apt-get update${N}"
sudo apt-get update &&
echo
echo -e "${G}Install Docker Engine - Community${N}"
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

echo
echo -e "${G}Verify Docker Engine is successfully installed${N}"
sudo docker run hello-world

echo
echo -e "${G}Install Docker Compose${N}"
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose &&
sudo chmod +x /usr/local/bin/docker-compose &&

echo
echo -e "${G}Verify Docker Compose is successfully installed${N}"
docker-compose --version

echo
echo -e "${G}Join Docker Swarm${N}"
sudo docker swarm join --token $SWARM_TOKEN &&

echo
echo -e "${G}Add User to Docker group${N}"
sudo groupadd docker
sudo gpasswd -a $USER docker
#newgrp docker & # if you do this, it will exit out to terminal. So don't do it.
sleep 1s
mkdir -p /home/prg/.docker &&
sudo chown prg:prg /home/prg/.docker -R &&
sudo chmod g+rwx "/home/prg/.docker" -R &&
echo "OK"

echo
echo -e "${G}Set up ALSA configuration${N}"
touch ~/Templates/"New Document"
sudo -s <<EOF
echo "pcm.usbmic1 {
    type dsnoop
    ipc_key 123456
    ipc_perm 0666
    slave {
        pcm \"hw:CARD=AC44,DEV=0\"
        channels 1
        rate 44100
    }
    hint {
        description \"LOOPBACK_DEV\"
    }
}

pcm.usbmic2 {
    type dsnoop
    ipc_key 123456
    ipc_perm 0666
    slave {
        pcm \"hw:CARD=AC44,DEV=0\"
        channels 1
        rate 32000
    }
    hint {
        description \"LOOPBACK_DEV_2\"
    }
}" > /etc/asound.conf && echo "OK"
EOF

echo -e "${G}Create s06 Video folder${N}"
mkdir -p ~/s06-empathy-interaction/empathy_videos/uploaded &&
echo "OK"

echo
echo -e "${G}Install and Log-in to RemotePC${N}"
FILE="remotepc.deb"
if [[ ! -f "$FILE" ]]; then
  wget  https://static.remotepc.com/downloads/rpc/310320/remotepc.deb #ubuntu 18+
fi
sudo apt install -y ./remotepc.deb

echo
echo "Done. Now run 'remotepc &' on another terminal. After logging in the first time, you need to check email and verify new device."

echo
echo "RemotePC login is in LastPass."
echo "RemotePC password is copied to clipboard for your convenience."
echo "u8sv5R&K8n4q" | xclip -selection c

read -n 1 -r -s -p $'When done, press any key to continue...\n\n'
