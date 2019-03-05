#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.75.01

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



echo "List *PUBLIC* Keys in Pi user Keyring $(tput setaf 1)*BEFORE*$(tput sgr 0) Importing Keys:"
echo
su pi -c "gpg --list-keys"
echo

# Download Developer Public Key used to sign releases and to send encrypted bug reports into pi user GPG keyring:
# Terrence Houlahan open-ipcamera key fingerprint: 55F0 6FEA FD60 BBB5 38BA  D470 C526 69EF BAF4 A660

# The gnupg keyserver can be flaky so we have to engineer reliability to keep trying to download the requested KeyID:

while [[ "$(su pi -c "gpg --list-keys $GPGPUBKEYIDDEVELOPERTERRENCE"|grep -o 'pub')" != 'pub' ]]
do
        echo
        echo "Downloading Developer Terrence Houlahan GPG Public Key used to sign open-ipcamera tagged Git Releases"
        su pi -c "gpg --keyserver hkp://keys.gnupg.net:80 --recv $GPGPUBKEYIDDEVELOPERTERRENCE"
        echo
        echo "Script will retry every 5 seconds until Key successfully downloaded"
        echo
        echo "If failing continuously exit script and check port TCP/80 open for GPG keyserver connectivity"
        sleep 5
done


# Download the USERs GPG Public Key to use for encrypting their sensitive data:
# Check for a value in variable GPGKEYIDPUBLICYOURS is neither empty or the default value:  If not attempt to download the user Public Key
if [[ "$(echo $GPGKEYIDPUBLICYOURS)" != 'YourGPGkeyIDhere' ]] && [[ "$(echo $GPGKEYIDPUBLICYOURS)" != '' ]]; then

while [[ "$(su pi -c "gpg --list-keys $GPGKEYIDPUBLICYOURS"|grep -o 'pub')" != 'pub' ]]
do
        echo
        echo "Downloading Developer Terrence Houlahan GPG Public Key used to sign open-ipcamera tagged Git Releases"
        su pi -c "gpg --keyserver hkp://keys.gnupg.net:80 --recv $GPGKEYIDPUBLICYOURS"
        echo
        echo "Script will retry every 5 seconds until Key successfully downloaded"
        echo
        echo "If failing continuously exit script and check GPG KeyID correct in variable GPGKEYIDPUBLICYOURS"
        echo "Also check port TCP/80 is open for keyserver connectivity"
        echo
        sleep 5
done

fi


echo
echo "List *PUBLIC* Keys in Pi user Keyring $(tput setaf 6)*AFTER*$(tput sgr 0) Importing Keys:"
echo
su pi -c "gpg --list-keys"
echo
