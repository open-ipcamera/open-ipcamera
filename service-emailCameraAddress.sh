#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.68.00

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



# Apple offers no means to identify the IP of a device tethered to an iPhone HotSpot.
# This systemd service emails camera IP address assigned by a HotSpot to email specified in variable *SNMPSYSCONTACT*
# If you want to change the email address this notification (or any other system alert) is sent to edit *sysContact* in /etc/snmp/snmpd.conf directly.

# NOTE: email alerts will only work if a valid mail relay with correct credentials has been configured in open-ipcamera variables.sh file when installing it


cat <<'EOF'> $PATHSCRIPTS/email-camera-address.sh
#!/bin/bash

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3


# Redirect output of * set -x * to a log to capture any potential errors as script executed as a SystemD Service
# varFD is an arbitrary variable name and used here to assign the next unused File Descriptor to redirect output to the log
exec {varFD}>/media/automount1/logs/script-email-camera-address.log
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


echo -e "Subject: IP of Camera: $( echo $CAMERAIPV4 )\r\n\r\nIP Address of $CAMERALOCATION Camera $(hostname) is: $CAMERAIPV4 / $CAMERAIPV6 '\n' Script sending this email: $SCRIPTLOCATION" |msmtp $SYSCONTACT

# Below comand has the --debug switch: uncomment if you want to tweak the command and get granular visibility
#echo -e "Subject: IP of Camera: $( echo $CAMERAIPV4 )\r\n\r\nIP Address of $CAMERALOCATION Camera $(hostname) is: $CAMERAIPV4 / $CAMERAIPV6 '\n' Script sending this email: $SCRIPTLOCATION" |msmtp --debug $SYSCONTACT

EOF


chmod 700 $PATHSCRIPTS/email-camera-address.sh
chown pi:pi $PATHSCRIPTS/email-camera-address.sh


cat <<EOF> /etc/systemd/system/email-camera-address.service
[Unit]
Description=Email IP Address of Camera on Boot
Requires=network-online.target
After=motion.service

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=$PATHSCRIPTS/email-camera-address.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/email-camera-address.service

systemctl enable email-camera-address.service
