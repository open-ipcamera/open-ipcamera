#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 1.40

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


cat <<'EOF'> $PATHSCRIPTS/heat-alert.sh
#!/bin/bash

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3


# Redirect output of * set -x * to a log to capture any errors as script executed as a SystemD Service
# varFD is an arbitrary variable name and used here to assign the next unused File Descriptor to redirect output to the log
exec {varFD}>/media/automount1/logs/script-heat-alert.log
BASH_XTRACEFD=$varFD

set -x

# A * sleep * has been inserted before variable declaration section to allow * CAMERAIPV4= * and * CAMERAIPV6= * to populate correctly AFTER networking has settled
# The SystemD Service target * Requires=network-online.target * this script has a dependency on is met before the network has fully risen up.  Known bug:
# https://github.com/coreos/bugs/issues/1966
# https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/
sleep 10


# Edit values in variables below rather than editing script itself to avoid introducing a fault
# NOTE1: Do NOT restart service after changing a threshhold value- script is fired-off anew every 5 minutes by the SystemD timer * heat-alert.timer *.
# NOTE2: Temperature units are in CELCIUS
# NOTE3: Baseline temperature of a cold Pi at boot is about 35C
HEATTHRESHOLDWARN='60'
HEATTHRESHOLDSHUTDOWN='75'


SCRIPTLOCATION="$(readlink -f $0)"

#CAMERALOCATION: Do *NOT edit this variable directly: edit value of * sysLocation * in /etc/snmp/snmpd.conf which this variable pulls the value from
# sed expression matches * sysLocation * all spaces after it and only prints everything AFTER the match: the human readable location
CAMERALOCATION="$(sudo sed -n 's/sysLocation.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit alert recipient in below variable. To change alert address edit value of * sysContact * directly in /etc/snmp/snmpd.conf
SYSCONTACT="$(sudo sed -n 's/sysContact.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit below variables: these are self-populating and resolve to the ip address of this host
CAMERAIPV4="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
CAMERAIPV6="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"


# NOTE: A delay (* sleep 20 *) is inserted before shutdown where HEATTHRESHOLDSHUTDOWN tests TRUE to a) allow time to send the notification and
# b) to give you time to edit "heat-alert.sh" to increase value if set too low causing Pi to just reboot in a loop

if [[ $(/opt/vc/bin/vcgencmd measure_temp|cut -d '=' -f2|cut -d '.' -f1) -gt $HEATTHRESHOLDWARN ]]; then
	echo -e “Temp exceeds WARN threshold: $HEATTHRESHOLDWARN C. '\n' To adjust WARN alert Threshold edit: $SCRIPTLOCATION '\n' Sender of Alert: $(hostname) / $CAMERAIPV4 / $CAMERAIPV6 '\n' Alert Sent: $(date)” | mutt -s "Heat Alert Camera $(echo $CAMERAIPV4)" $SYSCONTACT
elif [[ $(/opt/vc/bin/vcgencmd measure_temp|cut -d '=' -f2|cut -d '.' -f1) -gt $HEATTHRESHOLDSHUTDOWN ]]; then
	echo -e “Pi shutdown due to Heat Threshold: $HEATTHRESHOLDSHUTDOWN C being reached '\n' To adjust shutdown Heat Threshold edit: $SCRIPTLOCATION '\n' Sender of Alert: $(hostname) $CAMERAIPV4 / $CAMERAIPV6 '\n' Alert Sent: $(date)” | mutt -s "Shutdown Alert Camera $(echo $CAMERAIPV4)" $SYSCONTACT
	sleep 20
	systemctl poweroff
else
	exit
fi

EOF


chmod 700 $PATHSCRIPTS/heat-alert.sh
chown pi:pi $PATHSCRIPTS/heat-alert.sh


cat <<EOF> /etc/systemd/system/heat-alert.service
[Unit]
Description=Email Heat Alerts
Requires=network-online.target
After=motion.service

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=$PATHSCRIPTS/heat-alert.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/heat-alert.service

systemctl enable heat-alert.service



cat <<'EOF'> /etc/systemd/system/heat-alert.timer
[Unit]
Description=Email Heat Alerts

[Timer]
OnCalendar=*:0/5
Unit=heat-alert.service

[Install]
WantedBy=timers.target

EOF


chmod 644 /etc/systemd/system/heat-alert.timer

systemctl enable heat-alert.timer
systemctl list-timers --all
