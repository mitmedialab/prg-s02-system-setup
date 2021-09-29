docker rm -f s02-ros_usb-cam
docker rm -f s02-ros_roscore
docker rm -f s02-ros_rosbridge
docker rm -f data-tardis_data-tardis


echo
read -n 1 -r -s -p $'Connect USB camera and press any key to continue...\n'
echo
echo -e "${G}Run Local ROS Docker Containers${N}"
ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
while [ -z "$ROS_IMAGE_ID" ]; do
  echo "Waiting for ros docker image to finish download..."
  sleep 10s
  ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
  ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
done
echo $ROS_IMAGE_ID

sudo docker run -d -it --name=s02-ros_usb-cam --device=/dev/video0:/dev/video0 --restart=always --network=host \
         --workdir=/root/projects $ROS_IMAGE_ID  python3.6 -m s02-launch-scripts.scripts.start_usb_cam_launcher

sudo docker run -d -it --name=s02-ros_roscore --restart=always --network=host $ROS_IMAGE_ID roscore
sudo docker run -d -it --name=s02-ros_rosbridge --restart=always --network=host $ROS_IMAGE_ID roslaunch rosbridge_server rosbridge_websocket.launch
#sudo docker run -d -it --name=s02-ros_game-launcher --restart=on-failure --network=host --workdir=/root/projects --volume=/tmp/rosbags:/root/projects/rosbags $ROS_IMAGE_ID python3.6 -m s02-storybook.scripts.launcher_scripts.start_game_launcher

# sudo docker run -d -it --restart=unless-stopped --device=/dev/snd:/dev/snd \
#         --network=host --workdir=/root/catkin_ws/src/unity-game-controllers \
#         $ROS_IMAGE_ID python3.6 -m scripts.utils_scripts.start_mic_launcher.py 

echo -e "${G}Run Local Synology Data Tardis Container${N}"
TARDIS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/prg-s02-synology-data-tardis --format "{{.ID}}"`
TARDIS_IMAGE_ID=`echo $TARDIS_IMAGE_ID | awk '{print $1}'`
while [ -z "$TARDIS_IMAGE_ID" ]; do
  echo "Waiting for data tardis image to finish download..."
  sleep 10s
  TARDIS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/prg-s02-synology-data-tardis --format "{{.ID}}"`
  TARDIS_IMAGE_ID=`echo $TARDIS_IMAGE_ID | awk '{print $1}'`
done
echo $TARDIS_IMAGE_ID

sudo docker run -d -it --name=data-tardis_data-tardis --restart=always --network=host --volume=/home/prg/rosbags/data-tardis:/data/tardis \
      --env HOST_HOSTNAME=$HOSTNAME	\
      --env ETCO_synology_address_n00='prg-synology-1.media.mit.edu'	\
      --env ETCO_synology_address_n01='10.111.16.41'	\
      --env ETCO_synology_address_n02='10.111.28.41'	\
      --env ETCO_synology_password='9^jvH%5cU6#E'	\
      --env ETCO_synology_username='data-tardis'	\
      --env ETCO_synology_port='5000'             \
      --env ETCO_synology_directory='/DataTardis'	\
      --env ETCO_local_directory='/data/tardis'	\
      --env ETCO_check_periodicity_ms='60000'	\
      --env ETCO_delete_after_upload='1' $TARDIS_IMAGE_ID 
