#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"

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


############## FUNCTIONS: ###############

# Note that "notify-apt-failure" Calls the other function "apt-cmd-last"
status-apt-cmd () {
if [[ $(echo $?) != 0 ]]; then
	echo "$(tput setaf 1)Apt Command FAILURE:$(tput sgr 0)"
else
	echo "$(tput setaf 2)Apt Command SUCCESS:$(tput sgr 0) $(apt-cmd-last)"
fi
}

# Below function extracts the LAST *SUCCESSFUL* apt command executed from the apt history log. 
# Note that *UNSUCCESSFUL* attempts are not recorded in that log
apt-cmd-last () {
tail -5 /var/log/apt/history.log|grep -i "Commandline"|cut -d ':' -f2
}
