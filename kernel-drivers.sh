#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.68.01

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


# Restore configuration to a predictable known state:
if [ -f /etc/modules-load.d/bcm2835-v4l2.conf  ]; then
	rm /etc/modules-load.d/bcm2835-v4l2.conf
fi


# Load Kernel module for Pi camera on boot:
cat <<EOF> /etc/modules-load.d/bcm2835-v4l2.conf
bcm2835-v4l2

EOF

echo 'File created to automatically load camera driver on boot:'
echo "/etc/modules-load.d/bcm2835-v4l2.conf"

# Rebuild Kernel modules dependencies map
depmod -a

# Load Camera Kernel Module
# Will automatically load on reboot at end of script- modprobe command disabled
#modprobe bcm2835-v4l2
