G='\033[0;32m'
N='\033[0m'

source src/s02-machine-commands.sh

echo
echo -e "${G}Set user to execute sudo commands without password${N}"
line="$USER ALL=(ALL) NOPASSWD: ALL"
sudo grep -qxF "$line" /etc/sudoers || sudo sed -i '27i '"$line"'' /etc/sudoers  &&
echo "OK"

LOC_SCHOOL="1"
LOC_HOME="2"
echo "Select from the following option:"
echo "[1] School Deployment"
echo "[2] Home Deployment"
read LOCATION

if [ "$LOCATION" = "$LOC_SCHOOL" ]; then
   SWARM_TOKEN="SWMTKN-1-4qtr77cbney2t4f81rj7qlz61fq78l4wyv3infn4d5lz1ct1g1-4ryfnlja84ovm2da412rk0xe2 18.27.79.165:2377"
   SHEET_URL="https://docs.google.com/spreadsheets/d/1LyPBXvrFj7XT9vVZTdyXslW371ttndbsb-SnG8kh-2M/edit?usp=sharing"
elif [ "$LOCATION" = "$LOC_HOME" ]; then
   SWARM_TOKEN="SWMTKN-1-3r1kuhl9wrgka8pce4slulizgo0elx8m81plxsxct31md3tbgd-by06dq1top1x9wfm3mxwn6z5b 18.27.78.195:2377" 
   SHEET_URL="https://docs.google.com/spreadsheets/d/135a5wF63Tt_AUOSR7NvoM1jeysmoccADIUxwsIcF2c0/edit?usp=sharing"
else
   exit
fi

# todo: Run after station assemnly.
# echo
# echo -e "${G}Set default MIC source to MXL AC404${N}"
# MIC_NAME=`pactl list short sources | grep USB_audio_CODEC | grep alsa_input | awk '{print $2}'`
# line="set-default-source $MIC_NAME"
# sudo grep -qxF "$line" /etc/pulse/default.pa || sudo sed -i '/#set-default-source/a\'"$line"'' /etc/pulse/default.pa  &&
# echo "OK"

echo
echo -e "${G}Setup Jibo Audio Streaming Script${N}"
sudo cp -R -u -p src/jibo-audio-streaming-receiver.sh  /usr/local/bin/
if [ "$LOCATION" = "$LOC_SCHOOL" ]; then
   line="/usr/local/bin/jibo-audio-streaming-receiver.sh &"
   sudo grep -qxF "$line" /etc/rc.local || sudo sed -i '$i \'"$line"'\n' /etc/rc.local
fi
echo "OK"

echo
echo -e "${G}Setup Reboot Timer${N}"
# reboot_cmd="00 7 \* \* \*      /sbin/reboot"
if ! sudo grep -q "00 7 \* \* \*    /sbin/reboot" /var/spool/cron/crontabs/root; then 
   echo -e "$(sudo crontab -u root -l)\n00 7 * * *    /sbin/reboot" | sudo crontab -u root -
fi
echo
sudo cat /var/spool/cron/crontabs/root
echo
echo "OK"

echo
echo -e "${G}Setup PRG-MIT WiFi${N}"
sudo cp -R -u -p src/PRG-MIT /etc/NetworkManager/system-connections/
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
sudo apt-get -y install vim-gnome apt-transport-https ca-certificates curl gnupg-agent software-properties-common &&

#echo
#echo -e "${G}Install packages${N}"
#sudo apt-get -y install gnome-tweak-tool

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
unzip ~/chrome-linux.zip -d ~/ &&
cp -R -u -p src/JiboChromium_logo.png ~/chrome-linux &&
cp -R -u -p src/JiboChromium.desktop ~/Desktop &&
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
# newgrp docker # if you do this, it will exit out to terminal. So don't do it.
sleep 1s
mkdir -p /home/prg/.docker &&
sudo chown prg:prg /home/prg/.docker -R &&
sudo chmod g+rwx "/home/prg/.docker" -R &&
echo "OK"

echo
echo -e "${G}Add Docker Monitor Script${N}"
sudo cp -R -u -p src/s02-docker_monitor /usr/local/bin/ &&
sudo cp -R -u -p src/docker-ros /usr/local/bin/ &&
echo "OK"

echo
echo -e "${G}Install and Log-in to TeamViewer${N}"
FILE="TeamViewer2017.asc"
if [[ ! -f "$FILE" ]]; then
   wget https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc 
fi
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
wlan1=`ifconfig wlp58s0 2>/dev/null | awk '/HWaddr/ {print $5}'`
wlan2=`ifconfig wlp0s20f3 2>/dev/null | awk '/HWaddr/ {print $5}'`
eth=`ifconfig eno1 2>/dev/null | awk '/HWaddr/ {print $5}'`

echo "WLAN  $wlan1$wlan2"
echo "ETH   $eth"
xdg-open $SHEET_URL

echo
echo "Done. Now run 'sudo teamviewer setup' on another terminal. Don't forget to check email for verification."
read -n 1 -r -s -p $'When done, press any key to continue...\n'

echo
read -n 1 -r -s -p $'Connect USB camera and press any key to continue...\n'
echo
echo -e "${G}Run USB_CAM Docker Container${N}"
ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
while [ -z "$ROS_IMAGE_ID" ]; do
  echo "Waiting for docker image to finish download..."
  sleep 10s
  ROS_IMAGE_ID=`docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
  ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
done
echo $ROS_IMAGE_ID

sudo docker run -d -it --name=s02-ros_usb-cam --device=/dev/video0:/dev/video0 --restart=always --network=host \
         --workdir=/root/projects $ROS_IMAGE_ID  python3.6 -m s02-storybook.scripts.launcher_scripts.start_usb_cam_launcher &&

# sudo docker run -d -it --restart=unless-stopped --device=/dev/snd:/dev/snd \
#         --network=host --workdir=/root/catkin_ws/src/unity-game-controllers \
#         $ROS_IMAGE_ID python3.6 -m scripts.utils_scripts.start_mic_launcher.py 
