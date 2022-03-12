#!/usr/bin/env bash

echo "### user-fonts.sh"
set -x #echo on

# powerline fonts 설치
git clone https://github.com/powerline/fonts.git /tmp/fonts
cd /tmp/fonts && sh ./install.sh
cd ~ && rm -rf /tmp/fonts

# Nerd Fonts
curl -fsL -o ~/.local/share/fonts/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip"
cd ~/.local/share/fonts/ && unzip JetBrainsMono.zip && rm JetBrainsMono.zip && rm *Windows*
fc-cache -f -v -r
