#!/bin/bash

G='\033[0;32m'
N='\033[0m'

source s06-empathy-interactions/s06-machine-commands.sh

if [[ ! -e ./rc-local.service ]]; then
    echo "run this in the top directory of the checked-out prg-s02-system-setup repo"
    exit 1
fi

echo
echo -e "${G}Set user to execute sudo commands without password${N}"
line="$USER ALL=(ALL) NOPASSWD: ALL"
sudo grep -qxF "$line" /etc/sudoers || sudo sed -i '27i '"$line"'' /etc/sudoers  &&
echo "OK"


SWARM_TOKEN="SWMTKN-1-3zc9c3xnf20ue7mgkhu8then3lf0kdhdg27i7qk7naurrjnlvv-8k38rf1t1oiwo30lhx1rpcuq5 18.27.79.165:2377"  # buildroot.media.mit.edu

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
echo -e "${G}Setup Cron Jobs and Reboot Timers${N}"
# reboot_cmd="00 7 \* \* \*      /sbin/reboot"
# if ! sudo grep -q "\*/1 \* \* \* \*    /bin/bash /usr/local/jibo-station-wifi-service/check_and_run.sh" /var/spool/cron/crontabs/root; then 
#    echo -e "$(sudo crontab -u root -l)\n*/1 * * * *    /bin/bash /usr/local/jibo-station-wifi-service/check_and_run.sh" | sudo crontab -u root -
# fi

if ! sudo grep -q "\*/1 \* \* \* \* \+/bin/systemctl start docker" /var/spool/cron/crontabs/root; then 
   echo -e "$(sudo crontab -u root -l)\n*/1 * * * *    /bin/systemctl start docker" | sudo crontab -u root -
fi

#if ! sudo grep -q "00 7 \* \* \* \+/bin/systemctl restart docker" /var/spool/cron/crontabs/root; then 
#   echo -e "$(sudo crontab -u root -l)\n00 7 * * *    /bin/systemctl restart docker" | sudo crontab -u root -
#fi

#if ! sudo grep -q "#00 7 \* \* \* \+/sbin/reboot" /var/spool/cron/crontabs/root; then 
#   echo -e "$(sudo crontab -u root -l)\n#00 7 * * *    /sbin/reboot" | sudo crontab -u root -
#fi

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
   echo "adding jocelyn's ssh key"
   sudo grep -qxF "$jocelyns_ssh_key" ~/.ssh/authorized_keys || echo "$jocelyns_ssh_key" >> ~/.ssh/authorized_keys
   echo "adding audrey's ssh key"
   sudo grep -qxF "$audreys_ssh_key" ~/.ssh/authorized_keys || echo "$audreys_ssh_key" >> ~/.ssh/authorized_keys
   echo "adding jon's ssh key"
   sudo grep -qxF "$jons_ssh_key" ~/.ssh/authorized_keys || echo "$jons_ssh_key" >> ~/.ssh/authorized_keys

echo
echo -e "${G}apt-get update${N}"
sudo apt-get update &&

echo
echo -e "${G}install packages${N}"
sudo apt-get -y install build-essential vim-gtk3 apt-transport-https ca-certificates curl gnupg software-properties-common xclip wget lsb-release libminizip1 libxcb-xinerama0 emacs-nox htop make fping tree &&

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
chmod +x ~/Desktop/JiboChromium.desktop
echo "OK"

echo
echo -e "${G}Create Rosbag Data Tardis folder${N}"
mkdir -p ~/rosbags/data-tardis
echo "OK"

# Docker setup
echo
echo -e "${G}Add Docker's official GPG key${N}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&

echo
echo -e "${G}Setup Docker stable repository${N}"
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&

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
echo -e "${G}Fix create 'New Document' right click menu${N}"
touch ~/Templates/"New Document"

echo
echo -e "${G}Set up ALSA configuration${N}"
sudo -s <<EOF
echo "pcm.usbmic44-1 {
    type dsnoop
    ipc_key 466752
    ipc_perm 0666
    slave {
        pcm \"hw:CARD=AC44,DEV=0\"
        channels 1
        rate 32000
    }
    hint {
        description \"LOOPBACK_DEV_44\"
    }
}

pcm.usbmic44-2 {
    type dsnoop
    ipc_key 466752
    ipc_perm 0666
    slave {
        pcm \"hw:CARD=AC44,DEV=0\"
        channels 1
        rate 32000
    }
    hint {
        description \"LOOPBACK_DEV_44_2\"
    }
}

pcm.usbmic404-1 {
    type dsnoop
    ipc_key 485616
    ipc_perm 0666
    slave {
        pcm \"hw:CARD=CODEC,DEV=0\"
        channels 1
        rate 32000
    }
    hint {
        description \"LOOPBACK_DEV_404\"
    }
}

pcm.usbmic404-2 {
    type dsnoop
    ipc_key 485616
    ipc_perm 0666
    slave {
        pcm \"hw:CARD=CODEC,DEV=0\"
        channels 1
        rate 32000
    }
    hint {
        description \"LOOPBACK_DEV_404_2\"
    }
}" > /etc/asound.conf && echo "OK"
EOF

echo -e "${G}Create s06 Video folder${N}"
mkdir -p ~/s06-empathy-interaction/empathy_videos/uploaded && echo "OK"

echo
echo -e "${G}Setup VPN${N}"
if [[ ! -d ~/vpn ]]; then
   tar zxvf vpn-s02.tar.gz -C ~/
   (cd ~/vpn && sudo ./install.sh)
fi
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
        ssid="PRG-MIT"
        psk=eaaf33ae234217c783d8e1c21eb6e1b1b4534171a0aa8befa386b2d55a84bac0
}
EOF

if $INSTALL_WIFI_DONGLE; then
      echo "installing additional networking packages"
      sudo apt install -y net-tools iw ifupdown ifplugd resolvconf hostapd haveged dnsmasq silversearcher-ag

      # disable the unique network interface names, go back to wlan0 & wlan1
      echo "disabling complex names"
      sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

      if ! grep -q wlan0 /etc/network/interfaces; then
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

      if ! egrep -q wlan0 /etc/rc.local; then
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
      #echo "You will have to manually enter jibo-station-wifi-service and change interface to wlan0 instead of wlan1"

      # disable Network Manager
      #systemctl stop NetworkManager  # nah! probably don't wanna do this
      for f in NetworkManager NetworkManager-wait-online.service NetworkManager-dispatcher.service network-manager.service; do
         echo "disabling $f"
         sudo systemctl disable $f
      done
fi


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

read -p "S06 NUC setup finished. Reboot? [y/n] " yn
case $yn in
    ""|[yY]|yes|Yes|YES )
        sudo reboot
        ;;
    * )
        echo "not rebooting"
        ;;
esac


echo "All finished!"
exit
