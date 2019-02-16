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


# By default Dropbox API used to upload images breaks scripted automation by requiring user input on first access.
# So we initiate an access then spit back the token supplied in variable DROPBOXACCESSTOKEN and finally acknowledge it is correct


# Test file has date+time format name to ensure upload does not conflict with a previous test file or token initialization will fail:
touch /home/pi/test_`date +%Y-%m-%d_%H-%M-%S`.txt

cd /home/pi/Dropbox-Uploader/
su pi -c "printf '\n'|./dropbox_uploader.sh upload /home/pi/test*.txt / << 'INPUT'
$DROPBOXACCESSTOKEN
y
INPUT"
rm /home/pi/test*.txt
