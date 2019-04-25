#!/bin/bash

source "${BASH_SOURCE%/*}/variables-secure.sh"
source "${BASH_SOURCE%/*}/variables.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.86.01

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


# References:
# http://msmtp.sourceforge.net/doc/msmtp.html
# https://wiki.archlinux.org/index.php/Msmtp


# NOTE 1: This script ONLY executed on FIRST install of open-ipcamera to CREATE /etc/msmtp config. Upgrades will only MODIFY the file created here  


####  To *MANUALLY* Execute This Script (independently of a full install):  ####
# If need change your mail relay settings its an option to execute this script independently and avoid a full re-install
# 1. Supply the required values for the 5 variables below
# 2. Un-comment these variables then save file and execute it

#SASLUSER='yourSASLuserName'
#SASLPASSWD='yourSASLpasswdGoesHere'
#GMAILADDRESS='yourAcctName@gmail.com'
#GMAILPASSWD='YourGmailPasswdHere'
#SMTPRELAYFQDN='mail.your-SMTP-relay-goes-here.co.uk'



if [ ! -f /etc/msmtprc ]; then


# MSMTP does not provide a default config file so we create one below:
cat <<EOF> /etc/msmtprc
defaults
auth           on
tls            on
tls_starttls   on
logfile        $PATHLOGSAPPS/msmtp.log

# For TLS support uncomment either tls_trustfile_file directive *OR* tls_fingerprint directive: NOT BOTH
# Note: tls_trust_file wont work with self-signed certs: use the tls_fingerprint directive in lieu

#tls_trust_file /etc/ssl/certs/ca-certificates.crt
tls_fingerprint $(msmtp --host=$SMTPRELAYFQDN --serverinfo --tls --tls-certcheck=off | grep SHA256 | awk '{ print $2 }')


# Self-Hosted Mail Account
account     $SMTPRELAYFQDN
host        $SMTPRELAYFQDN
port        $SMTPRELAYPORT
from        $SMTPRELAYFROM
user        $SASLUSER
password    $SASLPASSWD
 
# Gmail
account     gmail
host        smtp.gmail.com
port        587
from        $GMAILADDRESS
user        $GMAILADDRESS
password    $GMAILPASSWD

account default : $SMTPRELAYFQDN

EOF


echo
echo 'MSMTP config file /etc/msmtprc created'

echo
echo '*IF* port TCP/25 blocked then the TLS Fingerprint of your self-hosted SMTP relay will not be computed and supplied to the *tls_fingerprint* directive in msmtprc config file'
echo 'It will consequently not be treated as TRUSTED by MSMTP which will not relay alerts to your self-hosted SMTP server'
echo
echo "$(tput setaf 3)If you do *NOT* receive alerts from a self-hosted SMTP mail relay check the * tls_fingerprint * directive for a fingerprint in /etc/msmtprc$(tput sgr 0)"
echo



# variables-secure.sh is deleted at the end of the full install and will not therefore be available during subsequent upgrades. We disable it:
sed -i 's|^source \"\${BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|\#source \"\$\{BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|' $0


cp -p /etc/msmtprc /etc/msmtprc.BAK_`date +%Y-%m-%d_%H-%M-%S`
	

fi
