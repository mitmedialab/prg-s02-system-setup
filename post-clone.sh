#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./post-clone.sh NEW_HOSTNAME"
    exit
fi
#change hostname
default_hn="s02-n00-nuc-xxx"
target_hn=$1

echo $default_hn
echo $target_hn

sudo sed -i~ 's/'"$default_hn"'/'"$target_hn"'/' /etc/hostname
sudo sed -i~ 's/'"$default_hn"'/'"$target_hn"'/' /etc/hosts
sudo sed -i~ 's/'"$default_hn"'/'"$target_hn"'/' /etc/hostapd/hostapd.conf

echo 'Reboot? (y/n)' && read x && [[ "$x" == "y" ]] && sudo /sbin/reboot;
