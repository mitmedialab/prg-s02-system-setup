#!/bin/bash

mkdir -p ~/catkin_ws/src

git clone https://github.com/mitmedialab/triadic-interaction-controller ~/catkin_ws/src/triadic-interaction-controller
git clone https://github.com/mitmedialab/jibo_msgs ~/catkin_ws/src/jibo_msgs

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

# install python3.7
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.7

sudo apt-get -y install python3-pip

#sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
#sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2

#sudo update-alternatives --config python3

python3.7 -m pip install pip
python3.7 -m pip install transitions pyyaml PyQt5

python3.5 -m pip install pip
python3.5 -m pip install transitions

# setup ROS
python3.7 -m pip install --extra-index-url https://rospypi.github.io/simple/ rospy rosbag

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

sudo -E apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt-get update
sudo apt-get install ros-kinetic-desktop-full

echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc

sudo apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential

sudo rosdep init
rosdep update

cd ~/catkin_ws; catkin_make
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc

