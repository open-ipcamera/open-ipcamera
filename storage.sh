#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.85.00

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


echo "To stop frequent writes from trashing MicroSD card where Pi OS lives"
echo "directories with frequent write activity will be mounted on USB storage"
echo


# Disable automounting by default Filemanager * pcmanfm * if present: it steps on our SystemD automount which offers greater flexibility to change mount options:
if [ -f /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf ]; then
	sed -i "s/mount_removable=1/mount_removable=0/" /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf
fi


echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 6)* Automount 1 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo

# Benefits of using SystemD automounts vs hard mounts:
# https://www.theregister.co.uk/2016/08/22/systemd_adds_filesystem_mount_tool/

if [ ! -d /media/automount1 ]; then
	mkdir /media/automount1
fi

chmod 775 /media/automount1
chown pi:pi /media/automount1

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount1.mount
[Unit]
Description=Create automount1 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sda1
Where=/media/automount1
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount1.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount1.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount1
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount1
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount1.automount

systemctl disable media-automount1.mount
systemctl enable media-automount1.automount

systemctl daemon-reload

systemctl start media-automount1.automount

echo
echo 'Created media-automount1.automount'
echo




echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 3)* Automount 2 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo


if [ ! -d /media/automount2 ]; then
	mkdir /media/automount2
fi

chmod 775 /media/automount2
chown pi:pi /media/automount2

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount2.mount
[Unit]
Description=Create automount2 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sdb1
Where=/media/automount2
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount2.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount2.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount2
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount2
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount2.automount

systemctl disable media-automount2.mount
systemctl enable media-automount2.automount

echo
echo 'Created media-automount2.automount'
echo




echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 1)* Automount 3 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo


if [ ! -d /media/automount3 ]; then
	mkdir /media/automount3
fi

chmod 775 /media/automount3
chown pi:pi /media/automount3

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount3.mount
[Unit]
Description=Create automount3 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sdc1
Where=/media/automount3
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount3.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount3.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount3
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount3
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount3.automount

systemctl disable media-automount3.mount
systemctl enable media-automount3.automount

echo
echo 'Created media-automount3.automount'
echo




echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 4)* Automount 4 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo


if [ ! -d /media/automount4 ]; then
	mkdir /media/automount4
fi

chmod 775 /media/automount4
chown pi:pi /media/automount4

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount4.mount
[Unit]
Description=Create automount4 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sdd1
Where=/media/automount4
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount4.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in "Where" directive below:
cat <<EOF> /etc/systemd/system/media-automount4.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount4
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount4
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount4.automount

systemctl disable media-automount4.mount
systemctl enable media-automount4.automount

systemctl daemon-reload

echo
echo 'Created media-automount4.automount'
echo


# Testing revealed where automounts were started where no block device was loaded in a USB port it was broke parts of script which followed.
# So we only start automounts for additional (sda1 must load as the images and logs are stored on it) block devices if found:

if [[ $(lsblk|grep sdb1) != '' ]]; then
	systemctl start media-automount2.automount
fi


if [[ $(lsblk|grep sdc1) != '' ]]; then
	systemctl start media-automount3.automount
fi


if [[ $(lsblk|grep sdd1) != '' ]]; then
	systemctl start media-automount4.automount
fi




echo
echo "$(tput setaf 5)******  Check USB ExFAT Formatted Storage for Images Present:  ******$(tput sgr 0)"
echo

# Test a USB Flash Drive is present:
if [[ $(ls /dev|grep sda1) != '' ]]; then
	echo
	echo 'Storage Found: Testing for ExFAT Formatting next'
else
	echo 'ERROR: No USB Flash Storage Found to Write Images to.'
	echo 'Please insert an ExFAT formatted USB Flash Drive and re-execute this script'
	echo 'Script exiting.'
	exit
fi


# Test the USB Flash Drive formatted for ExFAT:
if [ $(lsblk -f|grep sda1|awk '{print $2}') = 'exfat' ]; then
	echo
	echo 'Storage is formatted for ExFAT. Script will continue'
	echo
else
	echo
	echo 'ERROR: ExFAT formatted USB flash drive REQUIRED to write video to'
	echo "Format a USB Flash Drive for ExFAT and re-excute $0. Exiting script"
	echo
	exit
fi


# NOTE:  This is the EARLIEST this directory can be created- needs to live on the mount we created for it.
#	Do not move the creation of this directory from the end of this file nor specify it before storqge.sh has been called by open-ipcamera-config.sh
# Create a folder on USB flash storage to write our persistent logs to.
# This is to avoid abusing MicroSD card housing the OS with frequent writes
if [ ! -d $PATHLOGSAPPS ]; then
	mkdir -p $PATHLOGSAPPS
	chmod 751 $PATHLOGSAPPS
else
	echo "Directory $PATHLOGSAPPS already exists on USB Flash Storage"
fi
