#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 1.40

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


### Create Directories for home-rolled stuff to live in:

echo
echo "$(tput setaf 5)****** Create open-ipcamera Scripts Directory:  ******$(tput sgr 0)"
echo

if [ ! -d $PATHSCRIPTS ]; then
	mkdir -p $PATHSCRIPTS
	chown pi:pi $PATHSCRIPTS
	chmod 751 $PATHSCRIPTS
	echo "Created $PATHSCRIPTS Directory"
fi


echo
echo "$(tput setaf 5)****** Remove Packages:  ******$(tput sgr 0)"
echo

# Package * usbmount * will interfere with SystemD Auto-mounts which we will use for the USB Flash Drive where video and images are written locally to.
# We check to see if it is present and if test evalutes *true* we get rid of it
if [[ ! $(dpkg -l | grep usbmount) = '' ]]; then
	apt-get -qqy purge usbmount > /dev/null
	status-apt-cmd
fi



# Test for presence of Libre Office "Writer" package and if true (not an empty value) wipe it and all the other crap that comes with it:
if [[ ! $(dpkg -l | grep libreoffice-writer) = '' ]]; then
	echo "Libre Office found."
	echo "Can take over a minute to remove it. Script might appear to hang"
	apt-get -qqy purge libreoffice* > /dev/null
	echo
	echo "Libre Office wiped from system"
	echo
else
	echo
	echo "Libre Office not found on system"
	echo
fi


echo
echo "$(tput setaf 5)****** Re-Sync Package Index:  ******$(tput sgr 0)"
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
echo "$(tput setaf 5)****** Install Packages:  ******$(tput sgr 0)"
echo


echo 'Packages could be installed in a single command but are done separately both to'
echo 'illustrate what is being installed and to make it easier to change packages by functionality'
echo
echo '*apt-get --install-recommends install packageName* could be used to install recommended pkgs but this is a blunt instrument that frequently installs tons of crap.'
echo 'So only selective recommended packages (per *apt-cache show packageName*) have been added to each *apt-get install* command where appropriate'
echo
# debconf-utils is useful for killing pesky TUI dialog boxes that break unattended package installations by requiring user input during scripted package installs:
if [[ $(dpkg -l | grep debconf-utils) = '' ]]; then
	until apt-get -qqy install debconf-utils > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
	done
fi

status-apt-cmd


# Grab the Kernel headers
if [[ $(dpkg -l | grep raspberrypi-kernel-headers) = '' ]]; then
	until apt-get -qqy install raspberrypi-kernel-headers > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# Ensure git installed: required to grab repos using * git clone *
if [[ $(dpkg -l | grep git) = '' ]]; then
	until apt-get -qqy install git > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi


# bc required for comparative testing of equality in conditional expressions
if [[ $(dpkg -l | grep bc) = '' ]]; then
	until apt-get -qqy install bc > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


if [[ $(dpkg -l | grep exfat-fuse) = '' ]]; then
	until apt-get -qqy install exfat-fuse > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		status-apt-cmd
		echo
	done
fi

status-apt-cmd


# * motion * is package used by camera to capture video evidence
# Note: ffmpeg is not a dependency of the motion package but shown as a *recommends* so we will install it
if [[ $(dpkg -l | grep motion) = '' ]]; then
	until apt-get -qqy install motion ffmpeg > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# * msmtp * is used to relay motion detection email alerts:
if [[ $(dpkg -l | grep msmtp) = '' ]]; then
	until apt-get -qqy install msmtp > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# SNMP monitoring will be configured:
if [[ $(dpkg -l | grep snmpd) = '' ]]; then
	until apt-get -qqy install snmp snmpd snmp-mibs-downloader libsnmp-dev > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


if [[ $(dpkg -l | grep -w '\Wvim\W') = '' ]]; then
	until apt-get -qqy install vim > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		sleep 2
	done
fi

status-apt-cmd


# nmap used to test ports during install to alert user of potential connectivity issues
if [[ $(dpkg -l | grep nmap) = '' ]]; then
	until apt-get -qqy install nmap > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# gnupg for encrypting data and creating digital signatures. Used to encrypt the variables.sh file which contains passwords
if [[ $(dpkg -l | grep gnupg) = '' ]]; then
	until apt-get -qqy install gnupg > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# dirmngr is the GPG network certificate management service
if [[ $(dpkg -l | grep dirmngr) = '' ]]; then
	until apt-get -qqy install dirmngr > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# gnupg-agent used to request and cach password for keychain access
if [[ $(dpkg -l | grep gnupg-agent) = '' ]]; then
	until apt-get -qqy install gnupg-agent > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# Enhanced diff toolset for analyzing change.
if [[ $(dpkg -l | grep diffutils) = '' ]]; then
	until apt-get -qqy install diffutils > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# *expect* is a tool for automating interactive processes in scripts by providing an answer to a question that would break unattended execution of a script
if [[ $(dpkg -l | grep expect) = '' ]]; then
	until apt-get -qqy install expect > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# *parallel* tool for executing jobs in parallel
if [[ $(dpkg -l | grep parallel) = '' ]]; then
	until apt-get -qqy install parallel > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd





echo
echo 'Below packages not required for configuration as a Motion Detection Camera'
echo 'but included as they are useful tools to have on the system:'
echo
echo 'For info about a particular package: * sudo apt-cache show packagename *'
echo


if [[ $(dpkg -l | grep mutt) = '' ]]; then
	apt-get -qqy install mutt > /dev/null
	apt update > /dev/null
	status-apt-cmd
fi


# apt-file is a package searching tool.  Useful addition to any Debian-based system
if [[ $(dpkg -l | grep apt-file) = '' ]]; then
	apt-get -qqy install apt-file > /dev/null
	apt update > /dev/null
	status-apt-cmd
fi


# *netselect-apt* analyzes available mirrors by running some tests and then sets fastest one for you
# Great tool but has firewall dependencies on UDP traceroute and ICMP it uses for testing latency so decided not to configure it during the Pi-Cam config
# To MANUALLY configure netselect-apt:
#      sudo netselect-apt --arch armhf --nonfree --outfile /etc/apt/sources.list
# Then edit the "sources.list" file and change "stable" TO "stretch" (or whatever the current Raspbian flavour of the day is)
if [[ $(dpkg -l | grep netselect-apt) = '' ]]; then
	apt-get -qqy install netselect-apt > /dev/null
	apt update > /dev/null
	status-apt-cmd
fi


# *libimage-exiftool-perl* used to get metadata from videos and images from the CLI. Top-notch tool
# http://owl.phy.queensu.ca/~phil/exiftool/
if [[ $(dpkg -l | grep libimage-exiftool-perl) = '' ]]; then
	apt-get -qqy install libimage-exiftool-perl > /dev/null
	status-apt-cmd
fi


# *exiv2* is another tool for obtaining and changing media metadata but has limited support for video files- wont handle mp4- compared to *libimage-exiftool-perl*
# http://www.exiv2.org/
if [[ $(dpkg -l | grep exiv2) = '' ]]; then
	apt-get -qqy install exiv2 > /dev/null
	status-apt-cmd
fi


if [[ $(dpkg -l | grep mailutils) = '' ]]; then
	apt-get -qqy install mailutils > /dev/null
	status-apt-cmd
fi


# "screen" creates a shell session that can remain active after an SSH session ends that can be reconnected to on future SSH sessions.
# If you have a flaky Internet connection or need to start a long running process  screen" is your friend
if [[ $(dpkg -l | grep screen) = '' ]]; then
	apt-get -qqy install screen > /dev/null
	status-apt-cmd
fi


# mtr is like traceroute on steroids.  All network engineers I know use this in preference to "traceroute" or "tracert":
if [[ $(dpkg -l | grep mtr) = '' ]]; then
	apt-get -qqy install mtr > /dev/null
	status-apt-cmd
fi

# tcpdump is a packet sniffer you can use to investigate connectivity issues and analyze traffic:
if [[ $(dpkg -l | grep tcpdump) = '' ]]; then
	apt-get -qqy install tcpdump > /dev/null
	status-apt-cmd
fi

# iptraf-ng can be used to investigate bandwidth issues if you are puking too many chunky images over a thin connection:
if [[ $(dpkg -l | grep iptraf-ng) = '' ]]; then
	apt-get -qqy install iptraf-ng > /dev/null
	status-apt-cmd
fi


# "vokoscreen" is a great screen recorder that can be minimized so it is not visible in video
# "recordmydesktop" generates videos with a reddish cast - for at least the past couple of years- so I use "vokoscreen" and "vlc" will be installed instead
if [[ $(dpkg -l | grep vokoscreen) = '' ]]; then
	apt-get -qqy install vokoscreen libx264-148 > /dev/null
	status-apt-cmd
fi


# VLC can be used to both play video and also to record your desktop for HowTo videos of your Linux projects:
if [[ $(dpkg -l | grep vlc) = '' ]]; then
	apt-get -qqy install vlc vlc-plugin-access-extra browser-plugin-vlc > /dev/null
	status-apt-cmd
fi


# dstat is an diagnostic tool to gain insight into performance issues regarding memory storage and CPU
if [[ $(dpkg -l | grep dstat) = '' ]]; then
	apt-get -qqy install dstat > /dev/null
	status-apt-cmd
fi


# ipcalc useful for perform IPv4 calculations and processing the results in scripts
if [[ $(dpkg -l | grep ipcalc) = '' ]]; then
	apt-get -qqy install ipcalc > /dev/null
	status-apt-cmd
fi


# ipv6calc another IP calculations tool useful for extracting and manipulating addressing info in scripted tests
if [[ $(dpkg -l | grep ipv6calc) = '' ]]; then
	apt-get -qqy install ipv6calc > /dev/null
	status-apt-cmd
fi




# How to answer "no" to an interactive TUI dialog box in a script for an non-interactive installs:
#	https://unix.stackexchange.com/questions/106552/apt-get-install-without-debconf-prompt
# 	http://www.microhowto.info/howto/perform_an_unattended_installation_of_a_debian_package.html

# * boolean false * is piped to debconf-set-selections to pre-seed the answer to interactive install question *Should kexec-tools handle reboots(sysvinit only)?*
if [[ $(dpkg -l | grep kexec-tools) = '' ]]; then
	echo kexec-tools kexec-tools/load_exec boolean false | debconf-set-selections
	apt-get -qq install kexec-tools > /dev/null
	status-apt-cmd
	echo
fi
