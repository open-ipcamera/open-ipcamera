#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 1.60.3

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



# Restore snmpd.conf configuration to a predictable known state if a backup exists:
if [ -f /etc/snmp/snmpd.conf.ORIGINAL ]; then
	mv /etc/snmp/snmpd.conf.ORIGINAL /etc/snmp/snmpd.conf
fi


# Make a backup of the default snmpd.conf config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/snmp/snmpd.conf.ORIGINAL ]; then
	cp -p /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.ORIGINAL
fi


# Restore snmp.conf configuration to a predictable known state if a backup exists:
if [ -f /etc/snmp/snmp.conf.ORIGINAL ]; then
	mv /etc/snmp/snmp.conf.ORIGINAL /etc/snmp/snmpd.conf
fi


# Make a backup of the default snmp.conf config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/snmp/snmp.conf.ORIGINAL ]; then
	cp -p /etc/snmp/snmp.conf /etc/snmp/snmpd.conf.ORIGINAL
fi


# Restore /usr/share/snmp/snmpd.conf configuration to a predictable known state if a backup exists:
if [ -f /usr/share/snmp/snmpd.conf.ORIGINAL ]; then
	mv /usr/share/snmp/snmpd.conf.ORIGINAL /usr/share/snmp/snmpd.conf
fi



# *DISABLE* local-only connections to SNMP daemon
sed -i "s/agentAddress  udp:127.0.0.1:161/#agentAddress  udp:127.0.0.1:161/" /etc/snmp/snmpd.conf

# *ENABLE* remote SNMP connectivity to cameras:
# A further reminder to please restrict access by firewall to your cameras
sed -i "s/#agentAddress  udp:161,udp6:\[::1\]:161/agentAddress  udp:161,udp6:161/" /etc/snmp/snmpd.conf

# *DISABLE* access using default v1/2 community string *public*
# We are enabling SNMP V3 access so only a downside to leaving SNMP v1/2 access by a universally known community string
sed -i "s/ rocommunity public  default    -V systemonly/# rocommunity public  default    -V systemonly/" /etc/snmp/snmpd.conf
sed -i "s/ rocommunity6 public  default   -V systemonly/# rocommunity6 public  default   -V systemonly/" /etc/snmp/snmpd.conf


# Enable loading of MIBs:
sed -i "s/mibs :/#mibs :/" /etc/snmp/snmp.conf

# Next comment-out below line in /etc/default/snmpd as we *ARE* loading MIBs (we grabbed them when we installed snmp-mibs-downloader with the other SNMP packages):
sed -i "s/export MIBS=/#export MIBS=/" /etc/default/snmpd

# Describe location of camera:
sed -i "s/sysLocation    Sitting on the Dock of the Bay/sysLocation    $SNMPLOCATION/" /etc/snmp/snmpd.conf

# email alerts will pull the contact email address via SNMP from the variable "SNMPSYSCONTACT"
sed -i "s/sysContact     Me <me@example.org>/sysContact     $SNMPSYSCONTACT/" /etc/snmp/snmpd.conf

# Stop SNMP daemon to create a Read-Only user:
systemctl stop snmpd.service

# Only an SNMP v3 Read-Only user will be created to gain visibility into pi hardware:
# * -A * => AUTHENTICATION password and * -X * => ENCRYPTION password
net-snmp-config --create-snmpv3-user -ro -A $SNMPV3AUTHPASSWD -X $SNMPV3ENCRYPTPASSWD -a SHA -x AES $SNMPV3ROUSER
echo

# *APPEND* a note after the ACCESS CONTROL header in snmpd.conf detailing where our v3 SNMP credentials live to avoid future confusion:
sed -i '/#  ACCESS CONTROL/a # NOTE: SNMP v3 Access Token Added by net-snmp-config to /var/lib/snmp/snmpd.conf by open-ipcamera-config.sh script' /etc/snmp/snmpd.conf
sed -i '/#  ACCESS CONTROL/a # NOTE: SNMP v3 User Added by net-snmp-config to /usr/share/snmp/snmpd.conf by open-ipcamera-config.sh script' /etc/snmp/snmpd.conf


systemctl enable snmpd.service
systemctl start snmpd.service

echo

# Make a backup of default /usr/share/snmp/snmpd.conf config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /usr/share/snmp/snmpd.conf.ORIGINAL ]; then
	cp -p /usr/share/snmp/snmpd.conf /usr/share/snmp/snmpd.conf.ORIGINAL
fi
