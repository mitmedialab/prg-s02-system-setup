#!/bin/bash
git clone https://github.com/mitmedialab/triadic-interaction-controller ~/triadic-interaction-controller

FILE="zoom_amd64.deb"
if [[ ! -f "$FILE" ]]; then
    wget https://zoom.us/client/latest/zoom_amd64.deb 
fi
sudo apt install -y ./zoom_amd64.deb

FILE="VNC-Server-6.7.2-Linux-x64.deb"
if [[ ! -f "$FILE" ]]; then
    wget https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.2-Linux-x64.deb
fi
sudo apt install -y ./VNC-Server-6.7.2-Linux-x64.deb

sudo systemctl enable vncserver-x11-serviced --now
sudo vnclicensewiz

