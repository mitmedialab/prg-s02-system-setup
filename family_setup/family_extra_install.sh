#!/bin/bash

# secure boot should be disabled or, follow the instructions while installing this package
sudo apt-get install -y v4l2loopback-dkms

# zoom interface is blocked - it needs OS upgrade 
sudo apt-get upgrade


#setting up gstreamer 
sudo apt-get -y install gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly libxml2 libpcap0.8 libaudit1 libnotify4 libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

#setting up gstreamer for gscam 
sudo apt-get -y install gstreamer0.10-plugins-good gstreamer0.10-tools gstreamer0.10-x gstreamer0.10-plugins-base gstreamer0.10-plugins-good  libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev


#setting up pulseaudio
sudo apt-get install pulseaudio-utils

#setting up gscam ros package
rosdep install gscam
sudo apt-get install ros-kinetic-gscam
sudo mv ~/family_video.launch /opt/ros/kinetic/share/gscam 

#setting up audio ros package
cd ~/catkin_ws/src
git clone https://github.com/ros-drivers/audio_common.git
rosdep install audio_common
mv ~/audio_capture.cpp ~/catkin_ws/src/audio_common/audio_capture/src
mv ~/family_audio.launch ~/catkin_ws/src/audio_common/audio_capture/launch

cd ~/catkin_ws
#Hae Won said to have this separate 
#catkin_make
source ~/catkin_ws/devel/setup.bash


#setup virtual drivers module at boot
#video virtual module 
sudo bash -c 'cat > /etc/modules-load.d/v4l2loopback.conf <<EOL
v4l2loopback 
EOL'

sudo bash -c 'cat >  /etc/modprobe.d/v4l2loopback.conf <<EOL
options v4l2loopback video_nr=7 card_label="family project" 
EOL'



#audio virtual module 
sudo bash -c 'cat >>  /etc/pulse/default.pa <<EOL
#audio virtual module 
load-module module-null-sink sink_name=Family
load-module module-loopback sink=Family
EOL'










