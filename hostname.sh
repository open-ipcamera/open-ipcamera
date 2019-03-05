#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.75.00

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


# Restore /etc/hosts configuration to a predictable known state if a backup exists:
if [ -f /etc/hosts.ORIGINAL ]; then
	mv /etc/hosts.ORIGINAL /etc/hosts
fi

# Make a backup of the default config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/hosts.ORIGINAL ]; then
	cp -p /etc/hosts /etc/hosts.ORIGINAL
fi


hostnamectl set-hostname raspberrypi
systemctl restart systemd-hostnamed&
wait $!


echo "Hostname CURRENT: $(hostname)"

hostnamectl set-hostname $OURHOSTNAME.$OURDOMAIN
systemctl restart systemd-hostnamed&
wait $!


echo
echo "Hostname NEW: $(hostname)"


# hostnamectl does NOT update the hosts own entry in /etc/hosts so must do separately:
sed -i "s/127\.0\.1\.1.*/127\.0\.0\.1      $OURHOSTNAME $OURHOSTNAME.$OURDOMAIN/" /etc/hosts
sed -i "s/::1.*/::1     $OURHOSTNAME $OURHOSTNAME.$OURDOMAIN/" /etc/hosts
