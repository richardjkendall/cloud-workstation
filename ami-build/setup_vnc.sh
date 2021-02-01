#!/bin/bash

install() {
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get install -y ubuntu-desktop tightvncserver gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal
}

configure() {
  # create folder for config file
  mkdir -p ~/.vnc

  # output config file contents
  cat > ~/.vnc/xstartup <<- EOM
#!/bin/sh

export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey

vncconfig -iconic &
gnome-panel &
gnome-settings-daemon &
metacity &
nautilus &
gnome-terminal &
EOM
}

install
configure

