G='\033[0;32m'
N='\033[0m'

source s02-machine-commands.sh

echo
echo -e "${G}Set user to execute sudo commands without password${N}"
sudo sed -i '27i prg ALL=(ALL) NOPASSWD: ALL' /etc/sudoers  &&

echo
echo -e "${G}Set default MIC source to MXL AC404${N}"
MIC_NAME=`pactl list short sources | grep USB_audio_CODEC | grep alsa_input | awk '{print $2}'`
sudo sed -i '/set-default-source/a\set-default-source $MIC_NAME' /etc/pulse/default.pa  &&

echo
echo -e "${G}Setup Jibo Audio Streaming Script${N}"
sudo cp jibo-audio-streaming-receiver.sh  /usr/local/bin/
sudo sed -i '/exit 0/i\/usr/local/bin/jibo-audio-streaming-receiver.sh &\n' /etc/rc.local

echo
echo -e "Setup PRG-MIT WiFi"
sudo cp PRG-MIT /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/PRG-MIT

echo
echo -e "Add ssh keys"
   echo "adding haewon's ssh key"
   echo "$haewons_ssh_key" > /tmp/additional_key.pub
   ssh-copy-id -f -i /tmp/additional_key
   echo "adding brayden's ssh key"
   echo "$braydens_ssh_key" > /tmp/additional_key.pub
   ssh-copy-id -f -i /tmp/additional_key
   echo "adding sam's ssh key"
   echo "$sams_ssh_key" > /tmp/additional_key.pub
   ssh-copy-id -f -i /tmp/additional_key
   echo "adding jon's ssh key"
   echo "$jons_ssh_key" > /tmp/additional_key.pub
   ssh-copy-id -f -i /tmp/additional_key
   rm /tmp/additional_key

echo
echo -e "${G}apt-get update${N}"
sudo apt-get update &&

echo
echo -e "${G}install packages${N}"
sudo apt-get -y install vim-gtk-py2 apt-transport-https ca-certificates curl gnupg-agent software-properties-common &&

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

#echo
#echo -e "${G}Install packages${N}"
#sudo apt-get -y install gnome-tweak-tool

echo
echo -e "${G}Install openssh-server${N}"
sudo apt-get -y install openssh-server &&
sudo systemctl enable ssh
sudo systemctl start ssh

echo
echo -e "${G}Join Docker Swarm${N}"
sudo docker swarm join --token SWMTKN-1-4qtr77cbney2t4f81rj7qlz61fq78l4wyv3infn4d5lz1ct1g1-4ryfnlja84ovm2da412rk0xe2 18.27.79.165:2377 &&

echo
echo -e "${G}Run local Docker Containers${N}"
#sudo docker login &&
#sudo docker run -it -p 554:554 -p 7888:7888 -p 8777:8777 -p 37777:37777 -p 37778:37778 mitprg/s02-literacy-ga:first &&
ROS_IMAGE_ID=`docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
sudo docker run -d -it --restart=unless-stopped --device=/dev/video0:/dev/video0 \
         --network=host --workdir=/root/catkin_ws/src/unity-game-controllers \
         $ROS_IMAGE_ID python3.6 -m scripts.utils_scripts.start_usb_cam_launcher.py 

#sudo docker run -d -it --restart=unless-stopped --device=/dev/snd:/dev/snd \
#         --network=host --workdir=/root/catkin_ws/src/unity-game-controllers \
#         $ROS_IMAGE_ID python3.6 -m scripts.utils_scripts.start_mic_launcher.py 

echo
echo -e "${G}Install and Log-in to TeamViewer${N}"
wget https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc &&
sudo apt-key add TeamViewer2017.asc &&
sudo sh -c 'echo "deb http://linux.teamviewer.com/deb stable main" >> /etc/apt/sources.list.d/teamviewer.list' &&
sudo apt update &&
sudo apt install -y teamviewer &&
teamviewer

echo
echo -e "${G}Copy the following computer hostname and wlan MAC address to the provided URL${N}"
echo -e "${G}If the hostname is not in \"s02-nXX-nux-YY\" format, change it in /etc/hostname${N}"
cat /etc/hostname
ifconfig wlp58s0 2>/dev/null|awk '/HWaddr/ {print $5}'
xdg-open https://docs.google.com/spreadsheets/d/1LyPBXvrFj7XT9vVZTdyXslW371ttndbsb-SnG8kh-2M/edit?usp=sharing

echo
echo "done."
