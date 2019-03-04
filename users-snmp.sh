#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/variables-secure.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.69.01

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


# NOTE: This script is ONLY executed on FIRST install of open-ipcamera.
# User management will thereafter be an end-user task- as is true in most upgrade processes



####  To *MANUALLY* Execute This Script (independently of a full install):  ####
# If need change your mail relay settings its an option to execute this script independently and avoid a full re-install
# 1. Supply required values for 3 below variables
# 2. Un-comment variables then save this file and execute it


### NOTE 1: Below two variables are encased between a double and single quote. DO NOT DELETE THEM when setting a password
### NOTE 2: Additionally neither should your complex passwords for below variables incorporate single or double quote marks.  All other special characters OK to use
#SNMPV3AUTHPASSWD="'PiDemo1234'"
#SNMPV3ENCRYPTPASSWD="'PiDemo1234'"
#SNMPV3ROUSER='pi'



# Stop SNMP daemon to create a Read-Only user:
systemctl stop snmpd.service

# Only an SNMP v3 Read-Only user will be created to gain visibility into pi hardware:
# * -A * => AUTHENTICATION password and * -X * => ENCRYPTION password
$(command -v net-snmp-config) --create-snmpv3-user -ro -A $SNMPV3AUTHPASSWD -X $SNMPV3ENCRYPTPASSWD -a SHA -x AES $SNMPV3ROUSER
echo

# *APPEND* a note after the ACCESS CONTROL header in snmpd.conf detailing where our v3 SNMP credentials live to avoid future confusion:
sed -i '/#  ACCESS CONTROL/a # NOTE: SNMP v3 Access Token Added by net-snmp-config to /var/lib/snmp/snmpd.conf by open-ipcamera-config.sh script' /etc/snmp/snmpd.conf
sed -i '/#  ACCESS CONTROL/a # NOTE: SNMP v3 User Added by net-snmp-config to /usr/share/snmp/snmpd.conf by open-ipcamera-config.sh script' /etc/snmp/snmpd.conf

systemctl start snmpd.service


# variables-secure.sh is deleted at the end of the full install and will not therefore be available during subsequent upgrades. We disable it:
sed -i 's|^source \"\${BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|\#source \"\$\{BASH_SOURCE\%\/\*\}\/variables-secure\.sh\"|' $0


# Backup /usr/share/snmp/snmpd.conf:
cp -p /usr/share/snmp/snmpd.conf /usr/share/snmp/snmpd.conf.`date +%Y-%m-%d_%H-%M-%S`



echo
echo "$(tput setaf 5)****** VALIDATE SNMP CONFIG:  ******$(tput sgr 0)"
echo

echo 'Execute an snmpget of sysLocation.0 (camera location):'
echo '------------------------------------------------------'
$(command -v snmpget) -v3 -a SHA -x AES -A $SNMPV3AUTHPASSWD -X $SNMPV3ENCRYPTPASSWD -l authNoPriv -u $(tail -1 /usr/share/snmp/snmpd.conf|cut -d ' ' -f 2) $CAMERAIPV4 sysLocation.0
echo
echo "Expected result of snmpget should be: * $SNMPLOCATION *"
echo
