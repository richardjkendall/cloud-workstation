#!/bin/bash

# store init script in variable
read -d '' INIT_SCRIPT << EOF
[Unit]
Description=Systemd VNC server startup script for Ubuntu 20.04
After=syslog.target network.target

[Service]
Type=forking
User={User}
ExecStartPre=-/usr/bin/vncserver -kill :%i &> /dev/null
ExecStart=/usr/bin/vncserver -depth 24 -geometry {ScreenGeom} :%i
PIDFile=/home/{User}/.vnc/%H:%i.pid
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

TARGET_USER="ubuntu"

get_tag() {
  INSTANCE_ID=$(ec2metadata --instance-id)
  REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
  TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$1" --region=$REGION --output=text | cut -f5)
  if [ -z "$TAG_VALUE" ]; then
    return 1
  else
    echo "$TAG_VALUE"
  fi
}


VNC_PASSWORD=$(get_tag "VncPassword")
echo "got VncPassword of $VNC_PASSWORD"
if [ -z "$VNC_PASSWORD" ]; then
  echo "Exiting because no VncPassword was found"
  exit 1
fi

SCREEN_GEOMETRY=$(get_tag "ScreenGeometry")
echo "got ScreenGeometry of $SCREEN_GEOMETRY"
if [ -z "$SCREEN_GEOMETRY" ]; then
  echo "Exiting because no ScreenGeometry was found"
  exit 1
fi

# make xstartup +x
chmod +x /home/$TARGET_USER/.vnc/xstartup

# set password
echo $VNC_PASSWORD | vncpasswd -f > /home/$TARGET_USER/.vnc/passwd
chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.vnc/passwd
chmod 600 /home/$TARGET_USER/.vnc/passwd

# install start-up script
INIT_SCRIPT=$(echo "$INIT_SCRIPT" | awk -v srch="{ScreenGeom}" -v repl="$SCREEN_GEOMETRY" '{ sub(srch,repl,$0); print $0 }')
INIT_SCRIPT=$(echo "$INIT_SCRIPT" | awk -v srch="{User}" -v repl="$TARGET_USER" '{ sub(srch,repl,$0); print $0 }')
echo "$INIT_SCRIPT"
echo "$INIT_SCRIPT" > /etc/systemd/system/vncserver@.service
systemctl daemon-reload
systemctl enable vncserver@1

# start vnc server
service vncserver@1 start