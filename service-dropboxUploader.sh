#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.65.03

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


# *Dropbox-Uploader* facilitates copying images from local USB Flash storage to cloud safeguarding evidence from theft or destruction of Pi-Cam

if [ ! -d /home/pi/Dropbox-Uploader ]; then
	cd /home/pi
	until git clone https://github.com/andreafabrizi/Dropbox-Uploader.git
	do
		echo
		echo "$(tput setaf 5)Download of Dropbox-Uploader repo failed. Retrying$(tput sgr 0)"
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
	done
fi

chown -R pi:pi /home/pi/Dropbox-Uploader


cat <<EOF> $PATHSCRIPTS/Dropbox-Uploader.sh
#!/bin/bash

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3


# Script searches /media/automount1 for jpg and mp4 files and pipes those it finds to xargs which
# first uploads them to dropbox and then deletes them ensuring storage does not fill to 100 percent

find /media/automount1 -name '*.jpg' -print0 -o -name '*.mp4' -print0 | xargs -d '/' -0 -I % sh -c '/home/pi/Dropbox-Uploader/dropbox_uploader.sh upload % . && rm %'

EOF


chmod 700 $PATHSCRIPTS/Dropbox-Uploader.sh
chown pi:pi $PATHSCRIPTS/Dropbox-Uploader.sh


cat <<EOF> /etc/systemd/system/Dropbox-Uploader.service
[Unit]
Description=Upload images to cloud
#Before=

[Service]
User=pi
Group=pi
Type=simple
ExecStart=$PATHSCRIPTS/Dropbox-Uploader.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/Dropbox-Uploader.service


cat <<EOF> /etc/systemd/system/Dropbox-Uploader.timer
[Unit]
Description=Execute Dropbox-Uploader.sh script every 5 min to safeguard camera evidence

[Timer]
OnCalendar=*:0/5
Unit=Dropbox-Uploader.service

[Install]
WantedBy=timers.target

EOF


chmod 644 /etc/systemd/system/Dropbox-Uploader.timer


systemctl daemon-reload
systemctl enable Dropbox-Uploader.service
systemctl enable Dropbox-Uploader.timer


echo 'https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md'
echo
