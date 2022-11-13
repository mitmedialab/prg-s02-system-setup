sed -i 's/ros-bundle:triadic-interaction/ros-bundle:triadic-interaction-nuc10/g' /home/prg/prg-s02-system-setup/src/triadic-interaction
sed -i 's/ros-bundle:triadic-interaction/ros-bundle:triadic-interaction-nuc10/g' /home/prg/prg-s02-system-setup/src/dyadic-interaction


echo "load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket" >>  /etc/pulse/default.pa
echo -e "default-server = unix:/tmp/pulseaudio.socket \nautospawn = no \ndaemon-binary = /bin/true \nenable-shm = false" >>  /etc/pulse/client.conf

echo "options v4l2loopback video_nr=7,8 card_label=\"family project\",\"family project 2\"" > /etc/modprobe.d/v4l2loopback.conf

git pull https://github.com/mitmedialab/jibo-station-wifi-service /usr/local/jibo-station-wifi-service

cd  /usr/local/jibo-station-wifi-service

systemctl stop jibo-station-wifi-service.service

./install.sh
