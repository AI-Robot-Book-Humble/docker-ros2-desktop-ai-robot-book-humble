@echo off
setlocal
set ORIGINAL_IMAGE=airobotbook/ros2-desktop-ai-robot-book-humble:latest
set MY_IMAGE=ros2-desktop-ai-robot-book-humble:mine
docker pull %ORIGINAL_IMAGE%
if errorlevel 1 (
    echo "イメージの取得に失敗"
    exit 1
)
for /f "usebackq" %%A in (`docker images --format "{{.ID}}" %ORIGINAL_IMAGE%`) do set ID=%%A
docker tag %ID% %MY_IMAGE%
docker rmi %ORIGINAL_IMAGE%
