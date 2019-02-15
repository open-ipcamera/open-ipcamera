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


# Truncate any messages previously appended to MOTD by this script:
truncate -s 0 /etc/motd


echo 'Configured Help Messages/Tips in /etc/motd to display on user login'
echo >> /etc/motd
echo >> /etc/motd
echo '###############################################################################################################' >> /etc/motd
echo "##  $(tput setaf 4)If I saved you lots of time manually configuring buy me a beer either in person or PayPal:$(tput sgr 0) ##" >> /etc/motd
echo "##                          $(tput setaf 4)paypal.me/TerrenceHoulahan $(tput sgr 0)                          ##" >> /etc/motd
echo '###############################################################################################################' >> /etc/motd
echo >> /etc/motd
echo >> /etc/motd
echo 'Troubleshooting: Execute below script to gather data to investigate the fault:' >> /etc/motd
echo "cd $PATHSCRIPTS" >> /etc/motd
echo './troubleshooting-helper.sh' >> /etc/motd
echo >> /etc/motd
echo 'Camera Feed Access: Append :8080 to IP of this host in a web browser to view camera stream' >> /etc/motd
echo >> /etc/motd
echo 'stop/start/reload Motion daemon:' >> /etc/motd
echo 'sudo systemctl [stop|start|reload] motion' >> /etc/motd
echo >> /etc/motd
echo 'Manually change *VIDEO* resolution using Video4Linux driver: tailor below example to your own use-case:' >> /etc/motd
echo 'Step 1: sudo systemctl stop motion' >> /etc/motd
echo 'Step 2: sudo v4l2-ctl --set-fmt-video=width=1920,height=1080,pixelformat=4' >> /etc/motd
echo >> /etc/motd
echo 'Obtain resolution and other data from an image file:' >> /etc/motd
echo 'exiv2 /media/pi/imageName.jpg' >> /etc/motd
echo >> /etc/motd
echo 'To see metadata for an image or video:' >> /etc/motd
echo 'exiftool /media/pi/videoName.mp4' >> /etc/motd
echo >> /etc/motd
echo >> /etc/motd
echo 'To edit or delete these login messages:  vi /etc/motd' >> /etc/motd
echo >> /etc/motd
echo '###############################################################################' >> /etc/motd
echo >> /etc/motd
echo >> /etc/motd