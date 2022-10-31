G='\033[0;32m'
N='\033[0m'

source src/s02-machine-commands.sh

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

# echo
# echo -e "${G}Setup PRG-MIT WiFi${N}"
# sudo cp -R -u -p src/PRG-MIT /etc/NetworkManager/system-connections/
# sudo chmod 600 /etc/NetworkManager/system-connections/PRG-MIT &&
# echo "OK"

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
unzip -qq ~/chrome-linux.zip -d ~/ &&
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
#newgrp docker & # if you do this, it will exit out to terminal. So don't do it.
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
echo -e "${G}Setup VPN${N}"
tar zxvf vpn-s02.tar.gz -C ~/
cd ~/vpn && sudo ./install.sh 
cd $ROOT_DIR
echo "OK"

INSTALL_WIFI_DONGLE=true
while true; do
    read -p "Are you installing a WiFi dongle? [Y/n]: " yn
    case $yn in
        [Nn]* ) INSTALL_WIFI_DONGLE=false; break;;
        [Yy]* ) read -n 1 -r -s -p  "Okay, setting up WiFi Dongle. Connect WiFi USB Dongle and hit enter..."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

read -r -d '' wifi_interfaces_config <<EOF
iface wlan0 inet static
address 10.99.0.1
netmask 255.255.255.0
gateway 10.99.0.1
EOF

read -r -d '' wifi_sysctl_config <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

read -r -d '' wifi_hostapd_config <<EOF
country_code=US
interface=wlan0
driver=nl80211
ssid=$HOSTNAME
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=3
wpa_passphrase=JiboHasWiFi1
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

read -r -d '' wifi_dnsmasq_config <<EOF
interface=wlan0
dhcp-range=10.99.0.2,10.99.0.20,255.255.255.0,24h
no-hosts
addn-hosts=/etc/hosts.dnsmasq
domain=wlan
address=/gw.wlan/10.99.0.1
EOF

read -r -d '' wpa_supplicant <<EOF
ctrl_interface=/var/run/wpa_supplicant
update_config=1
country=US

network={
	ssid="hindol"
	psk=375fd953ab5cbc33a4ce1b7d455213de40ee5aeac577215237f1107cb3a148ff
}

network={
	ssid="PRG-MIT"
	psk=eaaf33ae234217c783d8e1c21eb6e1b1b4534171a0aa8befa386b2d55a84bac0
}

network={
	ssid="SquidDisco 5GHz"
	psk=cf0ba3aceef787616471c206c3e5f6fe400fad78a65c5bade078e5ed20e264f4
}
EOF

if $INSTALL_WIFI_DONGLE; then
   if [ ! -d "/usr/local/jibo-station-wifi-service" ]; then

      # disable the unique network interface names, go back to wlan0 & wlan1
      echo "disabling complex names"
      sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

      echo "$wifi_interfaces_config" | sudo tee -a /etc/network/interfaces
      sudo sed -i~ 's/auto lo/auto lo wlan0/' /etc/network/interfaces

      # cat /etc/network/interfaces
      # echo
      # echo "/etc/network/interfaces should look like this:"
      # echo "auto lo wlan0
      #  iface lo inet loopback
      #  iface wlan0 inet static
      #  address 10.99.0.1
      #  netmask 255.255.255.0
      #  gateway 10.99.0.1"

      echo "$wifi_sysctl_config" | sudo tee -a /etc/sysctl.conf

      echo "$wifi_hostapd_config" | sudo tee /etc/hostapd/hostapd.conf

      echo "DAEMON_CONF=/etc/hostapd/hostapd.conf" | sudo tee -a /etc/default/hostapd

      sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.dist &&
      echo "$wifi_dnsmasq_config" | sudo tee /etc/dnsmasq.conf &&
      sudo touch /etc/hosts.dnsmasq

      sudo sed -i~ '/^Requires=network.target/a After=network-online.target\nWants=network-online.target' /lib/systemd/system/dnsmasq.service

      sudo cp /lib/systemd/system/dnsmasq.service  /etc/systemd/system/

      sudo sed -i~ '/^exit 0.*/e cat wifi_rclocal_config.txt' /etc/rc.local

      echo "installing dhcpcd5"
      sudo apt update
      sudo apt install dhcpcd5
      sudo systemctl enable dhcpcd

      echo "configuring wpa_supplicant"
      echo "$wpa_supplicant" | sudo tee /etc/wpa_supplicant.conf
      
      sudo mv wpa_supplicant.service /etc/systemd/system/

      # probably not needed
      sudo systemctl enable wpa_supplicant.service

      # diable Network Manager
      #systemctl stop NetworkManager  # nah! probably don't wanna do this
      for f in NetworkManager NetworkManager-wait-online.service NetworkManager-dispatcher.service network-manager.service; do
         echo "disabling $f"
         sudo systemctl disable $f
      done

      sudo git clone https://github.com/mitmedialab/jibo-station-wifi-service /usr/local/jibo-station-wifi-service
      sudo chown -R prg /usr/local/jibo-station-wifi-service
      cd /usr/local/jibo-station-wifi-service && ./install.sh

      cd $ROOT_DIR
   fi
fi

echo
echo -e "${G}Install and Log-in to RemotePC${N}"
FILE="remotepc.deb"
if [[ ! -f "$FILE" ]]; then
  # wget  https://static.remotepc.com/downloads/rpc/310320/remotepc.deb #ubuntu 18+
  wget https://download.remotepc.com/downloads/rpc/310320/remotepc-old.deb # ubuntu 16
fi
# sudo apt install -y ./remotepc.deb
sudo apt install -y ./remotepc-old.deb # ubuntu16

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

# echo
# echo -e "${G}Copy the following computer hostname and wlan MAC address to the provided URL${N}"
# echo -e "${G}If the hostname is not in \"s02-nXX-nux-YY\" format, change it in /etc/hostname${N}"
# cat /etc/hostname
# wlan1=`ifconfig wlp58s0 2>/dev/null | awk '/HWaddr/ {print $5}'`
# wlan2=`ifconfig wlp0s20f3 2>/dev/null | awk '/HWaddr/ {print $5}'`
# eth=`ifconfig eno1 2>/dev/null | awk '/HWaddr/ {print $5}'`

# echo "WLAN  $wlan1$wlan2"
# echo "ETH   $eth"
# xdg-open $SHEET_URL 2>/dev/null

echo
echo "Done. Now run 'remotepc &' and 'sudo teamviewer setup' on another terminal. After logging in the first time, you need to check email and verify new device."

echo
echo "RemotePC and TeamViewer logins are in LastPass."
echo "RemotePC password is copied to clipboard for your convenience."
echo "u8sv5R&K8n4q" | xclip -selection c

read -n 1 -r -s -p $'When done, press any key to continue...\n\n'

echo
sudo bash setup_usb-cam.sh 

