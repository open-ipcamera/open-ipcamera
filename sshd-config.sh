#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.82.00

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


# Restore configuration to a predictable known state if a backup exists:
if [ -f /etc/ssh/sshd_config.ORIGINAL ]; then
	mv /etc/ssh/sshd_config.ORIGINAL /etc/ssh/sshd_config
fi

# Make a backup of default config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/ssh/sshd_config.ORIGINAL ]; then
	cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.ORIGINAL
fi


# Modify default SSH access behaviour by tweaking below directives in /etc/ssh/sshd_config
sed -i "s|#ListenAddress 0.0.0.0|ListenAddress 0.0.0.0|" /etc/ssh/sshd_config
sed -i "s|#ListenAddress ::|ListenAddress ::|" /etc/ssh/sshd_config
sed -i "s|#SyslogFacility AUTH|SyslogFacility AUTH|" /etc/ssh/sshd_config

# LogLevel Values: QUIET \ FATAL \ ERROR \ INFO (default) \ VERBOSE \ DEBUG \ DEBUG1 \ DEBUG2 \ DEBUG3. DEBUG and DEBUG1 equivalent. Using a DEBUG level violates users privacy
sed -i "s|#LogLevel INFO|LogLevel VERBOSE|" /etc/ssh/sshd_config

sed -i "s|#LoginGraceTime 2m|LoginGraceTime 1m|" /etc/ssh/sshd_config
sed -i "s|#MaxAuthTries 6|MaxAuthTries 3|" /etc/ssh/sshd_config
sed -i "s|#PubkeyAuthentication yes|PubkeyAuthentication yes|" /etc/ssh/sshd_config
sed -i "s|#AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2|AuthorizedKeysFile     .ssh/authorized_keys|" /etc/ssh/sshd_config
sed -i "s|#PasswordAuthentication yes|PasswordAuthentication yes|" /etc/ssh/sshd_config
sed -i "s|#PermitEmptyPasswords no|PermitEmptyPasswords no|" /etc/ssh/sshd_config
sed -i "s|#X11Forwarding yes|X11Forwarding yes|" /etc/ssh/sshd_config
sed -i "s|PrintMotd yes|PrintMotd no|" /etc/ssh/sshd_config
sed -i "s|#PrintLastLog yes|PrintLastLog yes|" /etc/ssh/sshd_config
sed -i "s|#TCPKeepAlive yes|TCPKeepAlive yes|" /etc/ssh/sshd_config

echo
echo "Changes made to /etc/ssh/sshd_config by script are $(tput setaf 1)RED$(tput sgr 0)"
echo "Original values are shown in $(tput setaf 2)GREEN$(tput sgr 0)"
echo
diff --color /etc/ssh/sshd_config /etc/ssh/sshd_config.ORIGINAL
echo
