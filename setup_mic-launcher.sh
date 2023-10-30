INSTALL_MICROPHONE_CONTAINER=true
while true; do
    read -p "Proceed with setting up Microphone Launcher docker container? [Y/n]: " yn
    case $yn in
        [Nn]* ) INSTALL_MICROPHONE_CONTAINER=false; echo "Please run ./setup_mic_launcher.sh later"; break;;
        [Yy]*|"" ) read -n 1 -r -s -p  "Okay, setting up MICROPHONE LAUNCHER docker container. Connect USB microphone and hit enter..."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if $INSTALL_MICROPHONE_CONTAINER; then
	docker rm -f s02-ros_microphone-launcher
	
	echo
	echo -e "${G}Run MICROPHONE_LAUNCHER Docker Container${N}"
	ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
	ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
	while [ -z "$ROS_IMAGE_ID" ]; do
		echo "Waiting for docker image to finish download..."
  		sleep 10s
  		ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
  		ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
	done
	echo $ROS_IMAGE_ID

	sudo docker run -d -it --name=s02-ros_microphone-launcher --network=host --restart=always --workdir=/root/projects --device=/dev/snd:/dev/snd \
	--volume=/home/prg/rosbags:/root/projects/rosbags $ROS_IMAGE_ID python3.8 -m s02-launch-scripts.scripts.start_asr_launcher 
fi

# sudo docker run -d -it --restart=unless-stopped --device=/dev/snd:/dev/snd \
#         --network=host --workdir=/root/catkin_ws/src/unity-game-controllers \
#         $ROS_IMAGE_ID python3.6 -m scripts.utils_scripts.start_mic_launcher.py 
