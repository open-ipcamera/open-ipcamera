#!/bin/bash
# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.65.01
# "open-ipcamera-config.sh": Installs and configs Raspberry Pi camera application related camera Kernel module and motion detection alerts
#   Hardware:   Raspberry Pi 2/3B+
#   OS:         Raspbian "Stretch" 9.6 (lsb_release -a)
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
############## GPG KEY VARIABLES: ##############
# Anybody with *PHYSICAL* access to a Pi can get the MicroSD card and it is game-over for security.
# However steps can be taken to harden Pi from attacks from attacks by REMOTE users on a network- ie the Internet.
# NOTE: YOUR GPG SECRET KEY WILL *NOT* BE STORED ON THE PI- it stays on your own computer.
# For a GPG Encryption Boot-Camp to understand what to plug into below GPG variables visit my YouTube Channel "www.YouTube.com/user/LinuxEngineer"
# WARNING: If you are NOT supplying your own GPG Key ID in below variable do NOT change default value of *YourGPGkeyIDhere*
GPGKEYIDPUBLICYOURS='YourGPGkeyIDhere'
GPGKEYIDPUBLICYOURSEMAIL='emailAddressAssociatedWithGPGkeyIDHere'
############## Linux OS VARIABLES:  ##############
OURHOSTNAME='pi3Bplus-camera1'
OURDOMAIN='f1linux.com'
# Set a threshold value to be notified when Pi temperature exceeds it:
HEATTHRESHOLDWARN='60'
# WARNING: Do NOT set SHUTDOWN threshold too low or test will evaluate true as soon as pi boots causing it to just keep rebooting
# NOTE: Pi3B+ can run hot: https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=138193
HEATTHRESHOLDSHUTDOWN='75'
############## SNMP Monitoring ##############
# "SNMPLOCATION" is a descriptive location of the area camera covers
SNMPLOCATION='Office Door'
# NOTE: The email address specified in variable SNMPSYSCONTACT will be the one used for ALL System Alerts
SNMPSYSCONTACT='accountToReceiveAlerts@domain.com'
############## MSMTP (to send alerts): ##############
# NOTE: Both Self-Hosted and GMAIL SMTP Relay Accounts will be configured using below variables.
#	However only 1 of the 2 accounts needs to work for email alerts to start flowing
# SELF-HOSTED SMTP Relay Mail Server: This is the Primary MSMTP relay account that is configured
SMTPRELAYPORT='25'
SMTPRELAYFQDN='mail.your-SMTP-relay-goes-here.co.uk'
SMTPRELAYFROM='yourName@domainYouWantAlertsToAppearToBeSentFrom.com'
############## Camera Application "Motion" ##############
IPV6ENABLED='on'
# With camera positioned flat on base of Smarti Pi case (USB ports facing up) we need to rotate picture 180 degrees:
ROTATE='180'
# log_level directive values: EMR (1) ALR (2) CRT(3) ERR(4) WRN(5) NTC(6) INF(7) DBG(8) ALL(9)
LOGLEVEL='4'
WEBCONTROLPORT='8080'
STREAMPORT='8081'
# Max VIDEO Resolution PiCam v2: 1080p30, 720p60, 640x480p90
# Max IMAGE Resolution PiCam v2: 3280 x 2464
# NOTE: If you have a lot of PiCams all puking high-res images can cause bandwidth issues when copying them to Dropbox
WIDTH='1640'
HEIGHT='1232'
FRAMERATE='1'
# Autobrightness can cause wild fluctuations causing it PiCam to register each change as a motion detection creating a gazillion images. Suggested value= "off"
AUTOBRIGHTNESS='off'
QUALITY='65'
FFMPEGOUTPUTMOVIES='on'
MAXMOVIETIME='60'
FFMPEGVIDEOCODEC='mp4'
THRESHOLD='1500'
LOCATEMOTIONMODE='preview'
LOCATEMOTIONSTYLE='redbox'
OUTPUTPICTURES='best'
STREAMQUALITY='50'
STREAMMOTION='1'
STREAMLOCALHOST='off'
STREAMAUTHMETHOD='0'
WEBCONTROLLOCALHOST='off'
############## open-ipcamera INSTALL VARIABLES: ##############
#*#*#*#*#*#*#*# NOT END-USER CONFIGURABLE: #*#*#*#*#*#*#*#
# You risk breaking the open-ipcamera install if you change the values or operation of below variables:
# Project Developer (Terrence Houlahan) Public key provided to offer users option of sending encrypted bug reports
# terrence.houlahan@open-ipcamera.net Key Fingerprint: 704F CD25 56C4 0AF8 F2FB  D8E2 E5A1 DE67 F98F A66F
GPGPUBKEYIDDEVELOPERTERRENCE='E5A1DE67F98FA66F'
GPGPUBKEYDEVELOPERTERRENCE='PubKey_terrence.houlahan_at_open-ipcamera.net_KeyID_FE5A1DE67F98FA66F.asc'
PACKAGESINSTALLED=$(cat /var/log/apt/history.log|grep "Commandline"|grep "install"|awk '{print $5}'|uniq)
PACKAGESPURGED=$(cat /var/log/apt/history.log|grep "Commandline"|grep "purge"|awk '{print $4}'|uniq)
# Following variables self-resolve host IPv4/6v addresses so they can be automatically inserted in config files to avoid manual configuration
# * CAMERAIPV4 * Prints first non-local IPv4 address. If connected both wired and wirelessly the IP of eth0 will take precedence based on implied logic cable was connected for some reason
CAMERAIPV4="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
# * CAMERAIPV6 * Looks for and prints an IPv6 Global Unicast Address if such an interface is configured
CAMERAIPV6="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"
# VERSIONLATEST variable used to determine the latest version actually downloaded to system and available to use as a patching end-point
VERSIONLATEST="$(grep -m1 '# Version' $0|awk '{print $3}'| cut -d 'v' -f2)"
# VERSIONREPO variable used to determine most current version on REPO- this used to determine whether or not to commence an upgrade
VERSIONREPO=$(curl -s 'https://github.com/f1linux/open-ipcamera/tags/'|grep -o "$Version v[0-9][0-9].[0-9][0-9].[0-9][0-9]"|sort -r|head -n1|cut -d 'v' -f2)
# To check the version of a previously installed version we go outside the repo path to a script installed by HereDoc:
VERSIONINSTALLED="$(cat /home/pi/open-ipcamera-scripts/version.txt 2>/dev/null)"
PATHOPENIPCAMERAREPO='https://github.com/f1linux/'
PATHSCRIPTS='/home/pi/open-ipcamera-scripts'
# Only logging relate to installing/upgrading of open-ipcamera will live here. No subsequent logging writes here to provide a starting point for analyzing change from a clean build
PATHLOGINSTALL='/home/pi/open-ipcamera-logs'
PATHINSTALLDIR='/home/pi/open-ipcamera'
# Service logs are pointed to USB storage to reduce writes to MicroSD card. SystemD JournalD logs cannot be redirected however and are written to /var on card
PATHLOGSAPPS='/media/automount1/logs'
# This script is designed to run *mostly* unattended. Package installation requiring user input is therefore undesirable
# We set a non-persistent (will not survive reboot) preference for duration of our script:
export DEBIAN_FRONTEND=noninteractive