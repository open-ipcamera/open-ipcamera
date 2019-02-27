#!/bin/bash

source "${BASH_SOURCE%/*}/variables-secure.sh"

# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.65.04

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


# If default config access values found in motion.conf then set unique usernames and passwords for HTTP access from variables:

# Below 2 sed expressions have a special construction around the variables to stop special characters in complex passwords being interpreted

if [[ "$(grep '; stream_authentication username:password' /etc/motion/motion.conf|awk '{print $3}')" = 'username:password' ]]; then
	sed -i 's/; stream_authentication username:password/stream_authentication '"$USER:$PASSWD"'/' /etc/motion/motion.conf
fi



if [[ "$(grep '; webcontrol_authentication username:password' /etc/motion/motion.conf|awk '{print $3}')" = 'username:password' ]]; then
	sed -i 's/; webcontrol_authentication username:password/webcontrol_authentication '"$USER:$PASSWD"'/' /etc/motion/motion.conf
fi


# variables-secure.sh is deleted at the end of the full install and will not therefore be available during subsequent upgrades. We disable it:
sed -i 's|^source \"\${BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|\#source \"\$\{BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|' $0
