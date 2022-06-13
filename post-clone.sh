#!/bin/bash

G='\033[0;32m'
N='\033[0m'

if [ -z "$1" ]; then
    echo "Usage: ./post-clone.sh NEW_HOSTNAME"
    exit
fi

# change hostname
echo -e "${G}Updating Hostname${N}"
default_hn="s02-n00-nuc-xxx"
target_hn=$1

echo $default_hn
echo $target_hn

sudo sed -i~ 's/'"$default_hn"'/'"$target_hn"'/' /etc/hostname
sudo sed -i~ 's/'"$default_hn"'/'"$target_hn"'/' /etc/hosts
sudo sed -i~ 's/'"$default_hn"'/'"$target_hn"'/' /etc/hostapd/hostapd.conf

# apply change of hostname
sudo hostname $target_hn
new_hn=`hostname`
if [[ "$new_hn" == "$target_hn" ]];
then
    echo
    echo "Hostname successfully changed to: $new_hn"
else
    echo "Hostname change unsuccessful. Check errors and rerun."
    exit
fi

# leave and rejoin swarm
echo
echo -e "${G}Joining swarm as a new node${N}"
./switch_swarm.sh

# re-setup usb cam docker container
echo
echo -e "${G}Setup USB CAM docker container${N}"
sudo bash setup_usb-cam.sh 

# setup docker restart cron job
echo
echo -e "${G}Setup Restart Docker Timer${N}"
if ! sudo grep -q "00 7 \* \* \*    /bin/systemctl restart docker" /var/spool/cron/crontabs/root; then 
   echo -e "$(sudo crontab -u root -l)\n00 7 * * *    /bin/systemctl restart docker" | sudo crontab -u root -
fi
echo -e "$(sudo crontab -u root -l | grep -v '/sbin/reboot')" | sudo crontab -u root -
echo
sudo cat /var/spool/cron/crontabs/root
echo


# install remotepc and teamviewer
echo
echo -e "${G}Install and Log-in to RemotePC${N}"
FILE="remotepc.deb"
if [[ ! -f "$FILE" ]]; then
   wget  https://static.remotepc.com/downloads/rpc/310320/remotepc.deb
   sudo apt install -y ./remotepc.deb
fi


echo
echo -e "${G}Install and Log-in to TeamViewer${N}"
FILE="TeamViewer2017.asc"
if [[ ! -f "$FILE" ]]; then
   wget https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc 
   sudo apt-key add TeamViewer2017.asc &&
   sudo sh -c 'echo "deb http://linux.teamviewer.com/deb stable main" >> /etc/apt/sources.list.d/teamviewer.list' &&
   sudo apt update &&
   sudo apt install -y teamviewer
fi

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

echo 'Reboot? (y/n)' && read x && [[ "$x" == "y" ]] && sudo /sbin/reboot;
