@echo off
setlocal
set ORIGINAL_IMAGE=airobotbook/ros2-desktop-ai-robot-book-humble:latest
set MY_IMAGE=ros2-desktop-ai-robot-book-humble:mine
for /f "usebackq" %%A in (`docker image ls -q %ORIGINAL_IMAGE%`) do set ID=%%A
if [%ID%] == [] (
    docker pull %ORIGINAL_IMAGE%
) else (
    echo %ORIGINAL_IMAGE%はすでにローカルに存在
)
if errorlevel 1 (
    echo "イメージの取得に失敗"
    exit 1
)
for /f "usebackq" %%A in (`docker image ls -q %ORIGINAL_IMAGE%`) do set ID=%%A
docker tag %ID% %MY_IMAGE%
docker rmi %ORIGINAL_IMAGE%
