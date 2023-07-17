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
   # SHEET_URL="https://docs.google.com/spreadsheets/d/1LyPBXvrFj7XT9vVZTdyXslW371ttndbsb-SnG8kh-2M/edit?usp=sharing"
elif [ "$LOCATION" = "$LOC_HOME" ]; then
   SWARM_TOKEN="SWMTKN-1-3r1kuhl9wrgka8pce4slulizgo0elx8m81plxsxct31md3tbgd-by06dq1top1x9wfm3mxwn6z5b 18.27.78.195:2377" 
   # SHEET_URL="https://docs.google.com/spreadsheets/d/135a5wF63Tt_AUOSR7NvoM1jeysmoccADIUxwsIcF2c0/edit?usp=sharing"
elif [ "$LOCATION" = "$LOC_DHA" ]; then
   SWARM_TOKEN="SWMTKN-1-3mh14xm7y74su3jcoym339t7n562bzossrfn0fksdv5wm2qnxm-ex4dblke9q3os5o2i1cixlv88 18.27.79.58:2377" 
   # SHEET_URL="https://docs.google.com/spreadsheets/d/135a5wF63Tt_AUOSR7NvoM1jeysmoccADIUxwsIcF2c0/edit?usp=sharing"   
else
   exit
fi


echo
echo -e "${G}Setup rc.local${N}"
FILE="/etc/rc.local"
if [[ ! -f "$FILE" ]]; then 
sudo cp rc-local.service /etc/systemd/system/rc-local.service
    echo "#!/bin/sh -e" | sudo tee /etc/rc.local
    echo "" | sudo tee -a /etc/rc.local
    echo "exit 0" | sudo tee -a /etc/rc.local
    sudo chmod +x /etc/rc.local
    sudo systemctl enable rc-local
    echo "OK"
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
   chmod go-rwx ~/.ssh
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
sudo apt-get -y install vim-gnome apt-transport-https ca-certificates curl gnupg-agent software-properties-common xclip hostapd haveged dnsmasq cmtest make &&

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
        rate 32000
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
echo -e "${G}Setup VPN${N}"
tar zxvf vpn-s02.tar.gz -C ~/
cd ~/vpn && sudo ./install.sh 
cd $ROOT_DIR
echo "OK"


if [ -d "/usr/local/jibo-station-wifi-service" ]; then
    echo ""
    echo "Note: It looks like jibo-station-wifi-service has already been installed"
    echo "      So you might want to say 'No' to the next question"
    echo ""
fi

# WiFi setup
INSTALL_WIFI_DONGLE=true
while true; do
    read -p "Are you installing a WiFi dongle? [Y/n]: " yn
    case $yn in
        [Nn]* ) INSTALL_WIFI_DONGLE=false; break;;
        [Yy]*|"" ) read -n 1 -r -s -p  "Okay, setting up WiFi Dongle. Connect WiFi USB Dongle and hit enter..."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

read -r -d '' wifi_interfaces_config <<EOF
auto lo wlan0
allow-hotplug wlan1
iface wlan0 inet static
address 10.99.0.1
netmask 255.255.255.0
iface wlan1 inet dhcp
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
bind-interfaces
except-interface=lo
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
	ssid="SquidDisco"
        psk=a54e9bac812a27aa7fee335d6971cf07e51d88132201e5cd11ea50d4b8c0f5fe
}
EOF

if $INSTALL_WIFI_DONGLE; then
      echo "installing additional networking packages"
      sudo apt install -y net-tools iw ifupdown ifplugd resolvconf hostapd haveged dnsmasq #libhavege2 may not exist?

      # disable the unique network interface names, go back to wlan0 & wlan1
      echo "disabling complex names"
      sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

      if ! grep -q wlan1 /etc/network/interfaces; then
	  echo "$wifi_interfaces_config" | sudo tee -a /etc/network/interfaces 1>/dev/null
      fi

      if ! egrep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
	  echo "$wifi_sysctl_config" | sudo tee -a /etc/sysctl.conf >/dev/null
      fi

      echo "$wifi_hostapd_config" | sudo tee /etc/hostapd/hostapd.conf >/dev/null
      echo "DAEMON_CONF=/etc/hostapd/hostapd.conf" | sudo tee -a /etc/default/hostapd >/dev/null
      sudo systemctl unmask hostapd.service
      sudo systemctl enable hostapd.service

      echo ""
      echo "the error about dnsmasq conflicting on port 53 is ignorable"
      echo "it'll be fixed when the system reboots with the new dnsmasq.conf file in place"
      echo ""

      if [ ! -e /etc/dnsmasq.conf.dist ]; then
      	  sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.dist &&
      	  echo "$wifi_dnsmasq_config" | sudo tee /etc/dnsmasq.conf &&
      	  sudo touch /etc/hosts.dnsmasq
      fi

      if [ ! -e /etc/systemd/system/dnsmasq.service ]; then
	  sudo cp -p /lib/systemd/system/dnsmasq.service /etc/systemd/system/dnsmasq.service
	  sudo sed -i~ '/^Requires=network.target/a After=network-online.target\nWants=network-online.target' /etc/systemd/system/dnsmasq.service
      fi

      if ! egrep -q wlan1 /etc/rc.local; then
	  if [[ $(tail -1 /etc/rc.local) = "exit 0" ]]; then
	      NEW_RC_LOCAL="$(head -n -1 /etc/rc.local; cat wifi_rclocal_config.txt; echo ''; echo 'exit 0')"
	      echo "$NEW_RC_LOCAL" | sudo tee /etc/rc.local >/dev/null
	  else
	      echo "Error: /etc/rc.local doesn't end with 'exit 0' line"
	  fi
      fi

      if ! grep -q "nameserver 8.8.8.8" /etc/resolvconf/resolv.conf.d/head; then
	  echo "adding google nameservers to head of default resolv.conf file"
	  echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolvconf/resolv.conf.d/head >/dev/null
	  echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolvconf/resolv.conf.d/head >/dev/null
      fi
      if ! egrep -q wlan1 /etc/default/ifplugd; then
	  sudo sed -i~ 's/INTERFACES=""/INTERFACES="wlan1"/' /etc/default/ifplugd
      fi

      echo "configuring wpa_supplicant"
      echo "$wpa_supplicant" | sudo tee /etc/wpa_supplicant.conf >/dev/null
      
      sudo cp -p wpa_supplicant.service.nuc10 /etc/systemd/system/wpa_supplicant.service
      sudo chown root:root /etc/systemd/system/wpa_supplicant.service

      # probably not needed
      sudo systemctl enable wpa_supplicant.service

      if [ ! -e /usr/local/jibo-station-wifi-service ]; then
	  sudo mkdir /usr/local/jibo-station-wifi-service
	  sudo chown prg /usr/local/jibo-station-wifi-service
	  git clone https://github.com/mitmedialab/jibo-station-wifi-service /usr/local/jibo-station-wifi-service
	  (cd /usr/local/jibo-station-wifi-service && JSWS_NO_REBOOT_PROMPT=1 ./install.sh)
      fi

      # disable Network Manager
      #systemctl stop NetworkManager  # nah! probably don't wanna do this
      for f in NetworkManager NetworkManager-wait-online.service NetworkManager-dispatcher.service network-manager.service; do
         echo "disabling $f"
         sudo systemctl disable $f
      done
fi


read -p "S02 NUC setup finished. Reboot? [y/n] " yn
case $yn in
    ""|[yY]|yes|Yes|YES )
	sudo reboot
	;;
    * )
	echo "not rebooting"
	;;
esac

exit


echo
echo -e "${G}Install and Log-in to RemotePC${N}"
FILE="remotepc.deb"
if [[ ! -f "$FILE" ]]; then
  wget  https://static.remotepc.com/downloads/rpc/310320/remotepc.deb #ubuntu 18+
fi
sudo apt install -y ./remotepc.deb


echo
echo -e "${G}Install and Log-in to TeamViewer${N}"
FILE="teamviewer_amd64.deb"
if [[ ! -f "$FILE" ]]; then
   # wget https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc 
   wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
fi


echo
echo "Done. Now run 'remotepc &' on another terminal. After logging in the first time, you need to check email and verify new device."

echo
echo "RemotePC login is in LastPass."
echo "RemotePC password is copied to clipboard for your convenience."
echo "u8sv5R&K8n4q" | xclip -selection c

read -n 1 -r -s -p $'When done, press any key to continue...\n\n'
