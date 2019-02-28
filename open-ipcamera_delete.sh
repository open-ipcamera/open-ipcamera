#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.66.00

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


# NOTE: "variables-secure.sh" copied to $PATHSCRIPTS/ by "variables-secure.sh_backup.sh"
# "variables-secure.sh" only used on first FULL install and deleted afterwards: no need to re-copy it to $PATHSCRIPTS/ as with "variables.sh" which is used for upgrades


# Copy unique data FROM INSTALL directory TO SCRIPTS dir to ensure remains persistent for upgrades:
if [ ! -f $PATHSCRIPTS/variables.sh ]; then
	cp -p $PATHINSTALLDIR/variables.sh $PATHSCRIPTS/
fi


if [ ! -f $PATHSCRIPTS/upgrade_open-ipcamera.sh ]; then
	cp -p $PATHINSTALLDIR/open-ipcamera_upgrade.sh $PATHSCRIPTS/
fi


if [ ! -f $PATHSCRIPTS/$GPGPUBKEYDEVELOPERTERRENCE ]; then
	cp  $PATHINSTALLDIR/$GPGPUBKEYDEVELOPERTERRENCE $PATHSCRIPTS/
	chown pi:pi $PATHSCRIPTS/$GPGPUBKEYDEVELOPERTERRENCE
fi



# Delete open-ipcamera repo files:
rm -rf $PATHINSTALLDIR

echo
echo 'Deleted * open-ipcamera * Repo Directory'
echo
