#!/bin/bash

FILE="zoom_amd64.deb"
if [[ ! -f "$FILE" ]]; then
    wget https://zoom.us/client/latest/zoom_amd64.deb 
fi
sudo apt install -y ./zoom_amd64.deb


# install python3.7
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
FILE="Python-3.7.4.tgz"
if [[ ! -f "$FILE" ]]; then
	wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz
fi
sudo tar xzf Python-3.7.4.tgz
cd Python-3.7.4/
sudo ./configure
sudo make
sudo make install
echo "alias python3=python3.7" >> ~/.bashrc
echo "alias pip3=pip3.7" >> ~/.bashrc
echo "alias python3=python3.7" >> ~/.bash_aliases
echo "alias pip3=pip3.7" >> ~/.bash_aliases

# source ~/.bashrc
pip3 install --upgrade pip





# setup ROS
echo -e "\n!!!!!!!!! SET UP ROS\n"

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

sudo -E apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt-get update
sudo apt-get install ros-kinetic-desktop-full

echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc

sudo apt-get -y install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential

sudo apt-get -y install python3-catkin-pkg-modules python3-rospkg-modules

sudo rosdep init
sudo rosdep update

#### PACKAGES for the triadic controller
echo -e "\n!!!!!!!!! PYTHON PACKAGES for triadic controller\n"
sudo pip3 install pyqt5 PyYAML
sudo pip3 install rospkg catkin_pkg rosdep rosinstall_generator rosinstall wstool vcstools catkin_tools
sudo pip3 install psutil click PyAutoGUI Pillow pandas transitions
sudo pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
sudo pip3 install -U rospkg

#### PACKAGES for the affect modeling ros
sudo pip3 install mxnet==1.9.1
sudo pip3 install gluoncv


### SET UP REPOS
echo -e "\n!!!!!!!!! SET UP REPOS\n"
mkdir -p ~/catkin_ws/src

git config --global credential.helper store

git clone -b final-study-2022 https://github.com/mitmedialab/triadic-interaction-controller ~/catkin_ws/src/triadic-interaction-controller
git clone -b controller https://github.com/mitmedialab/parent-child-reading-story-corpus.git ~/catkin_ws/src/parent-child-reading-story-corpus
git clone https://github.com/mitmedialab/jibo_msgs ~/catkin_ws/src/jibo_msgs
git clone https://github.com/ybkim95/affect_modeling_ros.git ~/catkin_ws/src/affect_modeling_ros
git clone -b final-rm https://github.com/mitmedialab/triadic-modeling.git ~/catkin_ws/src/triadic-modeling


mkdir -p ~/catkin_ws/src/output_data/affect_log
mkdir -p ~/catkin_ws/src/output_data/annotation_log
mkdir -p ~/catkin_ws/src/output_data/session_info
mkdir -p ~/catkin_ws/src/output_data/tablet_log
mkdir -p ~/catkin_ws/src/output_data/interaction_log
mkdir -p ~/catkin_ws/src/output_data/jibo_speech_change
mkdir -p ~/catkin_ws/src/output_data/videos

## compile ros messages (e.g., jibo msgs, triadic msgs, audio msgs)
cd ~/catkin_ws/
sudo chown $USER: -R /home/prg/catkin_ws
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

echo "cd ~/catkin_ws/src/triadic-interaction-controller" >> ~/.bashrc
