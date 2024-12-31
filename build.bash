#!/bin/bash

args=""
for v in http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
do
  eval "test -n \"\$$v\" && args=\"\$args --build-arg $v=\${$v}\""
done
echo "args:" $args

docker build \
$* \
$args \
-t airobotbook/ros2-desktop-ai-robot-book-humble \
.
