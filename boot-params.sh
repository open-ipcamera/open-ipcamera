#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.83.00

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


# Restore configuration to a predictable known state if a backup exists:
if [ -f /boot/config.txt.ORIGINAL ]; then
	mv /boot/config.txt.ORIGINAL /boot/config.txt
fi

# Make a backup of the default config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /boot/config.txt.ORIGINAL ]; then
	cp -p /boot/config.txt /boot/config.txt.ORIGINAL
fi


# raspian-config: How to interface from CLI:
# https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup

# Clear any boot params added during a previous build and then add each back with most current value set:
# Enable camera (No raspi-config option to script this):
sed -i '/start_x=1/d' /boot/config.txt
echo 'start_x=1' >> /boot/config.txt

sed -i '/disable_camera_led=1/d' /boot/config.txt
echo 'disable_camera_led=1' >> /boot/config.txt

echo "Determine if Pi is a Zero W or NOT to set GPU memory value appropriately:"

if [ $(cat /proc/device-tree/model | awk '{ print $3 }') != 'Zero' ]; then
	echo 'NOT PI ZERO!'
	echo 'Setting GPU Memory to 128'
	sed -i '/gpu_mem=128/d' /boot/config.txt
	echo 'gpu_mem=128' >> /boot/config.txt
else
	echo 'PI ZERO'
#	echo "Setting GPU Memory to 512"
#	sed -i '/gpu_mem=512/d' /boot/config.txt
#	echo 'gpu_mem=512' >> /boot/config.txt
fi

echo
echo 'Camera ENABLED'
echo
echo 'Camera LED light DISABLED'
echo

sed -i '/disable_splash=1/d' /boot/config.txt
echo 'disable_splash=1' >> /boot/config.txt
echo 'Boot Splash Screen DISABLED'
