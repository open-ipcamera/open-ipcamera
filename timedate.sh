#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.75.02

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


# USEFUL REFERENCES:
#       https://www.digitalocean.com/community/tutorials/how-to-set-up-time-synchronization-on-ubuntu-16-04
#       https://wiki.archlinux.org/index.php/systemd-timesyncd
#       https://www.freedesktop.org/software/systemd/man/timedatectl.html


# NOTE: When time servers are allocated by DHCP they can be identified at below path:
#	   /run/dhcpcd/ntp.conf/wlan0.dhcp


echo
echo "$(tput setaf 6)TIMESYNCD Config: Ensure Pi-Cam Records Evidence with Accurate Time$(tput sgr 0)"
echo


# Restore configuration to a predictable known state if a backup exists:
if [ -f /etc/systemd/timesyncd.conf.ORIGINAL ]; then
	mv /etc/systemd/timesyncd.conf.ORIGINAL /etc/systemd/timesyncd.conf
fi


# Make a backup of the default config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/systemd/timesyncd.conf.ORIGINAL ]; then
	cp -p /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.ORIGINAL
fi

# Set systemd-timesyncd to start on boot if it is not already:
if [[ $(systemctl list-unit-files|grep systemd-timesyncd.service|awk '{print $2}') = 'enabled' ]]; then
    timedatectl set-ntp on
    systemctl start systemd-timesyncd
fi


sed -i "s/#NTP=/NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org/" /etc/systemd/timesyncd.conf
sed -i "s/#FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org/FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org/" /etc/systemd/timesyncd.conf

# Below (3) directives absent from Raspbian default timesyncd.conf config file as of Raspbian v9.6 Stretch.
# Check to see if they were written previously by script and if not whack them in:
#
if [[ $(grep "RootDistanceMaxSec" /etc/systemd/timesyncd.conf) = '' ]]; then
        # *RootDistanceMaxSec*: 5 seconds is default value
        echo "RootDistanceMaxSec=5" >> /etc/systemd/timesyncd.conf
fi

if [[ $(grep "PollIntervalMinSec" /etc/systemd/timesyncd.conf) = '' ]]; then
        # *PollIntervalMinSec*: 32 seconds is default value NOTE: Cannot be less than 16 seconds
        echo "PollIntervalMinSec=32" >> /etc/systemd/timesyncd.conf
fi

if [[ $(grep "PollIntervalMaxSec" /etc/systemd/timesyncd.conf) = '' ]]; then
        # *PollIntervalMaxSec*: 2048 seconds is default value NOTE: Cannot be less than value set for *PollIntervalMinSec*
        echo "PollIntervalMaxSec=2048" >> /etc/systemd/timesyncd.conf
fi


# Re-read config with the changes:
systemctl daemon-reload


echo 'Output of *timedatectl status* Follows:'
echo
timedatectl status
echo

echo "$(tput setaf 6)Validate above time against your computer clock to ensure it approximates current time in your geography$(tput sgr 0)"
echo
