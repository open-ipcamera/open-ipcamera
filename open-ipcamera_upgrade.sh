#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"

#set -x

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.69.00

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



# Only need to test if INSTALLED version number is LESS THAN or EQUAL TO latest version available on GitHub
# NOTE: the curly braces around variables in comparative test which have #0 appended to them  used to stop shell from interpreting versions as octal values
# Ref: https://stackoverflow.com/questions/24777597/value-too-great-for-base-error-token-is-08
if [[ "$(echo ${VERSIONREPO#0}|tr -d '.')" -gt "$(echo ${VERSIONINSTALLED#0}|tr -d '.')" ]]; then
	echo
	echo "Newer version of open-ipcamera downloaded:"
	echo
	cd /home/pi/
	git clone https://github.com/f1linux/open-ipcamera.git
	cd $PATHINSTALLDIR
	echo
	git tag -l -n20 $(git describe)
	echo
	read -p "Press ENTER to UPGRADE current open-ipcamera installation or CTRL C to exit it"
	echo
	# Set markers in *UPGRADE* logs
	echo '####################################################################################################################' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
	echo '' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo "$0 open-ipcamera v$VERSIONLATEST STARTED: `date +%Y-%m-%d_%H-%M-%S`" >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo '' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo 'Only events related to open-ipcamera write here.' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo "Applications log to: $PATHLOGSAPPS" >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo '' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	# BACKUP PRODUCTION version- which HAS unique user values- of variables.sh file before doing a 2-way merge of this file with the newest version of variables.sh in the upgrade:
	cp -p $PATHSCRIPTS/variables.sh $PATHSCRIPTS/variables.sh.BAK_`date +%Y-%m-%d_%H-%M-%S`
	# BACKUP UPGRADE version -which has no unique user values- of variables.sh before 2-way merge:
	cp -p $PATHINSTALLDIR/variables.sh $PATHINSTALLDIR/variables.sh.BAK_`date +%Y-%m-%d_%H-%M-%S`
	# Create a variable that contains the results of a diff between PRODUCTION and UPGRADE copies of variables.sh line-by-line and only print lines NOT beginning with hashtag and lines NOT present in BOTH files:
	VARIABLESMODIFIED=$(diff --new-line-format="" --unchanged-line-format="" $PATHSCRIPTS/variables.sh $PATHINSTALLDIR/variables.sh| grep "^[^#].*")	
	# If files differ THEN perform 2-way merge of lines NOT shared:
	if [[ $(echo $VARIABLESMODIFIED) = '' ]]; then paste -d'\n' $PATHSCRIPTS/variables.sh $PATHINSTALLDIR/variables.sh|awk -F'=' '!seen[$1]++' >$PATHINSTALLDIR/variables.sh; fi
	# NOTE: The new MERGED variables.sh file will be copied to a persistent location $PATHSCRIPTS/ by open-ipcamera_delete.sh before it deletes the open-ipcamera repo	
	# Create variable to show new variables- not comments- in variables.sh require values prior to upgrading open-ipcamera:
	VARIABLESEMPTY=$(cat $PATHINSTALLDIR/variables.sh|grep -o ".*='' ")	
	# Execute upgrade if variables.sh in LATEST release do NOT include unpopulated- not empty- variables. Else show empty variables notify user to complete them and exit:
	if [[ "$VARIABLESEMPTY" != '' ]]; then cd $PATHINSTALLDIR;./open-ipcamera-config.sh; else echo "Provide values for empty variables in variables.sh" && echo && echo "$VARIABLESEMPTY" && echo && echo "Re-execute upgrade script after completed" && exit; fi
	# Delete the pre-merged copy of variables.sh- we made a backup of this before the merge:
	rm $PATHSCRIPTS/variables.sh
	echo '' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo "$0 v$VERSIONLATEST COMPLETED:: `date +%Y-%m-%d_%H-%M-%S`" >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo '' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo '####################################################################################################################' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
	echo '' >> $PATHLOGINSTALL/upgrade_v$VERSIONLATEST.log
else
	echo
	echo "No upgrade required: open-ipcamera $VERSIONINSTALLED installed is current version"
	echo
	exit
fi
