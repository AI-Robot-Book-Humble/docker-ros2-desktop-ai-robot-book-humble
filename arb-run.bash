#!/bin/bash
MY_IMAGE=ros2-desktop-ai-robot-book-humble:mine
docker run \
-e http_proxy=${http_proxy} \
-e https_proxy=${https_proxy} \
-e no_proxy=${no_proxy} \
-e HTTP_PROXY=${HTTP_PROXY} \
-e HTTPS_PROXY=${HTTPS_PROXY} \
-e NO_PROXY=${HTTPS_PROXY} \
-e RESOLUTION=1920x1080 \
-e PULSE_COOKIE=/tmp/pulse/cookie \
-e PULSE_SERVER=unix:/tmp/pulse/native \
-v /run/user/$(id -u)/pulse/native:/tmp/pulse/native \
-v ~/.config/pulse/cookie:/tmp/pulse/cookie:ro \
--name ai_robot_book \
-p 15900:5900 \
-p 13389:3389 \
-p 6080:80 \
--shm-size=512m \
--privileged \
$* \
$MY_IMAGE
