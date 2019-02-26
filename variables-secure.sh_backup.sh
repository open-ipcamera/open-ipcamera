#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.65.02

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


# If a GPG Public Key specified then this script moves a copy of variables-secure.sh to a persistent location and encrypts it.
# If *NO* GPG Public Key specified then variables-secure.sh is DELETED.  Once install completed only a downside to retaining this file in cleartext
# OK to overwrite any existing copies in this path to ensure changes to variables.sh are captured:



# Below expression will ONLY encrypt variables-secure.sh if NOT either empty or using default value *YourGPGkeyIDhere* AND you provide an email address:
# The * trust-model always * switch looks dodgy but we are encrypting with our own PUBLIC key which we trust implicitly.
if [[ "$GPGKEYIDPUBLICYOURS" != '' || 'YourGPGkeyIDhere' ]] && [[ "$GPGKEYIDPUBLICYOURSEMAIL" != 'emailAddressAssociatedWithGPGkeyIDHere' ]]; then
	cp $PATHINSTALLDIR/variables-secure.sh $PATHSCRIPTS/
	chown pi:pi $PATHSCRIPTS/variables-secure.sh
	chmod 700 $PATHSCRIPTS/variables-secure.sh	
	# Update version number in header of variables-secure.sh to be consistent with other files in this tagged Git release:
	sed -i "s/^# Version [0-9][0-9].[0-9][0-9].[0-9][0-9]/# Version $VERSIONLATEST/" $PATHSCRIPTS/variables-secure.sh
	# Encrypt *variables-secure.sh*
	gpg --batch --yes --trust-model always -r $GPGKEYIDPUBLICYOURSEMAIL -a -e $PATHSCRIPTS/variables-secure.sh
	echo "variables-secure.sh has been encrypted with GPG Key $GPGKEYIDPUBLICYOURS"
	# Delete *UNENCRYPTED* variables.sh file:
	rm $PATHSCRIPTS/variables-secure.sh
	echo ''
else
	"DELETING variables-secure.sh: No GPG Public Key specified to encrypt a backup of this file."
	 "User Mgmnt outside of open-ipcamera upgrade processes- as true with most upgrade processes. Encrypted backup version only retained for reference purposes"
	rm $PATHINSTALLDIR/variables-secure.sh
fi
