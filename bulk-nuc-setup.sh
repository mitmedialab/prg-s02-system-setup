source s02-machine-commands.sh

n00_addr=(
"192.168.41.227"
"192.168.41.144"
)

n02_addr=(
"10.111.28.49"
"10.111.28.50"
"10.111.28.51"
"10.111.28.52"
"10.111.28.58"
"10.111.28.73"
"10.111.28.62"
"10.111.28.64"
)

n01_addr=(
"10.111.16.49"
"10.111.16.50"
"10.111.16.51"
#"10.111.16.52"
"10.111.16.34"
"10.111.16.58"
"10.111.16.60"
"10.111.16.62"
#"10.111.16.64"
#"10.111.16.63"
)

if [ $1 == 'n01' ]; then
  addr=("${n01_addr[@]}")
elif [ $1 == 'n02' ]; then
  addr=("${n02_addr[@]}")
elif [ $1 == 'n00' ]; then
  addr=("${n00_addr[@]}")
else
  echo 'n00, n01 or n02?'
  exit
fi

echo ${!addr[@]}

for i in ${!addr[@]}; do
 nuc_ip_addr=${addr[$i]}
 echo
 echo $i, $nuc_ip_addr
 ssh_nuc cat /etc/hostname
 #ssh_nuc mkdir -p /home/prg/rosbags/data-tardis
 #ssh_nuc ls rosbags

 #install_prg_ssh_keys
 #ssh_nuc ls rosbags 
 #ssh_nuc ls /etc/NetworkManager/system-connections
 #required_ssid="PRG-MIT-8"
 #setup_wifi
 #setup_jibo_audio_streaming
 #ssh_nuc 'ps aux | grep jibo'
 #ssh_nuc ifconfig eno1
 #ssh_nuc sudo reboot

 #ssh_nuc mkdir -p /home/prg/.docker
 #ssh_nuc sudo chown prg:prg /home/prg/.docker -R
 #ssh_nuc sudo chmod g+rwx "/home/prg/.docker" -R
  
 #ssh_nuc docker update --restart=no usb_cam
 #ssh_nuc docker rm -f usb_cam &&
 #ssh_nuc docker run -d -it --name=s02-ros_usb-cam --device=/dev/video0:/dev/video0 --restart=always --network=host --workdir=/root/projects 746be3a4fe13  python3.6 -m s02-storybook.scripts.launcher_scripts.start_usb_cam_launcher

 ssh_nuc docker system prune -a
 ssh_nuc docker ps -a
 ssh_nuc docker images

 #ssh_nuc docker ps
 #ssh_nuc 'v="30 7 \* \* \*      /sbin/reboot" && echo "$v" | sudo tee -a /var/spool/cron/crontabs/root'
 #ssh_nuc 'v="10 11 * * *      /sbin/reboot" && echo "$v" | sudo tee -a /var/spool/cron/crontabs/root'
 #ssh_nuc sudo cat /var/spool/cron/crontabs/root

 #scp s02-docker_monitor.sh prg@$nuc_ip_addr:/home/prg/
 #ssh_nuc sudo mv s02-docker_monitor.sh /usr/local/bin/
done
