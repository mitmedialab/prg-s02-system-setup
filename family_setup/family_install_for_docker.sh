#!/bin/bash



# secure boot should be disabled or, follow the instructions while installing this package
sudo apt-get install -y v4l2loopback-dkms


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

# create a link to run triadic 
echo "ln -s /home/prg/prg-s02-system-setup/src/triadic-interaction triadic-interaction" >> ~/.bashrc

