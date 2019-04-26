#!/bin/bash

source "${BASH_SOURCE%/*}/variables-secure.sh"
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.86.02

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



####  To *MANUALLY* Execute This Script (independently of a full re-install):  ####
# This script is ONLY executed on FIRST install of open-ipcamera.
# If want to execute this script independently to change the Dropbox Access Token:
# 1. Provide the token in the below variable
# 2. Un-comment the variable then save this file and execute it

#DROPBOXACCESSTOKEN='ReplaceThisStringWithYourAccessToken'

# By default Dropbox API used to upload images breaks scripted automation by requiring user input on first access.
# So we initiate an access then spit back the token supplied in variable DROPBOXACCESSTOKEN and finally acknowledge it is correct


echo "If a Dropbox access token was added in variables.sh- $(tput setaf 3)IT SHOULD HAVE BEEN$(tput sgr 0) - final sentence in final line of message below should read:"
echo "$(tput setaf 6)The configuration has been saved$(tput sgr 0)"
echo "If $(tput setaf 1)NOT$(tput sgr 0) create a Dropbox Access Token then specify it in variables.sh and re-execute this script"
echo


# Test file has date+time format name to ensure upload does not conflict with a previous test file or token initialization will fail:
touch /home/pi/test_`date +%Y-%m-%d_%H-%M-%S`.txt

cd /home/pi/Dropbox-Uploader/
su pi -c "printf '\n'|./dropbox_uploader.sh upload /home/pi/test*.txt / << 'INPUT'
$DROPBOXACCESSTOKEN
y
INPUT"
rm /home/pi/test*.txt



if [[ $(cat /home/pi/.dropbox_uploader|cut -d '=' -f2) = '' ]]; then

echo "$(tput setaf 1)######################################################################$(tput sgr 0)"
echo "$(tput setaf 1)######################################################################$(tput sgr 0)"
echo "$(tput setaf 1)##########################$(tput sgr 0)   $(tput setaf 6)WARNING:$(tput sgr 0)   $(tput setaf 1)##############################$(tput sgr 0)"
echo "$(tput setaf 1)##############$(tput sgr 0)  $(tput setaf 6)DROPBOX ACCESS TOKEN VARIABLE NOT SET IN:$(tput sgr 0)  $(tput setaf 1)###########$(tput sgr 0)"
echo "$(tput setaf 1)####################$(tput sgr 0)  $(tput setaf 6)/home/pi/.dropbox_uploader.sh$(tput sgr 0)  $(tput setaf 1)#################$(tput sgr 0)"
echo "$(tput setaf 1)######################################################################$(tput sgr 0)"
echo "$(tput setaf 1)######################################################################$(tput sgr 0)"

fi


# variables-secure.sh is deleted at the end of full install and will therefore not be available during subsequent upgrades. We disable it:
sed -i 's|^source \"\${BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|\#source \"\$\{BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|' $0
