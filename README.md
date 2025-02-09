# 「ROS 2とPythonで作って学ぶAIロボット入門 改訂第2版」の教材一式を提供するDockerイメージの作成

## 概要
- [「ROS 2とPythonで作って学ぶAIロボット入門 改訂第2版」](https://www.kspub.co.jp/book/detail/5386163.html)に必要なライブラリ，パッケージ，サンプルプログラムを全て含む．
- Daisuke Sato: Dockerfiles to provide HTML5 VNC interface to access Ubuntu Desktop + ROS 2, [GitHub tiryoh/ros2-desktop-vnc](https://github.com/Tiryoh/docker-ros2-desktop-vnc) のHumble用を基にしている．
- VSCodium
- 日本語環境

## イメージ作成

```
git clone https://github.com/AI-Robot-Book-Humble/docker-ros2-desktop-ai-robot-book-humble
cd docker-ros2-desktop-ai-robot-book-humble
./build.bash
```

## イメージの公開場所

https://hub.docker.com/repository/docker/airobotbook/ros2-desktop-ai-robot-book-humble

## 実行（Linux）

### イメージ入手

```
./arb-pull.bash
```

### コンテナ起動

```
./arb-run.bash
```

GPUを利用する場合

```
./arb-run.bash --gpus all
```

### デスクトップの利用

- ウェブブラウザをVNCビューアにする場合
  - `http://127.0.0.1:6080` にアクセス．
  - パスワード ubuntu

- RemminaをVNCビューアにする場合
  - `127.0.0.1:15900` にアクセス．
  - パスワード ubuntu

### 現在のコンテナをイメージとして保存

```
./arb-commit.bash
```

## 実行（Windows）

### イメージ入手

```
arb-pull.bat
```

### コンテナ起動

```
arb-run.bat
```

GPUを利用する場合

```
arb-run.bat --gpus all
```

### デスクトップの利用

- ウェブブラウザを使う場合
  - `http://127.0.0.1:6080` にアクセス．
  - パスワード ubuntu

- VNCビューアを使う場合
  - 127.0.0.1:15900 に接続
  - パスワード ubuntu

### 現在のコンテナをイメージとして保存

```
arb-commit.bat
```

## 既知の問題・今後の課題


## 著者

升谷 保博

## 履歴

- 2024-12-31: 新規作成


## ライセンス

Copyright (c) 2024, 2025 MASUTANI Yasuhiro  
All rights reserved.  
This project is licensed under the Apache License 2.0 license found in the LICENSE file in the root directory of this project.

## 参考文献

- Daisuke Sato: Dockerfiles to provide HTML5 VNC interface to access Ubuntu Desktop + ROS 2, [GitHub tiryoh/ros2-desktop-vnc](https://github.com/Tiryoh/docker-ros2-desktop-vnc) 

