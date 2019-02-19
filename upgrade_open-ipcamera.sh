#!/bin/bash

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

### update_open-ipcamera.sh

cat <<EOF> $PATHSCRIPTS/update_open-ipcamera.sh
#!/bin/bash

# UPGRADE INSTRUCTIONS:
#
# STEP 1:
# Provide IP address of the open-ipcamera Pi you are upgrading in the below variable:
CAMERAIPV4=''

# STEP 2:
# Copy this script *FROM* your Pi *TO* the computer where your secret key resides:
#
#     scp://\$CAMERAIPV4:/home/pi/open-ipcamera-scripts/update_open-ipcamera.sh .

# Step 3:
# Execute this update script *ON HOST WITH YOUR GPG SECRET KEY*:
#     ./update_open-ipcamera.sh


########## DO NOT EDIT BELOW THIS LINE ##########

PATHSCRIPTS='/home/pi/open-ipcamera-scripts'
PATHINSTALLDIR='/home/pi/open-ipcamera'
PATHOPENIPCAMERAREPO='https://github.com/f1linux/'

# Get LATEST tag for open-ipcamera from GitHub:
VERSIONLATEST=\$(curl -s 'https://github.com/f1linux/open-ipcamera/tags/'|grep -o "\$Version v[0-9].[0-9][0-9]"|sort -r|head -n1)
# Get version installed on Pi being upgraded:
VERSIONINSTALLED=\$(ssh pi@\$CAMERAIPV4 "grep -m1 '# Version' \$PATHSCRIPTS/version.txt|awk '{print \$3}'| cut -d 'v' -f2")


# Compare latest Git tag for open-ipcamera repo from GitHub to version tag on Pi: *IF* installed version LESS THAN or EQUAL TO GitHub Latest version *THEN* exit_script *ELSE* install upgrade:
if [[ "\$VERSIONINSTALLED" -le "\$VERSIONLATEST" ]]; then

	echo "No upgrade required: Latest version of open-ipcamera \$VERSIONINSTALLED installed"
	exit
	
else

	# Download latest open-ipcamera repo to Pi:
	ssh pi@\$CAMERAIPV4 "git clone \$PATHOPENIPCAMERAREPO/open-ipcamera.git"
	
	# Backup UPGRADE version of variables.sh before we copy decrypted PRODUCTION version- used to configure current system- to install directory so we can compare them:
	ssh pi@\$CAMERAIPV4 "cd \$PATHINSTALLDIR;cp -p ./variables.sh ./variables.sh.version-\$VERSIONLATEST"
	
	# Download encrypted variables.sh file from Pi to local computer with secret key to decrypt it and send file back to Pi:
	echo "Provide password for your GPG Secret key to decrypt variables.sh to complete upgrade process:"
	echo "\$(gpg -d \$(scp pi@\$CAMERAIPV4:\$PATHSCRIPTS/variables.sh.asc .;ls ./variables.sh.asc))" | ssh pi@\$CAMERAIPV4 "cat > \$PATHINSTALLDIR/variables.sh.PRODUCTION"
	
	# Create a variable that diffs PRODUCTION and UPGRADE copies of variables.sh line-by-line and only print lines which do NOT begin with a hashtag and lines not present in BOTH files:
	VARIABLESMODIFIED=\$(ssh pi@\$CAMERAIPV4 "cd \$PATHINSTALLDIR;diff --new-line-format="" --unchanged-line-format="" ./variables.sh.PRODUCTION ./variables.sh.v\$VERSIONLATEST| grep "^[^#].*" ")
	
	# If files differ perform a 2-way merge of lines not shared:
	if [ $(echo \$VARIABLESMODIFIED) = '' ]; then ssh pi@\$CAMERAIPV4 "cd \$PATHINSTALLDIR;paste -d'\n' ./variables.sh.PRODUCTION ./variables.sh.v\$VERSIONLATEST|awk -F'=' '!seen[\$1]++' > ./variables.sh"; fi

	# Create variable to show users which new variables in variables.sh they need to provide values for prior to executing the upgrade script:
	VARIABLESEMPTY=\$(ssh pi@\$CAMERAIPV4 "cat \$PATHINSTALLDIR/variables.sh|grep -o ".*='' ")

	# Next test if changes to variables.sh in the upgrade version included any new variables being added which as yet undefined. If TRUE notify user to complete them and exit upgrade script:
	if [ "\$VARIABLESEMPTY" != '' ]; then echo "Provide values for empty variables in variables.sh" && echo && echo "\$VARIABLESEMPTY" && echo && echo "Re-execute upgrade script after completed && exit ; fi



# Placeholder: Patching mechanisms will start here
	


	
	
fi

EOF

echo "Created $PATHSCRIPTS/update_open-ipcamera.sh"
