#!/bin/bash
ORIGINAL_IMAGE=airobotbook/ros2-desktop-ai-robot-book-humble:latest
MY_IMAGE=ros2-desktop-ai-robot-book-humble:mine
docker pull $ORIGINAL_IMAGE
if [ $? -gt 0 ]; then
    echo "イメージの取得に失敗"
    exit 1
fi
ID=$(docker images --format "{{.ID}}" $ORIGINAL_IMAGE)
docker tag $ID  $MY_IMAGE
docker rmi $ORIGINAL_IMAGE
