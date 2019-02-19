#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 1.60.3

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



# This script copies *variables.sh* out of the install path and back to /home/pi/scripts/open-ipcamera before open-ipcamera repo deleted
# It is OK to overwrite any existing copies in this path to ensure any changes made to variables.sh are captured:

cp $PATHINSTALLDIR/variables.sh $PATHSCRIPTS/
chown pi:pi $PATHSCRIPTS/variables.sh
chmod 700 $PATHSCRIPTS/variables.sh
# Update the version in the header of variables.sh file to be consistent with the rest of files in this tagged Git release:
sed -i "s/^# Version [0-9].[0-9][0-9]/# Version $VERSIONLATEST/" $PATHSCRIPTS/variables.sh


# Below expression will ONLY encrypt your variables.sh file if it is NOT either empty or using the default value *YourGPGkeyIDhere* AND you provide an email address
# The * trust-model always * switch looks dodgy but we are encrypting with our own PUBLIC key which we trust implicitly.
if [[ "$GPGKEYIDPUBLICYOURS" != '' || 'YourGPGkeyIDhere' ]] && [[ "$GPGKEYIDPUBLICYOURSEMAIL" != 'emailAddressAssociatedWithGPGkeyIDHere' ]]; then
	gpg --batch --yes --trust-model always -r $GPGKEYIDPUBLICYOURSEMAIL -a -e $PATHSCRIPTS/variables.sh
	# Delete *UNENCRYPTED* variables.sh file:
	rm $PATHSCRIPTS/variables.sh
	echo ''
fi
