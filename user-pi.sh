#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 1.60.4

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


echo
echo 'Show user pi * DEFAULT * group memberships:'
echo '*groups pi* Output:'
groups pi
echo

echo
echo 'Add supplementary group *motion* to user *pi* group memberships: *usermod -a -G motion pi*'
usermod -a -G motion pi
echo

echo
echo 'Show user pi * NEW * group memberships:'
echo '*groups pi* Output:'
groups pi
echo


echo 'Set user bash histories to unlimited length'
sed -i "s/HISTSIZE=1000/HISTSIZE=/" /home/pi/.bashrc
sed -i "s/HISTFILESIZE=2000/HISTFILESIZE=/" /home/pi/.bashrc
echo


echo 'Changing default password *raspberry* for user *pi*'
echo "pi:$PASSWDPI"|chpasswd

echo
echo 'Set passwd for user * root *'
echo "root:$PASSWDROOT"|chpasswd


# Only create the SSH keys and furniture if an .ssh folder does not already exist for user pi:
if [ ! -d /home/pi/.ssh ]; then
	mkdir /home/pi/.ssh
	chmod 700 /home/pi/.ssh
	chown pi:pi /home/pi/.ssh
	touch /home/pi/.ssh/authorized_keys
	chown pi:pi /home/pi/.ssh/authorized_keys

	# https://www.ssh.com/ssh/keygen/
	sudo -u pi ssh-keygen -t ecdsa -b 521 -f /home/pi/.ssh/id_ecdsa -q -P ''&
	wait $!

	chmod 600 /home/pi/.ssh/id_ecdsa
	chmod 644 /home/pi/.ssh/id_ecdsa.pub
	chown -R pi:pi /home/pi/

	echo "ECDSA 521 bit keypair created for user *pi*"
fi

echo
echo "$MYPUBKEY" >> /home/pi/.ssh/authorized_keys
echo "Added Your Public Key to * authorized_keys * file"
echo



# Disable autologin now that Public Key Access enabled:
sed -i "s/autologin-user=pi/#autologin-user=pi/" /etc/lightdm/lightdm.conf
systemctl disable autologin@.service
echo
echo "Disabled autologin"
echo

echo "Change default editor from * nano * to a universal Unix standard * vi *"
echo "BEFORE Change:"
update-alternatives --get-selections|grep editor
echo
update-alternatives --set editor /usr/bin/vim.basic
echo
echo "AFTER Change:"
update-alternatives --get-selections|grep editor

if [ -f /home/pi/.selected_editor ]; then
	sed -i 's|SELECTED_EDITOR="/bin/nano"|SELECTED_EDITOR="/usr/bin/vim"|' /home/pi/.selected_editor
fi

# The cp below restores /home/pi/.vimrc to default state before sed makes the appends
cp /usr/share/vim/vimrc /home/pi/.vimrc
echo "Created /home/pi/.vimrc"

if [ -f /etc/vim/vimrc.ORIGINAL ]; then
	mv /etc/vim/vimrc.ORIGINAL /etc/vim/vimrc
fi

if [ ! -f /etc/vim/vimrc.ORIGINAL ]; then
	cp -p /etc/vim/vimrc /etc/vim/vimrc.ORIGINAL
fi


# Below sed expression stops vi from going to * visual * mode when one tries to copy text
sed -i 's|^"set mouse=a.*|set mouse-=a|' /home/pi/.vimrc
sed -i 's|^"set mouse=a.*|set mouse-=a|' /etc/vim/vimrc

chown pi:pi /home/pi/.vimrc
chmod 600 /home/pi/.vimrc


# Create Mutt configuration file for user pi
cat <<EOF> /home/pi/.muttrc

set sendmail="$(command -v msmtp)"
set use_from=yes
set realname="$(hostname)"
set from="pi@$(hostname)"
set envelope_from=yes
set editor="vim.basic"

EOF

chown pi:pi /home/pi/.muttrc
chmod 600 /home/pi/.muttrc
