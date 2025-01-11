#!/usr/bin/env bash

for v in http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
do
  eval "test -v $v -a -z $"$v" && unset $v"
done

source /opt/ros//${ROS_DISTRO}/setup.bash

set -eu
set -v

# set -u のために source install/setup.bash でunbound variableになる問題の回避
export COLCON_TRACE=
export AMENT_TRACE_SETUP_FILES=
export AMENT_PYTHON_EXECUTABLE=
export COLCON_PREFIX_PATH=
export COLCON_PYTHON_EXECUTABLE=
export CMAKE_PREFIX_PATH=

# pip ReadTimeoutErrorの対策
# https://www.infocircus.jp/2020/06/30/pip-readtimeouterror-certbot-auto/
export PIP_DEFAULT_TIMEOUT=1000

sudo apt-get update -q

sudo apt-get upgrade -yq

# 前処理
mkdir -p ~/airobot_ws/src
rosdep update

# Whisperはnumpy 1.25.0未満を，YOLOはnumpy 2未満を求めている
pip3 install 'numpy<1.25.0'

# DDS
sudo apt -y install ros-${ROS_DISTRO}-rmw-cyclonedds-cpp
echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc

# colcon
mkdir ~/.colcon
cat << __EOF__ > ~/.colcon/defaults.yaml
{
    "build": {
        "symlink-install": true
    }
}
__EOF__

# 第1章

# 第2章
cd ~/airobot_ws/src
git clone https://github.com/AI-Robot-Book-Humble/chapter2
sudo apt-get -y install xterm
sudo cp ~/airobot_ws/src/chapter2/turtlesim_launch/mysim.launch.py /opt/ros/${ROS_DISTRO}/share/turtlesim/launch

# # 第3章
sudo apt-get -y install portaudio19-dev
sudo apt-get -y install pulseaudio
pip3 install pyaudio
pip3 install SpeechRecognition
pip3 install SpeechRecognition[whisper-local] soundfile
pip3 install gTTS
sudo apt-get -y install mpg123
pip3 install mpg123
cd ~/airobot_ws/src
git clone https://github.com/AI-Robot-Book-Humble/chapter3

# 第4章
sudo apt-get -y install ros-${ROS_DISTRO}-navigation2
sudo apt-get -y install ros-${ROS_DISTRO}-nav2-bringup
sudo apt-get -y install ros-${ROS_DISTRO}-slam-toolbox
sudo apt-get -y install ros-${ROS_DISTRO}-teleop-tools
sudo apt-get -y install ros-${ROS_DISTRO}-cartographer
sudo apt-get -y install ros-${ROS_DISTRO}-cartographer-ros
sudo apt-get -y install ros-${ROS_DISTRO}-dynamixel-sdk
sudo apt-get -y install ros-${ROS_DISTRO}-xacro
sudo apt-get -y install ros-${ROS_DISTRO}-ament-cmake-clang-format
pip3 install matplotlib seaborn
cd ~/airobot_ws/src/
# git clone -b humble-devel https://github.com/ROBOTIS-GIT/turtlebot3.git
git clone -b humble-devel https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
# git clone -b humble-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
git clone https://github.com/AI-Robot-Book-Humble/chapter4.git
git clone https://github.com/AI-Robot-Book-Humble/turtlebot3_happy_mini.git
echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc
echo "export TURTLEBOT3_MODEL=happy_mini" >> ~/.bashrc
cp -r ~/airobot_ws/src/chapter4/map ~

# 第5章
pip3 install opencv-contrib-python
sudo apt-get -y install ros-${ROS_DISTRO}-vision-opencv
sudo apt-get -y install ros-${ROS_DISTRO}-usb-cam
sudo apt-get -y install ros-${ROS_DISTRO}-realsense2-camera
pip3 install ultralytics
cd ~/airobot_ws/src
git clone https://github.com/JMU-ROBOTICS-VIVA/ros2_aruco
git clone https://github.com/AI-Robot-Book-Humble/chapter5

# 第6章
sudo apt-get -y install ros-${ROS_DISTRO}-joint-state-publisher-gui
cd ~/airobot_ws/src
git clone https://github.com/AI-Robot-Book-Humble/crane_plus
sudo apt-get -y install ros-${ROS_DISTRO}-tf-transformations
# 上のコマンドでpython3-transforms3dがインストールされ，古いバージョンのtransforms3dがnumpyバージョン2と問題を起こす．
# https://github.com/matthew-brett/transforms3d/issues/65
pip3 install transforms3d --upgrade
echo 'KERNEL=="ttyUSB*", DRIVERS=="ftdi_sio", MODE="0666", ATTR{device/latency_timer}="1"' > ~/99-ftdi_sio.rules
sudo mv ~/99-ftdi_sio.rules /etc/udev/rules.d/
git clone https://github.com/AndrejOrsula/pymoveit2
git clone https://github.com/AI-Robot-Book-Humble/chapter6

# 第7章
sudo apt-get install -y ros-${ROS_DISTRO}-smach
sudo apt-get install -y ros-${ROS_DISTRO}-executive-smach
cd ~/airobot_ws/src
git clone -b 4.0.0 https://github.com/FlexBE/flexbe_behavior_engine
git clone https://github.com/AI-Robot-Book-Humble/flexbe_webui
git clone https://github.com/AI-Robot-Book-Humble/chapter7
cd ~/airobot_ws/src/flexbe_webui
pip3 install -r requires.txt
echo "export WORKSPACE_ROOT=~/airobot_ws" >> ~/.bashrc

# 付録B
cd ~/airobot_ws/src
git clone https://github.com/AI-Robot-Book-Humble/appendixB

# 付録E
sudo apt-get -y install ros-${ROS_DISTRO}-tf-transformations
# 上のコマンドでpython3-transforms3dがインストールされ，古いバージョンのtransforms3dがnumpyバージョン2と問題を起こす．
# https://github.com/matthew-brett/transforms3d/issues/65
pip3 install transforms3d --upgrade
cd ~/airobot_ws/src
git clone https://github.com/AI-Robot-Book-Humble/appendixE


# まとめてビルド
cd ~/airobot_ws
rosdep install --default-yes --from-paths src --ignore-src
# pymoveit2のみ別のオプションを指定してビルド
colcon build --packages-select pymoveit2 --cmake-args "-DCMAKE_BUILD_TYPE=Release"
colcon build --packages-ignore pymoveit2
set +v
source install/setup.bash
set -v

## Ignition Gazeboのモデルのダウンロード
ign fuel download -v 4 -u https://fuel.gazebosim.org/1.0/openrobotics/models/sun
ign fuel download -v 4 -u https://fuel.gazebosim.org/1.0/openrobotics/models/ground%20plane
ign fuel download -v 4 -u https://fuel.gazebosim.org/1.0/openrobotics/models/wood%20cube%205cm
ign fuel download -v 4 -u https://fuel.gazebosim.org/1.0/openrobotics/models/table

# Gazeboのモデルのダウンロード
# https://gist.github.com/Tiryoh/bf24f61992bfa8e32f2e75fc0672a647
function download_model(){
	if [[ -d $HOME'/.gazebo/models/'$1 ]]; then
		echo model $1 is ready.
	else
		wget -l1 -np -nc -r "http://models.gazebosim.org/"$1 --accept=gz
	fi
}

mkdir -p ~/.gazebo/models && cd ~/.gazebo/models
cd /tmp 
TMPDIR=$(mktemp -d tmp.XXXXXXXXXX) 
cd $TMPDIR 
download_model sun
download_model ground_plane
download_model mailbox
download_model cafe_table
download_model first_2015_trash_can
download_model table_marble
if [[ -d "models.gazebosim.org" ]]; then
	cd "models.gazebosim.org"
	for i in *; do tar -zvxf "$i/model.tar.gz"; done
	cp -vfR * ~/.gazebo/models/
fi
rm -rf $TMPDIR

# 後処理
echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
echo "source ~/airobot_ws/install/setup.bash" >> ~/.bashrc

set +u

sudo rm -rf /var/lib/apt/lists/*

pip3 cache purge
