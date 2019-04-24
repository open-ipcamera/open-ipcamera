#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.83.01

######  License: ######
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3:
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not see <https://www.gnu.org/licenses/>.


cat <<'EOF'> $PATHSCRIPTS/motion-detection-camera-address.sh
#!/bin/bash

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3


# Redirect output of * set -x * to a log to capture any potential errors as script executed as a SystemD Service
# varFD is an arbitrary variable name and used here to assign the next unused File Descriptor to redirect output to the log
exec {varFD}>/media/automount1/logs/script-motion-detection-camera-address.log
BASH_XTRACEFD=$varFD

set -x

# A * sleep * has been inserted before variable declaration section to allow * CAMERAIPV4= * and * CAMERAIPV6= * to populate correctly AFTER networking has settled
# The SystemD Service target * Requires=network-online.target * this script has a dependency on is met before the network has fully risen up.  Known bug:
# https://github.com/coreos/bugs/issues/1966
# https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/
sleep 10


SCRIPTLOCATION="$(readlink -f $0)"

#CAMERALOCATION: sed expression matches * sysLocation * all spaces after it and only prints everything AFTER the match: the human readable location
CAMERALOCATION="$(sudo sed -n 's/sysLocation.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit alert recipient in below variable. To change alert address edit value of * sysContact * directly in /etc/snmp/snmpd.conf
SYSCONTACT="$(sudo sed -n 's/sysContact.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit below variables: they are self-populating and resolve to the ip address of this host
CAMERAIPV4="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
CAMERAIPV6="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

if [ ! -f /etc/motion/motion.conf.ORIGINAL ]; then
    cp -p /etc/motion/motion.conf /etc/motion/motion.conf.ORIGINAL
fi


if [[ $( grep "on_event_start" /etc/motion/motion.conf ) != '' ]]; then
	sed -i "/on_event_start/d" /etc/motion/motion.conf
fi


echo 'on_event_start echo '"\"Subject: Motion Detected $CAMERAIPV4\""' | msmtp '"\"$SYSCONTACT\""'' >> /etc/motion/motion.conf

systemctl restart motion

EOF


chmod 700 $PATHSCRIPTS/motion-detection-camera-address.sh
chown pi:pi $PATHSCRIPTS/motion-detection-camera-address.sh

echo "Created: $PATHSCRIPTS/motion-detection-camera-address.sh"



cat <<EOF> /etc/systemd/system/motion-detection-camera-address.service
[Unit]
Description=Update IP of Camera in motion.conf for notify email generated on motion detection events ensuring if DHCP IP changes it is automatically updated every boot
Requires=network-online.target
After=motion.service

[Service]
User=root
Group=root
Type=oneshot
ExecStart=$PATHSCRIPTS/motion-detection-camera-address.sh

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/motion-detection-camera-address.service

systemctl enable motion-detection-camera-address.service


echo "Created: /etc/systemd/system/motion-detection-camera-address.service"
echo
