docker rm -f s02-ros_usb-cam

echo
read -n 1 -r -s -p $'Connect USB camera and press any key to continue...\n'
echo
echo -e "${G}Run USB_CAM Docker Container${N}"
ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
while [ -z "$ROS_IMAGE_ID" ]; do
  echo "Waiting for docker image to finish download..."
  sleep 10s
  ROS_IMAGE_ID=`sudo docker images --filter=reference=docker-registry.jibo.media.mit.edu:5000/mitprg/ros-bundle --format "{{.ID}}"`
  ROS_IMAGE_ID=`echo $ROS_IMAGE_ID | awk '{print $1}'`
done
echo $ROS_IMAGE_ID

sudo docker run -d -it --name=s02-ros_usb-cam --device=/dev/video0:/dev/video0 --restart=always --network=host \
         --workdir=/root/projects $ROS_IMAGE_ID  python3.6 -m s02-launch-scripts.scripts.start_usb_cam_launcher 

# sudo docker run -d -it --restart=unless-stopped --device=/dev/snd:/dev/snd \
#         --network=host --workdir=/root/catkin_ws/src/unity-game-controllers \
#         $ROS_IMAGE_ID python3.6 -m scripts.utils_scripts.start_mic_launcher.py 
