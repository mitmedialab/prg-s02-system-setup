G='\033[0;32m'
N='\033[0m'

source s02-machine-commands.sh

echo
echo -e "${G}Set user to execute sudo commands without password${N}"
line='prg ALL=(ALL) NOPASSWD: ALL'
sudo grep -qxF "$line" /etc/sudoers || sudo sed -i '27i '"$line"'' /etc/sudoers  &&
echo "OK"

# todo: Run after station assemnly.
# echo
# echo -e "${G}Set default MIC source to MXL AC404${N}"
# MIC_NAME=`pactl list short sources | grep USB_audio_CODEC | grep alsa_input | awk '{print $2}'`
# line="set-default-source $MIC_NAME"
# sudo grep -qxF "$line" /etc/pulse/default.pa || sudo sed -i '/#set-default-source/a\'"$line"'' /etc/pulse/default.pa  &&
# echo "OK"

echo
echo -e "${G}Setup Jibo Audio Streaming Script${N}"
sudo cp jibo-audio-streaming-receiver.sh  /usr/local/bin/
line="/usr/local/bin/jibo-audio-streaming-receiver.sh &"
sudo grep -qxF "$line" /etc/rc.local || sudo sed -i '$i \'"$line"'\n' /etc/rc.local
echo "OK"

echo
echo -e "${G}Setup PRG-MIT WiFi${N}"
sudo cp PRG-MIT /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/PRG-MIT &&
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

# todo: Run after station assemnly.
# echo
# echo -e "${G}Run USB_CAM Docker Container${N}"
# #sudo docker login &&
# #sudo docker run -it -p 554:554 -p 7888:7888 -p 8777:8777 -p 37777:37777 -p 37778:37778 mitprg/s02-literacy-ga:first &&
# ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
# sudo docker run -d -it --restart=always --device=/dev/video0:/dev/video0 \
#          --network=host --workdir=/root/catkin_ws/src/unity-game-controllers --name=usb_cam \
#          $ROS_IMAGE_ID python3.6 -m scripts.utils_scripts.start_usb_cam_launcher &&

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
#teamviewer &
#sudo teamviewer setup

echo
echo -e "${G}Copy the following computer hostname and wlan MAC address to the provided URL${N}"
echo -e "${G}If the hostname is not in \"s02-nXX-nux-YY\" format, change it in /etc/hostname${N}"
cat /etc/hostname
ifconfig wlp58s0 2>/dev/null|awk '/HWaddr/ {print $5}'
ifconfig eno1 2>/dev/null|awk '/HWaddr/ {print $5}'
xdg-open https://docs.google.com/spreadsheets/d/1LyPBXvrFj7XT9vVZTdyXslW371ttndbsb-SnG8kh-2M/edit?usp=sharing

echo
echo "Done. Now run 'sudo teamviewer setup'. Don't forget to check email for verification."
