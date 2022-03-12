#!/usr/bin/env bash

echo "### desktop-env.sh"
set -x #echo on

if [[ ! -f $(which dbeaver) ]]; then
  # dbeaver
  curl -fsSL -k -o /tmp/dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
  dpkg -i /tmp/dbeaver.deb 
  rm -rf /tmp/dbeaver.deb
fi

if [[ ! -f /usr/local/bin/robo3t ]]; then
  # robo3t
  curl -fsSL -k -o /tmp/robo3t.tar.gz "https://github.com/Studio3T/robomongo/releases/download/v1.4.4/robo3t-1.4.4-linux-x86_64-e6ac9ec.tar.gz"
  tar xf /tmp/robo3t.tar.gz -C /tmp
  mv /tmp/robo3t-1.4.4-linux-x86_64-e6ac9ec /usr/local/bin/robo3t

  curl -fsSL -o /usr/local/bin/robo3t/bin/icon.png "https://dashboard.snapcraft.io/site_media/appmedia/2018/09/logo-256x256.png"
  cat <<EOF | tee /usr/share/applications/robo3t.desktop
[Desktop Entry]
Type=Application
Name=Robo3t
Icon=/usr/local/bin/robo3t/bin/icon.png
Exec=/usr/local/bin/robo3t/bin/robo3t
Comment=Robo3t
Categories=Development;
Terminal=false
StartupNotify=true
EOF
fi

# pycharm
if [[ ! -f /usr/local/bin/pycharm ]]; then
  curl -fsSL -o /tmp/pycharm-professional.tar.gz https://download.jetbrains.com/python/pycharm-professional-2021.3.2.tar.gz
  tar xfz /tmp/pycharm-professional.tar.gz -C /usr/local/bin 
  mv /usr/local/bin/pycharm-2021.3.2 /usr/local/bin/pycharm
  rm -f /tmp/pycharm-professional.tar.gz
fi


# tilix 설정: dconf dump /com/gexperts/ (설정 dump)
if [[ -f /usr/local/bin/setup/config/skel/tilix.dconf ]]; then
  export $(dbus-launch)
  DISPLAY=:0 dconf load /com/gexperts/ < /usr/local/bin/setup/config/skel/tilix.dconf
fi

# vm max map count
cat <<EOF | tee -a /etc/sysctl.conf
vm.max_map_count=262144
EOF

# pycharm slow disk
echo "fs.inotify.max_user_watches = 524288" | tee /etc/sysctl.d/idea.conf
sysctl -p --system

# clean tmp
apt autoremove -yqq
