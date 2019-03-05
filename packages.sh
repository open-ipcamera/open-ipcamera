#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.75.02

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
echo "$(tput setaf 5)******  PACKAGES: Remove conflicting packages or bloatware from default Raspbian image  ******$(tput sgr 0)"
echo

# usbmount: interferes with SystemD auto-mounts which we will use for the USB Flash Drive where video and images are written locally to
# libreoffice: it is just crap and not required on a device being used as a video camera


readarray arrayPackagesListPURGE < $PATHINSTALLDIR/packages-list-purge.txt

for i in ${arrayPackagesListPURGE[@]}; do
if [[ ! $(dpkg -l | grep "^ii  $i[[:space:]]") = '' ]]; then
	apt-get -qqy purge $i > /dev/null
fi
done




echo
echo "$(tput setaf 5)******  PACKAGES: Re-Sync Index:  ******$(tput sgr 0)"
echo

until apt-get -qqy update > /dev/null
	do
		echo
		echo "$(tput setaf 5)apt-get update failed. Retrying$(tput sgr 0)"
		echo "$(tput setaf 3)Check your Internet Connection$(tput sgr 0)"
		echo
	done

echo 'Package Index Updated'
echo


echo
echo "$(tput setaf 5)******  Install Packages:  ******$(tput sgr 0)"
echo

# For info about a particular package to learn more about what it actually does:
#	sudo apt-cache show packagename

#######  PACKAGES: REQUIRED  #######

# debconf-utils: provides debconf-set-selections used to kill TUI dialog boxes that break scripted package installs which demand user input
#	To see all the other utilities debconf-utils provides:
#		dpkg-query -L debconf-utils
# git: required to clone the open-ipcamera repo from GitHub and upgrade an installed open-ipcamera installation
# bc: required for comparative testing of equality in conditional expressions
# snmpd: Monitoring
# motion: package used by camera to capture video evidence
# ffmpeg: not a dependency of motion per se but shown as a *recommends* so we install it
# nmap: troubleshooting tool to connectivity issues related to closed ports
# dirmngr GPG network certificate management service
# gnupg: encrypting data and creating digital signatures. Used to encrypt variables.sh file which contains passwords
# gnupg-agent: used to request and cache password for keychain access
# diffutils: Enhanced diff toolset for analyzing change
# msmtp: used to relay motion detection email alerts
# expect: tool for automating interactive processes in scripts by providing an answer to a question that would break unattended execution of a script
# parallel: tool for executing jobs in parallel


#######  PACKAGES: OPTIONAL  #######
# These are packages not required for Motion Detection Camera configuration but included as useful tools to maintain/troubleshoot the system

# libimage-exiftool-perl: used to query/modify metadata from videos and images from CLI: http://owl.phy.queensu.ca/~phil/exiftool/
# exiv2: Another tool for obtaining and changing media metadata but limited support for video files- wont handle mp4:  http://www.exiv2.org/
# screen: Creates a shell session that can remain active after an SSH session ends that can be reconnected to on future SSH sessions.
# mtr: Think of it as traceroute on steroids.  All network engineers I know use this in preference to "traceroute" or "tracert"
# tcpdump: packet sniffer useful for investigating connectivity issues and analyzing traffic
# iptraf-ng: Used to investigate bandwidth issues
# vokoscreen: Screen recorder. Can be run minimized so screenrecorder itself not visible in video. "recordmydesktop" generates videos with a reddish cast which has been unresolved prob for YEASRS.
# VLC: Can be used both to play videos and also as a screenrecorder for creating HowTos for your projects
# dstat: Diagnostic tool for performance issues relating to memory storage and CPU.  Better alternqative to netstat and iostat:  http://dag.wiee.rs/home-made/dstat/
# ipcalc: Used to perform IPv4 calculations and results are used in scripts
# ipv6calc: another IP calculations tool useful for extracting and manipulating addressing info in scripted tests
# apt-file: package searching tool but oddly not installed by default

# netselect-apt: analyzes available mirrors by running some tests and then sets fastest one for you
# 	Great tool but has firewall dependencies on UDP traceroute and ICMP it uses for testing latency so I decided not to configure it during open-ipcamera installation
# 	To MANUALLY configure:
#      	sudo netselect-apt --arch armhf --nonfree --outfile /etc/apt/sources.list
# 	Then edit "sources.list" file and change "stable" TO "stretch" (or whatever the current Raspbian release is)


echo
echo "Script may appear to hang.  Just takes several minutes to install the Required and Optional packages"
echo


readarray arrayPackagesListRequired < $PATHINSTALLDIR/packages-list-required.txt

for i in ${arrayPackagesListRequired[@]}; do
if [[ $(dpkg -l | grep "^ii  $i[[:space:]]") = '' ]]; then
	until apt-get -qqy install $i > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
	done
fi
done



readarray arrayPackagesListOptional < $PATHINSTALLDIR/packages-list-optional.txt

for i in ${arrayPackagesListOptional[@]}; do
if [[ $(dpkg -l | grep "^ii  $i[[:space:]]") = '' ]]; then
	until apt-get -qqy install $i > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
	done
fi
done


########  Below Packages Require Unique Installation due to TUI Dialogs Which Can Break Scripted Installs:  ########

# How to answer "no" to an interactive TUI dialog box in a script for an non-interactive installs:
#	https://unix.stackexchange.com/questions/106552/apt-get-install-without-debconf-prompt
# 	http://www.microhowto.info/howto/perform_an_unattended_installation_of_a_debian_package.html

# * boolean false * is piped to debconf-set-selections to pre-seed the answer to interactive install question *Should kexec-tools handle reboots(sysvinit only)?*

if [[ $(dpkg -l | grep kexec-tools) = '' ]]; then
	echo kexec-tools kexec-tools/load_exec boolean false | debconf-set-selections
	apt-get -qq install kexec-tools > /dev/null
fi



echo
echo "$(tput setaf 5)******  Verify All Packages Installed Successfully:  ******$(tput sgr 0)"
echo
echo "Expected result of lists returned below is to be empty: if not investigate failed package installs"



echo
echo "$(tput setaf 1)FAILED$(tput sgr 0) Package Installs: REQUIRED Packages"
echo

# /var/log/apt/history.log only shows successful operations which changed the package database- it does NOT show FAILURES
# After installing packages we loop through an array using same lists used to install but now we echo package name if NOT found by dpkg

readarray arrayPackagesListFailedInstallRequired < $PATHINSTALLDIR/packages-list-required.txt

for i in ${arrayPackagesListFailedInstallRequired[@]}; do
if [[ $(dpkg -l | grep "^ii  $i[[:space:]]") = '' ]]; then
	echo "$(tput setaf 1)$i$(tput sgr 0)"
fi
done



echo
echo "$(tput setaf 1)FAILED$(tput sgr 0) Package Installs: OPTIONAL Packages"
echo


readarray arrayPackagesListFailedInstallOptional < $PATHINSTALLDIR/packages-list-optional.txt

for i in ${arrayPackagesListFailedInstallOptional[@]}; do
if [[ $(dpkg -l | grep "^ii  $i[[:space:]]") = '' ]]; then
	echo "$(tput setaf 1)$i$(tput sgr 0)"
fi
done


echo 



# Update apt-file DB with new packages installed so they can be searched with this utility:
$(command -v apt-file) update > /dev/null

# Populate the *locate* db:
$(command -v updatedb)  > /dev/null


echo "$PACKAGESINSTALLED" >> $PATHLOGINSTALL/packages-installed-v$VERSIONLATEST.log
echo "$PACKAGESPURGED"  >> $PATHLOGINSTALL/packages-purged-v$VERSIONLATEST.log
