#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.86.00

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


###### RASPBIAN NETWORKING: #####
#
# Dynamic Networking: "NetworkManager" *NOT* installed by default (unlike most distros)

# DNS Config: "resolvconf"
# -----------------------
# resolvconf configures system DNS resolvers and reads /etc/nsswitch.conf for order sources of DNS info consulted

# Interface Config: DHCPCD
# ------------------
# DHCPCD configures wired & wireless interfaces after setting up the access point details.
# "systemd-networkd" is present but disabled by default.
#
# If you wish to migrate IF config FROM "DHCPCD" TO "systemd-networkd" - and I do not see any upside in doing so at this time- here is a link to a HowTo:
# https://raspberrypi.stackexchange.com/questions/78787/howto-migrate-from-networking-to-systemd-networkd-with-dynamic-failover

# "systemd-resolved" installed by default
# To find related files ("locate" command requires the "mlocate" package to be installed):
#    locate resolved


# Below is a key dependency *NOT* installed by default:
if [[ "$( dpkg -l |grep libnss-resolve )" = '' ]]; then
	apt-get install -y libnss-resolve
fi


# The below future-proofs this script as the dependent pkg "systemd-resolvconf" is required post systemd v239
if [[ "$(systemctl --version | awk 'NR==1{print $2}')" -gt '238' ]]; then
	apt-get install -y systemd-resolvconf
fi

# We are going to replace /etc/resolv.conf with a symlink to systemd resolv file:
if [ -f /etc/resolv.conf ]; then
	rm -f /etc/resolv.conf
fi

# Test for presence of a symlink to /etc/resolv.conf from the system-resolved version of file:
if [ ! -L /etc/resolv.conf ]; then
        ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

# Remove "domain_name_servers" to stop the routers DHCP server from supplying resolver IPs to the client- we will control resolvers from /etc/systemd/resolved.conf now:
sed -i "s/option domain_name_servers, domain_name, domain_search, host_name/option domain_name, domain_search, host_name/" /etc/dhcpcd.conf

# Config /etc/systemd/resolved :
sed -i "s/#DNS=/DNS=$DNSRESOLVERIPV41 $DNSRESOLVERIPV61/" /etc/systemd/resolved.conf
# Below Google IPs for directive "FallbackDNS" are default. 
sed -i "s/#FallbackDNS=8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844/FallbackDNS=$DNSRESOLVERIPV42 $DNSRESOLVERIPV62/" /etc/systemd/resolved.conf

sed -i "s/#LLMNR=yes/LLMNR=yes/" /etc/systemd/resolved.conf
sed -i "s/#DNSSEC=no/DNSSEC=no/" /etc/systemd/resolved.conf
sed -i "s/#Cache=yes/Cache=yes/" /etc/systemd/resolved.conf
sed -i "s/#DNSStubListener=udp/DNSStubListener=udp/" /etc/systemd/resolved.conf

# Below directive(s) are *NOT*- as of systemd v232- present in default "resolved.conf" config file

if [[ "$(cat /etc/systemd/resolved.conf|grep 'DNSOverTLS=opportunistic')" = '' ]];then
	echo "DNSOverTLS=opportunistic" >> /etc/systemd/resolved.conf
fi



# Config /etc/nsswitch : "resolve" must be first in list of DNS resources consulted
# "hosts" directive is a mess: new entries can be- and have been- dynamically prepended before the "resolve" target and break our stub resolver.
# SO: we wipe "hosts" directive and append a correct line at bottom of nsswitch.conf :

# Test if this operation previously completed by determining if file already immutable :
if [[ "$(lsattr -l /etc/nsswitch.conf | grep -o 'Immutable')" = '' ]]; then

sed -i sed "/hosts.*/d" /etc/nsswitch.conf
echo "hosts:          resolve [!UNAVAIL=return] dns files mdns4_minimal [NOTFOUND=return]" >> /etc/nsswitch.conf
echo ''  >> /etc/nsswitch.conf
echo "NOTICE: FILE HAS BEEN MADE IMMUTABLE TO STOP DYNAMIC MODIFICATION of HOST DIRECTIVE BREAKING SYSTEMD-RESOLVED STUB RESOLVER" >> /etc/nsswitch.conf
echo '' >> /etc/nsswitch.conf

# Make nsswitch.conf immutable to stop it from being dynamically modified:
chattr +i /etc/nsswitch.conf

echo
echo 'OUTPUT OF "lsattr /etc/nsswitch.conf" :'
echo
lsattr /etc/nsswitch.conf
echo
echo 'Expected Result of "lsattr":  "i" should be reported reflecting file made immutable'
echo

fi




systemctl daemon-reload

# Restart systemd-resolved stub resolver:
systemctl restart systemd-resolved

echo "####################################################################################"
echo
echo "systemd-resolved stats $(tput setaf 1)*BEFORE*$(tput sgr 0) testing:"
echo
systemd-resolve --statistics

# Run a few ping tests which require DNS:
ping -c1 www.google.com
ping6 -c1 www.google.com

echo

ping -c1 www.amazon.com
ping6 -c1 www.amazon.com

echo

# Execute tests directly against stub resolver on 127.0.0.1 to validate it can correctly resolve names:
echo "OUTPUT OF: systemd-resolve www.amazon.com 127.0.0.1 "
echo
systemd-resolve www.amazon.com 127.0.0.1
echo
echo
echo "OUTPUT OF: systemd-resolve www.google.com 127.0.0.1 "
echo
systemd-resolve www.google.com 127.0.0.1

echo
echo
echo "####################################################################################"
echo
echo "systemd-resolved stats $(tput setaf 6)*AFTER*$(tput sgr 0) testing:"
echo
echo "NOTE: Numbers should increment after executing tests requiring name resolution above"
echo
systemd-resolve --statistics
