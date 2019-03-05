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


echo 'Default System log data is non-persistent. It exists im memory and is lost on every reboot'
echo 'Logging will be made persistent by writing it to disk in lieu of memory'
echo

# Restore configuration to a predictable known state if a backup exists:
if [ -f /etc/systemd/journald.conf.ORIGINAL ]; then
	mv /etc/systemd/journald.conf.ORIGINAL /etc/systemd/journald.conf
fi


# Make a backup of the default config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/systemd/journald.conf.ORIGINAL ]; then
	cp -p /etc/systemd/journald.conf /etc/systemd/journald.conf.ORIGINAL
fi


sed -i "s/#Storage=auto/Storage=persistent/" /etc/systemd/journald.conf
# Ensure logs do not eat all our storage space by expressly limiting their TOTAL disk usage:
sed -i "s/#SystemMaxUse=/SystemMaxUse=200M/" /etc/systemd/journald.conf
# Stop writing log data even if below threshold specified in "SystemMaxUse=" if total diskspace is running low using the *SystemKeepFree* directive:
sed -i "s/#SystemKeepFree=/SystemKeepFree=1G/" /etc/systemd/journald.conf
# Limit the size log files can grow to before rotation:
sed -i "s/#SystemMaxFileSize=/SystemMaxFileSize=500M/" /etc/systemd/journald.conf
# Purge log entries older than period specified in "MaxRetentionSec" directive
sed -i "s/#MaxRetentionSec=/MaxRetentionSec=1week/" /etc/systemd/journald.conf
# Rotate log no later than a week- if not already preempted by "SystemMaxFileSize" directive forcing a log rotation
sed -i "s/#MaxFileSec=1month/MaxFileSec=1week/" /etc/systemd/journald.conf
# Valid values for MaxLevelWall: emerg alert crit err warning notice info debug
sed -i "s/#MaxLevelWall=emerg/MaxLevelWall=crit/" /etc/systemd/journald.conf
# Write only "crticial" to disk
sed -i "s/#MaxLevelStore=debug/MaxLevelStore=crit/" /etc/systemd/journald.conf
# Max notification level to forward to the Kernel Ring Buffer (/var/log/messages)
sed -i "s/#MaxLevelKMsg=notice/MaxLevelKMsg=warning/" /etc/systemd/journald.conf

echo
echo "Changes made to /etc/systemd/journald.conf by script are $(tput setaf 1)RED$(tput sgr 0)"
echo "Original values are shown in $(tput setaf 2)GREEN$(tput sgr 0)"
echo
diff --color /etc/systemd/journald.conf /etc/systemd/journald.conf.ORIGINAL
echo

systemctl daemon-reload

# Re-Read changes made to /etc/systemd/journald.conf
systemctl restart systemd-journald


echo 'LOGGING NOTES:'
echo '--------------'
echo '1. Although SystemD logging has been changed to persistent by writing the logs to disk'
echo 'verbosity was also reduced to limit writes to bare minimum to avoid hammering MicroSD card.'
echo
echo "2. Application log paths have been changed to $PATHLOGSAPPS on USB storage to limit abuse to MicroSD card."
echo 'Was not possible to change path of /etc/systemd/journald.conf so JournalD still writes to MicroSD card'
echo
echo "3. Changes in $(tput setaf 1)RED$(tput sgr 0) can be reverted in: /etc/systemd/journald.conf"
echo
