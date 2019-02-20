#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 1.60.4

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


# Revert CPU Affinity back to default if a backup exists to ensure we start our new changes from a predictable known state::
if [ -f /etc/systemd/system.conf.ORIGINAL ]; then
	mv /etc/systemd/system.conf.ORIGINAL /etc/systemd/system.conf
fi

# Make a backup of the default config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/systemd/system.conf.ORIGINAL ]; then
	cp -p /etc/systemd/system.conf /etc/systemd/system.conf.ORIGINAL
fi


echo "$(tput setaf 6)The Pi 3B+ has a 4-core CPU. Motion in this install is single threaded. We will pin the process to a dedicated core.$(tput sgr 0)"
echo "$(tput setaf 6)By restricting SYSTEM processes to executing on CPUs 0-2 when we pin Motion to core 3 its use will be uncontended by other processes$(tput sgr 0)"
echo

cp -p /etc/systemd/system.conf /etc/systemd/system.conf.ORIGINAL

sed -i "s/#CPUAffinity=1 2/CPUAffinity=0 1 2/" /etc/systemd/system.conf


echo
echo "Changes made to/etc/systemd/system.conf by script are $(tput setaf 1)RED$(tput sgr 0)"
echo "Original values are shown in $(tput setaf 2)GREEN$(tput sgr 0)"
echo
diff --color /etc/systemd/system.conf /etc/systemd/system.conf.ORIGINAL
echo



cat <<'EOF'> $PATHSCRIPTS/set-cpu-affinity.sh
#!/bin/bash

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3


# Note: the number following cp is the CPU/core number in this case 3
taskset -cp 3 $(pgrep motion|cut -d ' ' -f2)

EOF


chmod 700 $PATHSCRIPTS/set-cpu-affinity.sh
chown pi:pi $PATHSCRIPTS/set-cpu-affinity.sh

# Note use of * Wants * directive to create a dependent relationship on Motion already being started
cat <<EOF> /etc/systemd/system/set-cpu-affinity.service
[Unit]
Description=Set CPU Affinity for the Motion process after it starts on boot
Wants=motion.service
After=motion.service

[Service]
User=root
Group=root
Type=oneshot
ExecStart=$PATHSCRIPTS/set-cpu-affinity.sh

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/set-cpu-affinity.service

systemctl enable set-cpu-affinity.service

chown -R pi:pi /home/pi


echo " $(tput setaf 6)CPU Affinity for Motion has been made persistent by executing as a service on boot$(tput sgr 0)"
