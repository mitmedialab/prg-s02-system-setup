#!/bin/bash

FILE="zoom_amd64.deb"
if [[ ! -f "$FILE" ]]; then
    wget https://zoom.us/client/latest/zoom_amd64.deb 
fi
sudo apt install -y ./zoom_amd64.deb

# FILE="VNC-Server-6.7.2-Linux-x64.deb"
# if [[ ! -f "$FILE" ]]; then
#     wget https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.2-Linux-x64.deb
# fi
# sudo apt install -y ./VNC-Server-6.7.2-Linux-x64.deb

#sudo systemctl enable vncserver-x11-serviced --now
#sudo vnclicensewiz

# install python3.7
wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz
sudo tar xzf Python-3.7.4.tgz
cd Python-3.7.4/
sudo ./configure
sudo make
sudo make install
echo "alias python3=python3.7" >> ~/.bashrc
echo "alias pip3=pip3.7" >> ~/.bashrc
echo "alias python3=python3.7" >> ~/.bash_aliases
echo "alias pip3=pip3.7" >> ~/.bash_aliases


# Install Python3.9
# sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
# wget https://www.python.org/ftp/python/3.9.12/Python-3.9.12.tgz
# tar -xf Python-3.9.12.tgz
# cd Python-3.9.12
# ./configure --enable-optimizations
# make -j 12
# sudo make altinstall

# Install pip3.9
#sudo apt-get install python3.9-pip
#sudo python3.9 -m pip install -upgrade pip
sudo apt-get install python3-yaml python3-dev
#sudo apt-get -y install python3-pip python3-pyqt5 python3-pyqt5.qtmultimedia python3-pandas

#sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
#sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2

#sudo update-alternatives --config python3


# setup ROS
#python3.9 -m pip install --extra-index-url https://rospypi.github.io/simple/ rospy rosbag

#python3.7 -m pip install pip
#python3.7 -m pip install transitions PyQt5

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

sudo -E apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt-get update
sudo apt-get install ros-kinetic-desktop-full

echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc

sudo apt-get -y install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential

sudo apt-get -y install python3-catkin-pkg-modules python3-rospkg-modules

sudo rosdep init
rosdep update

pip3 install rospkg catkin_pkg rosdep rosinstall_generator rosinstall wstool vcstools catkin_tools
pip3 install psutil
pip3 install click
pip3 install PyAutoGUI
pip3 install Pillow
pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
pip3 install pyqt5
pip3 install pandas
pip3 install transitions
pip3 install PyYAML
pip3 install -U rospkg

#### PACKAGES for the affect modeling ros
pip3 install mxnet==1.9.1
pip3 install gluoncv

mkdir -p ~/catkin_ws/src

git clone -b final-study-2022 https://github.com/mitmedialab/triadic-interaction-controller ~/catkin_ws/src/triadic-interaction-controller
git clone -b controller https://github.com/mitmedialab/parent-child-reading-story-corpus.git ~/catkin_ws/src/parent-child-reading-story-corpus
git clone https://github.com/mitmedialab/jibo_msgs ~/catkin_ws/src/jibo_msgs
git clone https://github.com/ybkim95/affect_modeling_ros.git


mkdir -p ~/catkin_ws/src/output_data/affect_log
mkdir -p ~/catkin_ws/src/output_data/annotation_log
mkdir -p ~/catkin_ws/src/output_data/session_info
mkdir -p ~/catkin_ws/src/output_data/tablet_log
mkdir -p ~/catkin_ws/src/output_data/interaction_log
mkdir -p ~/catkin_ws/src/output_data/jibo_speech_change
mkdir -p ~/catkin_ws/src/output_data/videos

## compile ros messages (e.g., jibo msgs, triadic msgs, audio msgs)
cd ~/catkin_ws/
catkin_make

echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc

pip3 install pyyaml transitions

# install sublime 
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
sudo apt update
sudo apt install sublime-text
