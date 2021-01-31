#!/bin/bash
#change hostname
default_hn="s02-n00-nuc-110"
target_hn="s02-n00-nuc-xxx"

sudo sed -i 's/$default_hn/$target_hn/' /etc/hostname
sudo sed -i 's/$default_hn/$target_hn/' /etc/hosts
sudo sed -i 's/$default_hn/$target_hn/' /etc/hostapd/hostapd.conf

echo 'Reboot? (y/n)' && read x && [[ "$x" == "y" ]] && /sbin/reboot; 


