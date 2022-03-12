#!/usr/bin/env bash

echo "### xrdp-user-env.sh"
set -x #echo on

# xdg user dirs
touch ~/.hushlogin

mkdir -p ~/{desktop,downloads,documents}
mkdir -p ~/documents/{templates,share,music,pictures,videos}

xdg-user-dirs-update --set DESKTOP ~/desktop
xdg-user-dirs-update --set DOWNLOAD ~/downloads
xdg-user-dirs-update --set DOCUMENTS ~/documents
xdg-user-dirs-update --set TEMPLATES ~/documents/templates
xdg-user-dirs-update --set PUBLICSHARE ~/documents/share
xdg-user-dirs-update --set MUSIC ~/documents/music
xdg-user-dirs-update --set PICTURES ~/documents/pictures
xdg-user-dirs-update --set VIDEOS ~/documents/videos

cd ~ && rm -rf "공개"  "다운로드"  "문서"  "바탕화면"  "비디오"  "사진"  "서식"  "음악" "템플릿"

