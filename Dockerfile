# Copyright 2024, 2025 MASUTANI Yasuhiro
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# This Dockerfile is based on https://github.com/Tiryoh/docker-ros2-desktop-vnc
# which is released under the Apache-2.0 license.

FROM ubuntu:jammy-20240808

ARG TARGETPLATFORM
LABEL maintainer="MASUTANI Yasuhiro <ai-robot-book@googlegroups.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

# Upgrade OS
RUN apt-get update -q && \
    apt-get upgrade -y && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Install Ubuntu Mate desktop
RUN apt-get update -q && \
    apt-get install -y \
        ubuntu-mate-desktop && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Add Package
RUN apt-get update && \
    apt-get install -y \
        tigervnc-standalone-server tigervnc-common \
        supervisor wget curl gosu git sudo python3-pip tini \
        build-essential vim sudo lsb-release locales \
        bash-completion tzdata terminator \
        dos2unix \
        apt-utils \
        nvtop \
        language-pack-ja fonts-takao fcitx-mozc dbus-x11 && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# noVNC and Websockify
RUN git clone https://github.com/AtsushiSaito/noVNC.git -b add_clipboard_support /usr/lib/novnc
RUN pip install 'numpy<1.25.0'
RUN pip install git+https://github.com/novnc/websockify.git@v0.10.0
RUN ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html

# Set remote resize function enabled by default
RUN sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" /usr/lib/novnc/app/ui.js

# Disable auto update and crash report
RUN sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades
RUN sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# Enable apt-get completion
RUN rm /etc/apt/apt.conf.d/docker-clean

# Install Firefox
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update -q && \
    apt-get install -y \
    firefox && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Install VSCodium
RUN wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    -O /usr/share/keyrings/vscodium-archive-keyring.asc && \
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' \
    | tee /etc/apt/sources.list.d/vscodium.list && \
    apt-get update -q && \
    apt-get install -y codium && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --home-dir /home/ubuntu --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
    echo ubuntu:ubuntu | chpasswd && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo 'Defaults env_keep="http_proxy hhtps_proxy no_proxy"' >> /etc/sudoers

RUN gosu ubuntu echo 'export DONT_PROMPT_WSL_INSTALL=1' >> /home/ubuntu/.bashrc && \
    gosu ubuntu bash -c "DONT_PROMPT_WSL_INSTALL=1 codium --install-extension ms-ceintl.vscode-language-pack-ja" && \
    gosu ubuntu bash -c "DONT_PROMPT_WSL_INSTALL=1 codium --install-extension ms-python.python"

# Install ROS
ENV ROS_DISTRO humble
# desktop or ros-base
ARG INSTALL_PACKAGE=desktop

RUN apt-get update -q && \
    apt-get install -y curl gnupg2 lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update -q && \
    apt-get install -y ros-${ROS_DISTRO}-${INSTALL_PACKAGE} \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-rosdep python3-vcstool \
    ros-${ROS_DISTRO}-rqt-* && \
    rosdep init && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update -q && \
    apt-get install -y \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-ros-ign && \
    rm -rf /var/lib/apt/lists/*

COPY ./ai-robot-book.sh /ai-robot-book.sh
RUN dos2unix /ai-robot-book.sh
RUN mkdir -p /tmp/ros_setup_scripts_ubuntu && mv /ai-robot-book.sh /tmp/ros_setup_scripts_ubuntu/ && \
    gosu ubuntu /tmp/ros_setup_scripts_ubuntu/ai-robot-book.sh

COPY ./entrypoint.sh /
RUN dos2unix /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-c", "/entrypoint.sh" ]

ENV USER ubuntu
ENV HOME=/home/ubuntu
