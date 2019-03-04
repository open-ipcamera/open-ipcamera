#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.69.02

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


echo
echo 'Raspbian Version *PRE* Updates'
lsb_release -a
echo
echo "Kernel: $(uname -r)"
echo


echo 'Remove any dependencies of uninstalled packages:'
apt-get -qqy autoremove > /dev/null
echo

echo 'Now execute the dist-upgrade'
apt-get -qqy dist-upgrade > /dev/null
echo


echo
echo 'Raspbian Version *POST* Updates'
lsb_release -a
echo
echo "Kernel: $(uname -r)"
echo


# Ensure autologin remains disabled after an upgrade:
sed -i "s/autologin-user=pi/#autologin-user=pi/" /etc/lightdm/lightdm.conf
systemctl disable autologin@.service
echo
