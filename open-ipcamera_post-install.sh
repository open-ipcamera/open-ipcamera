#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.80.00

##############  License: ##############
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



# Delete *version.txt* file so it can be replaced with an updated version reflecting this installs version number:
if [ -f $PATHSCRIPTS/version.txt ]; then
	chattr -i $PATHSCRIPTS/version.txt
	rm $PATHSCRIPTS/version.txt
fi


# Create *version.txt* echoing version number just installed into it:
echo "$VERSIONLATEST" >> $PATHSCRIPTS/version.txt

echo "Updated $PATHSCRIPTS/version.txt with version just installed"


# Change ownership of all files created by this script FROM user *root* TO user *pi*:
# Redirect stderr to /dev/null to quiet "operation not permitted" error when recursively chown-ing /home/pi/: version.txt is set to immutable and not a valid error
chown -R pi:pi /home/pi 2> /dev/null

# Set perms on *version.txt* to immutable so it cannot be deleted- inadvertently or intentionally
chown pi:pi $PATHSCRIPTS/version.txt
chattr +i $PATHSCRIPTS/version.txt

echo "Changed perms on $PATHSCRIPTS/version.txt to IMMUTABLE"
