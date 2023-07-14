G='\033[0;32m'
N='\033[0m'


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
   fi
fi