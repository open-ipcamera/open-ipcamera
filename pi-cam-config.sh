#!/bin/bash

# Author:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20181201

# "pi-cam-config.sh": Installs and configs Raspberry Pi camera application, related camera Kernel module and motion detection alerts
#   Hardware:   Raspberry Pi 2/3B+ *AND* Pi Zero W
#   OS:         Raspbian "Stretch" 9.6 (lsb_release -a)

######  License: ######
#
# Copyright (C) 2018 Terrence Houlahan
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


######  INSTALL INSTRUCTIONS: ######

# README.txt file distributed with this script
# VIDEO:  www.YouTube.com/user/LinuxEngineer

# If I saved you a few hours or possibly DAYS manually configuring one or more pi-cams perhaps consider buying me a beer:
#   paypal.me/TerrenceHoulahan

######  Variables: ######
#
# Variables are expanded in sed expressions and auto-populating variables.
# Change or delete specimen values below as appropriate:

### Variables: Linux
#OURHOSTNAME='pi0w-1'
OURHOSTNAME='pi3Bplus-camera1'
OURDOMAIN='f1linux.com'
PASSWDPI='ChangeMe1234'
PASSWDROOT='ChangeMe1234'

# ** WARNING ** REPLACE MY PUBLIC KEY BELOW WITH YOUR OWN. If your Pi is behind a NAT I cannot reach it but leaving my Key is a really bad idea
MYPUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/4ujZFHJrXgAracA7eva06dz6XIz75tKei8UPZ0/TMCb8z01TD7OvkhPGMA1nqXv8/ST7OqG22C2Cldknx+1dw5Oz8FNekHEJVmuzVGT2HYvcmqr4QrbloaVfx2KyxdChfr9fMyE1fmxRlxh1ZDIZoD/WrdGlHZvWaMYuyCyqFnLdxEF/ZVGbh1l1iYRV9Et1FhtvIUyeRb5ObfJq09x+OlwnPdS21xJpDKezDKY1y7aQEF+D/EhGk/UzA91axpVVM9ToakupbDk+AFtmrwIO7PELxHsN1TtA91e2dKOps3SmcVDluDoUYjO33ozNGDoLj08I0FJMNOClyFxMmjUGssA4YIdiYIx3+uae3Bjnu4qpwyREPxxiWZwt20vzO6pvyxqhjcU49gmAgp1pOgBXkkkpu/CHiDFGAJW06nk1QgK9NwkNKL2Tbqy30HY4K/px1OkgaDyvXIRvz72HRR+WZIfGHMW8RLa7ceoUU4dXObqgUie0FGAU23b2m2HTjYSyj2wAAFp5ONkp9F6V2yeeW1hyRvEwQnX7ov95NzIMvtvYvn5SIX7GVIy+/8TlLpChMCgBJ4DV13SVWwa5E42HnKILoDKTZ3AG0ILMRQsJdv49b8ulwTmvtEmHZVRt7mEVF8ZpVns68IH3zYWIDJioSoKWpj7JZGNUUPo79PS+wQ== terrence@Terrence-MBP.local'

#### Dropbox-Uploader Variables:
# Dropbox used to shift video and pics to the cloud to prevent evidence being destroyed or stolen
# Please consult "README.txt" for how to obtain the value for below variable
DROPBOXACCESSTOKEN='ABCD1234'

# Set a threshold value to be notified when Pi exceeds it:
HEATTHRESHOLDWARN='71'
HEATTHRESHOLDSHUTDOWN='91'

### Variables: SNMP Monitoring
# "SNMPLOCATION" is a descriptive location of the area the camera covers
SNMPLOCATION='Back Door'
SNMPV3AUTHPASSWD='PiDemo1234'
SNMPV3ENCRYPTPASSWD='PiDemo1234'
SNMPV3ROUSER='pi'

### Variables: MSMTP (to send alerts):
# SELF-HOSTED SMTP Relay Mail Server:
SMTPRELAYPORT='25'
SASLUSER='terrence'
SASLPASSWD='xUn&G5d4RqYk9Lj%4R3D2V8z&2HapP@7EywfG6!b3Mi?B7'
SMTPRELAYFQDN='mail.linuxengineer.co.uk'
SMTPRELAYFROM='terrence@houlahan.co.uk'

# GMAIL SMTP Relay Server:  NOTE: Requires a PAID Google-hosted mail account
GMAILADDRESS='terrence.houlahan.devices@gmail.com'
GMAILPASSWD='YourGmailPasswdHere'


# Specify an email address where IP of camera will be sent to you
# This email address can be different than the one specified in 'ONEVENTSTART' variable below
NOTIFICATIONSRECIPIENT='terrence.houlahan.devices@gmail.com'

### Variables: Camera Application "Motion"
# NOTE: "motion.conf" has many more adjustable parameters than those below, which are a subset of just very useful or required ones:

# Only modify "Subject: Motion Detected" if you want to change it. Take care not to delete any of the encasing single quote marks
ONEVENTSTART='echo '"'Subject: Motion Detected ${hostname}'"' | msmtp '"'$NOTIFICATIONSRECIPIENT'"''

IPV6ENABLED='on'
# NOTE: user for Camera application "Motion" login does not need to be a Linux system user account created with "useradd" command: can be arbitrary
USER='me'
PASSWD='CHANGEME1234'

# With camera positioned flat on the base of the Smarti Pi case (USB ports facing up) we need to rotate picture 180 degrees:
ROTATE='180'

# log_level directive values: EMR (1) ALR (2) CRT(3) ERR(4) WRN(5) NTC(6) INF(7) DBG(8) ALL(9)
# https://motion-project.github.io/motion_config.html#log_level
LOGLEVEL='4'

# You can change ports below if you configure other web services on camera host and they cause a port conflict.
# Otherwise the ports do not need to be changed:
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


# Below variables are self-populating- DO NOT EDIT THESE:
# They automagically identify the IP address of camera and inserts it in config files where an IP needs to be specified
CAMERAIPV4="$(ip addr list|grep wlan0|awk '{print $2}'|cut -d '/' -f1|cut -d ':' -f2)"
CAMERAIPV6="$(ip -6 addr list|grep inet6|grep 'scope link'| awk '{ print $2}'|cut -d '/' -f1)"


#############################################################
# ONLY EDIT BELOW THIS LINE IF YOU KNOW WHAT YOU ARE DOING! #
#############################################################


# This script is designed to run *mostly* unattended. Package installation requiring user input is therefore undesirable
# We will set a non-persistent (will not survive reboot) preference for duration of our script as *noninteractive*:
export DEBIAN_FRONTEND=noninteractive


############## FUNCTIONS: ###############

# Note that "notify-apt-failure" Calls the other function "apt-cmd-last"
status-apt-cmd () {
if [[ $(echo $?) != 0 ]]; then
	echo "$(tput setaf 1)Apt Command FAILURE:$(tput sgr 0)"
else
	echo "$(tput setaf 2)Apt Command SUCCESS:$(tput sgr 0) $(apt-cmd-last)"
fi
}

# Below function extracts the LAST *SUCCESSFUL* apt command executed from the apt history log. 
# Note that *UNSUCCESSFUL* attempts are not recorded in that log
apt-cmd-last () {
tail -5 /var/log/apt/history.log|grep -i "Commandline"|cut -d ':' -f2
}

#########################################

echo
echo "$(tput setaf 5)****** CREDITS:  ******$(tput sgr 0)"
echo
echo "My script takes the work of others folks and stitches it all together into a complete Motion Detection Camera Solution."
echo "So its right that I take a moment to thank those Open Source folks who toil in anonymity that provided me with the key components for my efforts:"
echo
echo "ANDREA FABRIZI: My script pi-cam-config.sh downloads and uses Andrea repo to shift images from local USB Flash storage to Dropbox"
echo "		$(tput setaf 2) https://github.com/andreafabrizi/Dropbox-Uploader.git $(tput sgr 0)"
echo
echo "Motion Project Team Members: Joseph Heenan * Mr-Dave *  Tosiara.  Their Software is used for Motion Detection"
echo "		$(tput setaf 2) https://github.com/orgs/Motion-Project/people$(tput sgr 0)"
echo
echo "Martin Lambers: MSMTP SMTP client used to squirt motion detection and other alerts"
echo "		$(tput setaf 2) https://gitlab.marlam.de/marlam/msmtp$(tput sgr 0)"
echo
echo "And of Course Thanks to DROPBOX for a really great API that makes shifting the images up to the cloud possible.  Outstanding company."
echo
echo

echo
echo "$(tput setaf 5)****** LICENSE:  ******$(tput sgr 0)"
echo

echo '"pi-cam-config.sh" Copyright (C) 2018 Terrence Houlahan'
echo
echo "This program comes with ABSOLUTELY NO WARRANTY express or implied."
echo "This is free software and you are welcome to redistribute it under certain conditions."
echo "Consult * LICENSE.txt * for terms of GPL 3 License and conditions of use."

read -p "Press ENTER to accept license and warranty terms to continue or close this bash shell to exit the script"



echo
echo "$(tput setaf 5)****** DELETE LIBRE OFFICE:  ******$(tput sgr 0)"
echo
echo "This is a camera: we do not require office applications."
echo
echo "Checking if Libre Office present and will remove if found."
echo "Can take over a minute to remove Libre Office- script might appear to hang"


# Test for presence of Libre Office "Writer" package and if true (not an empty value) wipe it and all the other crap that comes with it:
if [[ ! $(dpkg -l | grep libreoffice-writer) = '' ]]; then
	apt-get -qqy purge libreoffice* > /dev/null
	echo
	echo "Libre Office wiped from system"
	echo
else
	echo "Libre Office not found on system"
fi



echo
echo "$(tput setaf 5)****** DELETE DETRITUS FROM PRIOR INSTALLS:  ******$(tput sgr 0)"
echo
echo "$(tput setaf 2)### Restore Pi to predictable known state by removing artefacts left by prior executions of this script: ###$(tput sgr 0)"
echo

# Reset the hosts file back to default state
sed -i "s/127\.0\.0\.1.*/127\.0\.1\.1      raspberrypi/" /etc/hosts
sed -i "s/::1.*/::1     raspberrypi/" /etc/hosts

# Restore the default hostname:
hostnamectl set-hostname raspberrypi
systemctl restart systemd-hostnamed&
wait $!


# Delete packages and any related config files with "apt-get purge":

if [[ ! $(dpkg -l | grep raspberrypi-kernel-headers) = '' ]]; then
	apt-get -qqy purge raspberrypi-kernel-headers > /dev/null
fi


if [[ ! $(dpkg -l | grep motion) = '' ]]; then
	apt-get -qqy purge motion > /dev/null
fi


if [[ ! $(dpkg -l | grep msmtp) = '' ]]; then
	apt-get -qqy purge msmtp > /dev/null
fi


if [[ ! $(dpkg -l | grep snmpd) = '' ]]; then
	systemctl stop snmpd.service
	systemctl disable snmpd.service
	rm /etc/snmp/snmp.conf
	rm /etc/snmp/snmpd.conf
	apt-get -qqy purge snmp snmpd snmp-mibs-downloader libsnmp-dev > /dev/null
fi



# Delete "Dropbox-Uploader"
if [ -d /home/pi/Dropbox-Uploader ]; then
	rm -rf /home/pi/Dropbox-Uploader
fi

# Delete file that loads the camera kernel module on boot:
if [ -f /etc/modules-load.d/bcm2835-v4l2.conf  ]; then
	rm /etc/modules-load.d/bcm2835-v4l2.conf
fi


### Uninstall any SystemD services and their related files:


if [ -f /etc/systemd/system/set-cpu-affinity.service ]; then
	systemctl disable set-cpu-affinity.service
	rm /etc/systemd/system/set-cpu-affinity.service
	rm /home/pi/scripts/set-cpu-affinity.sh
fi



# Uninstall automount service for USB flash storage:
if [ -f /etc/systemd/system/media-pi.mount ]; then
	systemctl stop media-pi.mount
	systemctl disable media-pi.mount
	rm /etc/systemd/system/media-pi.mount
	rm /etc/systemd/system/media-pi.automount
fi



# Uninstall dropbox photo uploader SystemD service:
# NOTE: This is NOT part of the Dropbox-uploader script- it just uses it
if [ -f /etc/systemd/system/Dropbox-Uploader.service ]; then
	systemctl disable Dropbox-Uploader.service
	systemctl disable Dropbox-Uploader.timer
	rm /etc/systemd/system/Dropbox-Uploader.service
	rm /etc/systemd/system/Dropbox-Uploader.timer
fi


if [ -f /etc/systemd/system/email-camera-address.service ]; then
	systemctl stop email-camera-address.service
	systemctl disable email-camera-address.service
	rm /etc/systemd/system/email-camera-address.service
fi


if [ -f /etc/systemd/system/heat-alert.service ]; then
	systemctl stop heat-alert.service
	systemctl disable heat-alert.service
	systemctl stop heat-alert.timer
	systemctl disable heat-alert.timer
	rm /etc/systemd/system/heat-alert.service
	rm /etc/systemd/system/heat-alert.timer
fi



# Update the system to changes we made above to services:
systemctl daemon-reload


# Delete scripts home-rolled scripts created by here-doc from previous runs of "pi-cam-config.sh" that SystemD services were calling:

if [ -d /home/pi/scripts ]; then
	rm -r /home/pi/scripts
fi

if [ -d /media/pi/logs ]; then
	rm -r /media/pi/logs
fi

# Delete local config files not removed when their package was purged:

# Delete SSH keys: our public key and "pi" user keys
if [ -d /home/pi/.ssh ]; then
	rm -R /home/pi/.ssh
fi


if [ -f /home/pi/.vimrc ]; then
	rm /home/pi/.vimrc
fi

if [ -f /etc/msmtprc ]; then
	rm /etc/msmtprc
fi

if [ -f /home/pi/.muttrc ]; then
	rm /home/pi/.muttrc
fi



# Truncate any messages previously appended to MOTD by this script:
truncate -s 0 /etc/motd



### Revert any changes to config files:

# Remove any aliases created for sending root's mail in /etc/aliases:
if [ -f /etc/aliases ]; then
	sed  -i '/root: $NOTIFICATIONSRECIPIENT/d' /etc/aliases
fi


# Revert back to default CPU Affinity:
sed -i "s/CPUAffinity=0 1 2/#CPUAffinity=1 2/" /etc/systemd/system.conf




echo
echo "$(tput setaf 5)******  SET HOSTNAME:  ******$(tput sgr 0)"
echo

echo "Hostname CURRENT: $(hostname)"

hostnamectl set-hostname $OURHOSTNAME.$OURDOMAIN
systemctl restart systemd-hostnamed&
wait $!
echo
echo "Hostname NEW: $(hostname)"

# hostnamectl does NOT update the hosts own entry in /etc/hosts so must do separately:
sed -i "s/127\.0\.1\.1.*/127\.0\.0\.1      $OURHOSTNAME $OURHOSTNAME.$OURDOMAIN/" /etc/hosts
sed -i "s/::1.*/::1     $OURHOSTNAME $OURHOSTNAME.$OURDOMAIN/" /etc/hosts




echo
echo "$(tput setaf 5)****** SET BOOT PARAMS:  ******$(tput sgr 0)"
echo

# raspian-config: How to interface from the CLI:
# https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup

# Clear any boot params added during a previous build and then add each back with most current value set:
# Enable camera (No raspi-config option to script this):
sed -i '/start_x=1/d' /boot/config.txt
echo 'start_x=1' >> /boot/config.txt

sed -i '/disable_camera_led=1/d' /boot/config.txt
echo 'disable_camera_led=1' >> /boot/config.txt

echo "Determine if Pi is a Zero W or NOT to set GPU memory value appropriately:"

if [ $(cat /proc/device-tree/model | awk '{ print $3 }') != 'Zero' ]; then
	echo "NOT PI ZERO!"
	echo "Setting GPU Memory to 128"
	sed -i '/gpu_mem=128/d' /boot/config.txt
	echo 'gpu_mem=128' >> /boot/config.txt
else
	echo "PI ZERO"
#	echo "Setting GPU Memory to 512"
#	sed -i '/gpu_mem=512/d' /boot/config.txt
#	echo 'gpu_mem=512' >> /boot/config.txt
fi

echo

echo "Camera enabled"
echo "Camera LED light disabled"

sed -i '/disable_splash=1/d' /boot/config.txt
echo 'disable_splash=1' >> /boot/config.txt
echo "Disabled boot splash screen so we can see errors while host is rising up."



echo
echo "$(tput setaf 5)****** CAMERA KERNEL DRIVER: Load on Boot  ******$(tput sgr 0)"
echo


# Load Kernel module for Pi camera on boot:
cat <<EOF> /etc/modules-load.d/bcm2835-v4l2.conf
bcm2835-v4l2

EOF

echo "File created to automatically load camera driver on boot:"
echo "/etc/modules-load.d/bcm2835-v4l2.conf"

# Rebuild Kernel modules dependencies map
depmod -a

# Load Camera Kernel Module
#modprobe bcm2835-v4l2
# Will automatically load on the reboot at the end of the script



echo
echo "$(tput setaf 5)****** Configure Logging:  ******$(tput sgr 0)"
echo

echo "Default System log data is non-persistent. It exists im memory and is lost on every reboot"
echo "Logging will be made persistent by writing it to disk in lieu of memory"

cp -p /etc/systemd/journald.conf /etc/systemd/journald.conf.ORIGINAL

sed -i "s/#Storage=auto/Storage=persistent/" /etc/systemd/journald.conf
# Ensure logs do not eat all our storage space by expressly limiting their TOTAL disk usage:
sed -i "s/#SystemMaxUse=/SystemMaxUse=200M/" /etc/systemd/journald.conf
# Stop writing log data even if below threshold specified in "SystemMaxUse=" if total diskspace is running low using the *SystemKeepFree* directive:
sed -i "s/#SystemKeepFree=/SystemKeepFree=1G/" /etc/systemd/journald.conf
# Limit the size log files can grow to before rotation:
sed -i "s/#SystemMaxFileSize=/SystemMaxFileSize=500M/" /etc/systemd/journald.conf
# Purge log entries older than period specified in "MaxRetentionSec" directive
sed -i "s/#MaxRetentionSec=/MaxRetentionSec=1week/" /etc/systemd/journald.conf
# Rotate log no later than a week- if not already preempted by "SystemMaxFileSize" directive forcing a log rotation
sed -i "s/#MaxFileSec=1month/MaxFileSec=1week/" /etc/systemd/journald.conf
# Valid values for MaxLevelWall: emerg alert crit err warning notice info debug
sed -i "s/#MaxLevelWall=emerg/MaxLevelWall=crit/" /etc/systemd/journald.conf
# Write only "crticial" to disk
sed -i "s/#MaxLevelStore=debug/MaxLevelStore=crit/" /etc/systemd/journald.conf
# Max notification level to forward to the Kernel Ring Buffer (/var/log/messages)
sed -i "s/#MaxLevelKMsg=notice/MaxLevelKMsg=warning/" /etc/systemd/journald.conf

echo
echo "Changes made to /etc/systemd/journald.conf by script are $(tput setaf 1)RED$(tput sgr 0)"
echo "Original values are shown in $(tput setaf 2)GREEN$(tput sgr 0)"
echo
diff --color /etc/systemd/journald.conf /etc/systemd/journald.conf.ORIGINAL
echo

# Re-Read changes made to /etc/systemd/journald.conf
systemctl restart systemd-journald

echo "LOGGING NOTES:"
echo "Although SystemD logging made persistent verbosity reduced to limit thrashing MicroSD card as much as possible"
echo "Application logs will be written to USB storage on /home/pi/logs"
echo "No similar way to change SystemD log destination by path sadly"
echo "Review above changes to logging above if you wish to tailor them edit: /etc/systemd/journald.conf"




echo
echo "$(tput setaf 5)****** Re-Sync Package Index:  ******$(tput sgr 0)"
echo

until apt-get -qq update > /dev/null
	do
		echo
		echo "$(tput setaf 5)apt-get update failed. Retrying$(tput sgr 0)"
		echo "$(tput setaf 3)Check your Internet Connection$(tput sgr 0)"
		echo
	done

echo "Package Index Updated"
echo


echo
echo "$(tput setaf 5)****** PACKAGE INSTALLATION:  ******$(tput sgr 0)"
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


# Ensure git is installed: required to grab repos using * git clone *"
if [[ $(dpkg -l | grep git) = '' ]]; then
	until apt-get -qqy install git > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi


# * motion * is the package our camera uses to capture our video evidence
if [[ $(dpkg -l | grep motion) = '' ]]; then
	until apt-get -qqy install motion > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi

status-apt-cmd


# "msmtp" is used to relay motion detection email alerts:
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

echo
echo "Below package installations not required for configuration as a Motion Detection Camera"
echo "but included as I felt they were useful.  Feel free to apt-get remove them as you wish:"
echo

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


if [[ $(dpkg -l | grep mutt) = '' ]]; then
	apt-get -qqy install mutt > /dev/null
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
	apt-get -qqy install vokoscreen > /dev/null
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





echo
echo "$(tput setaf 5)****** USER CONFIGURATION: ******$(tput sgr 0)"
echo


if [ ! -d /home/pi/scripts ]; then
	mkdir /home/pi/scripts
	chown pi:pi /home/pi/scripts
	chmod 751 /home/pi/scripts
fi


echo 'Set user bash histories to unlimited length:'
sed -i "s/HISTSIZE=1000/HISTSIZE=/" /home/pi/.bashrc
sed -i "s/HISTFILESIZE=2000/HISTFILESIZE=/" /home/pi/.bashrc
echo


echo "Changing default password *raspberry* for user *pi*"
echo "pi:$PASSWDPI"|chpasswd

# Set a password for user *root*
echo "Set passwd for user *root*"
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
echo "Added Your Public Key to 'authorized_keys' file"
echo

cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.ORIGINAL

# Modify default SSH access behaviour by tweaking below directives in /etc/ssh/sshd_config
sed -i "s|#ListenAddress 0.0.0.0|ListenAddress 0.0.0.0|" /etc/ssh/sshd_config
sed -i "s|#ListenAddress ::|ListenAddress ::|" /etc/ssh/sshd_config
sed -i "s|#SyslogFacility AUTH|SyslogFacility AUTH|" /etc/ssh/sshd_config
sed -i "s|#LogLevel INFO|LogLevel INFO|" /etc/ssh/sshd_config
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
echo
# No need for autologin now that we enabled Public Key Access so we disable it:
sed -i "s/autologin-user=pi/#autologin-user=pi/" /etc/lightdm/lightdm.conf
systemctl disable autologin@.service
echo
echo "Disabled autologin"
echo

echo "Change default editor from crap *nano* to a universal Unix standard *vi*"
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

cp /usr/share/vim/vimrc /home/pi/.vimrc

# Below sed expression stops vi from going to "visual" mode when one tries to copy text GRRRRR!
sed -i 's|^"set mouse=a.*|set mouse-=a|' /home/pi/.vimrc
sed -i 's|^"set mouse=a.*|set mouse-=a|' /etc/vim/vimrc

chown pi:pi /home/pi/.vimrc
chmod 600 /home/pi/.vimrc

echo "Created /home/pi/.vimrc"

# Create Mutt configuration file for user pi
cat <<EOF> /home/pi/.muttrc

set sendmail=$(command -v msmtp)"
set use_from=yes
set realname="$(hostname)"
set from="pi@$(hostname)"
set envelope_from=yes
set editor="vim.basic"

EOF

chown pi:pi /home/pi/.muttrc
chmod 600 /home/pi/.muttrc




echo
echo "$(tput setaf 5)****** SNMP Configuration:  ******$(tput sgr 0)"
echo


# *DISABLE* local-only connections to SNMP daemon
sed -i "s/agentAddress  udp:127.0.0.1:161/#agentAddress  udp:127.0.0.1:161/" /etc/snmp/snmpd.conf

# *ENABLE* remote SNMP connectivity to cameras:
# A further reminder to please restrict access by firewall to your cameras
sed -i "s/#agentAddress  udp:161,udp6:[::1]:161/agentAddress  udp:161,udp6:161/" /etc/snmp/snmpd.conf

# Enable loading of MIBs:
sed -i "s/mibs :/#mibs :/" /etc/snmp/snmp.conf

# Describe location of camera:
sed -i "s/sysLocation    Sitting on the Dock of the Bay/sysLocation    $SNMPLOCATION/" /etc/snmp/snmpd.conf

# Stop SNMP daemon to create a Read-Only user:
systemctl stop snmpd.service

# Only an SNMP v3 Read-Only user will be created to gain visibility into pi hardware:
# "-A" => AUTHENTICATION password and "-X" => ENCRYPTION password
net-snmp-config --create-snmpv3-user -ro -A $SNMPV3AUTHPASSWD -X $SNMPV3ENCRYPTPASSWD -a SHA -x AES $SNMPV3ROUSER
echo

systemctl enable snmpd.service
systemctl start snmpd.service

echo

echo "Validate SNMPv3 config is correct by executing an snmpget of sysLocation.0 (camera location):"
echo "---------------------------------------------------------------------------------------------"
snmpget -v3 -a SHA -x AES -A $SNMPV3AUTHPASSWD -X $SNMPV3ENCRYPTPASSWD -l authNoPriv -u pi $CAMERAIPV4 sysLocation.0
echo
echo "Expected result of the snmpget should be: * $SNMPLOCATION *"
echo




echo
echo "$(tput setaf 5)****** DROPBOX Storage Configuration:  ******$(tput sgr 0)"
echo
echo "https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md"
echo

# *Dropbox-Uploader* facilitates copying images from local USB Flash storage to cloud safeguarding evidence from theft or destruction of Pi-Cam

if [ ! -d /home/pi/Dropbox-Uploader ]; then
	cd /home/pi
	until git clone https://github.com/andreafabrizi/Dropbox-Uploader.git
	do
		echo
		echo "$(tput setaf 5)Download of Dropbox-Uploader repo failed. Retrying$(tput sgr 0)"
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
	done
fi

chown -R pi:pi /home/pi/Dropbox-Uploader


cat <<EOF> /home/pi/scripts/Dropbox-Uploader.sh
#!/bin/bash

# Script searches /media/pi for jpg and mp4 files and pipes those it finds to xargs which
# first uploads them to dropbox and then deletes them ensuring storage does not fill to 100 percent

find /media/pi -name '*.jpg' -print0 -o -name '*.mp4' -print0 | xargs -d '/' -0 -I % sh -c '/home/pi/Dropbox-Uploader/dropbox_uploader.sh upload % . && rm %'

EOF


chmod 700 /home/pi/scripts/Dropbox-Uploader.sh
chown pi:pi /home/pi/scripts/Dropbox-Uploader.sh


cat <<EOF> /etc/systemd/system/Dropbox-Uploader.service
[Unit]
Description=Upload images to cloud
#Before=

[Service]
User=pi
Group=pi
Type=simple
ExecStart=/home/pi/scripts/Dropbox-Uploader.sh

[Install]
WantedBy=multi-user.target

EOF



cat <<EOF> /etc/systemd/system/Dropbox-Uploader.timer
[Unit]
Description=Execute Dropbox-Uploader.sh script every 5 min to safeguard camera evidence

[Timer]
OnCalendar=*:0/5
Unit=Dropbox-Uploader.service

[Install]
WantedBy=timers.target

EOF


systemctl daemon-reload
systemctl enable Dropbox-Uploader.service
systemctl enable Dropbox-Uploader.timer




echo
echo "$(tput setaf 5)****** USB Flash Storage Configuration:  ******$(tput sgr 0)"
echo

echo "To stop frequent writes from trashing MicroSD card the Pi OS lives on"
echo "directories with frequent write activity will be mounted on USB storage"
echo

# Interesting thread on auto mounting choices:
# https://unix.stackexchange.com/questions/374103/systemd-automount-vs-autofs

# *usbmount* will interfere with the way we are going to mount the storage: check to see if it is present and if true get rid of it
if [[ ! $(dpkg -l | grep usbmount) = '' ]]; then
	apt-get -qqy purge usbmount > /dev/null
	status-apt-cmd
fi


# Disable automounting by default Filemanager "pcmanfm" if present: it steps on our SystemD automount which offers greater flexibility to change mount options:
if [ -f /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf ]; then
	sed -i "s/mount_removable=1/mount_removable=0/" /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf
fi



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



# SystemD mount file created below should be named same as its mountpoint as specified in "Where" directive below:
cat <<EOF> /etc/systemd/system/media-pi.mount
[Unit]
Description=Create mount for USB storage for videos and images

[Mount]
What=/dev/sda1
Where=/media/pi
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in "Where" directive below:
cat <<EOF> /etc/systemd/system/media-pi.automount
[Unit]
Description=Automount USB storage mount for videos and images

[Automount]
Where=/media/pi
DirectoryMode=0755
TimeoutIdleSec=15

[Install]
WantedBy=multi-user.target

EOF


systemctl daemon-reload
systemctl start media-pi.mount



# Exit script if NO USB storage attached:
if [[ $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' ) = '' ]]; then
	echo
	echo "ERROR: Attach an EXFAT formatted USB flash drive to be a target for video to be written"
	echo "Re-run script after minimum storage requirements met. Exiting"
	echo
	exit
else
	echo
	echo "USB STORAGE FOUND"
fi

# Exit script USB storage attached but not formatted for EXFAT filesystem:
if [[ $(lsblk -f|grep sda1|awk '{print $2}') = '' ]]; then
	echo
	echo "ERROR: USB flash drive NOT formatted for * EXFAT * filesystem"
	echo "Re-execute script after minimum storage requirements met. Exiting"
	echo
	exit
else
	echo
	echo "USB STORAGE IS EXFAT:"
	echo "Script will proceed"
	echo
fi

systemctl enable media-pi.mount


# Create a folder on the USB flash storage to write our persistent logs to.
# We do this to avoid abusing the MicroSD card housing the OS with frequent writes.
if [ ! -d /media/pi/logs ]; then
	mkdir /media/pi/logs
	chmod 751 /media/pi/logs
fi



echo
echo "$(tput setaf 5)****** Camera Software *MOTION* Configuration  ******$(tput sgr 0)"
echo
echo "Further Info: https://motion-project.github.io/motion_config.html"
echo

# Configure *BASIC* Settings (just enough to get things generally working):
sed -i "s/ipv6_enabled off/ipv6_enabled $IPV6ENABLED/" /etc/motion/motion.conf
sed -i "s/daemon off/daemon on/" /etc/motion/motion.conf
sed -i 's|logfile /var/log/motion/motion.log|logfile /media/pi/logs/motion.log|' /etc/motion/motion.conf
sed -i "s/log_level 6/log_level $LOGLEVEL/" /etc/motion/motion.conf
sed -i "s/rotate 0/rotate $ROTATE/" /etc/motion/motion.conf
sed -i "s/width 320/width $WIDTH/" /etc/motion/motion.conf
sed -i "s/height 240/height $HEIGHT/" /etc/motion/motion.conf
sed -i "s/framerate 2/framerate $FRAMERATE/" /etc/motion/motion.conf
sed -i "s/auto_brightness off/auto_brightness $AUTOBRIGHTNESS/" /etc/motion/motion.conf
sed -i "s/quality 75/quality $QUALITY/" /etc/motion/motion.conf
sed -i "s/ffmpeg_output_movies off/ffmpeg_output_movies $FFMPEGOUTPUTMOVIES/" /etc/motion/motion.conf
sed -i "s/max_movie_time 0/max_movie_time $MAXMOVIETIME/" /etc/motion/motion.conf
sed -i "s/ffmpeg_video_codec mpeg4/ffmpeg_video_codec $FFMPEGVIDEOCODEC/" /etc/motion/motion.conf
sed -i "s/; on_event_start value/on_event_start $ONEVENTSTART/" /etc/motion/motion.conf
sed -i "s/threshold 1500/threshold $THRESHOLD/" /etc/motion/motion.conf
sed -i "s/locate_motion_mode off/locate_motion_mode $LOCATEMOTIONMODE/" /etc/motion/motion.conf
sed -i "s/locate_motion_style box/locate_motion_style $LOCATEMOTIONSTYLE/" /etc/motion/motion.conf
sed -i "s/output_pictures on/output_pictures $OUTPUTPICTURES/" /etc/motion/motion.conf
sed -i "s|target_dir /var/lib/motion|target_dir $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' )|" /etc/motion/motion.conf
sed -i "s/stream_port 8081/stream_port $STREAMPORT/" /etc/motion/motion.conf
sed -i "s/stream_quality 50/stream_quality $STREAMQUALITY/" /etc/motion/motion.conf
sed -i "s/stream_motion off/stream_motion $STREAMMOTION/" /etc/motion/motion.conf
sed -i "s/stream_localhost on/stream_localhost $STREAMLOCALHOST/" /etc/motion/motion.conf
sed -i "s/stream_auth_method 0/stream_auth_method $STREAMAUTHMETHOD/" /etc/motion/motion.conf
sed -i "s/; stream_authentication username:password/stream_authentication $USER:$PASSWD/" /etc/motion/motion.conf
sed -i "s/webcontrol_localhost on/webcontrol_localhost $WEBCONTROLLOCALHOST/" /etc/motion/motion.conf
sed -i "s/webcontrol_port 8080/webcontrol_port $WEBCONTROLPORT/" /etc/motion/motion.conf
sed -i "s/; webcontrol_authentication username:password/webcontrol_authentication $USER:$PASSWD/" /etc/motion/motion.conf


echo "Configure Motion to run by daemon"
# Remark the path is different to the target of foregoing sed expressions
sed -i "s/start_motion_daemon=no/start_motion_daemon=yes/" /etc/default/motion

echo "Set motion to start on boot"
systemctl enable motion.service




echo
echo "$(tput setaf 5)****** MAIL ALERTS CONFIGURATION: Motion Detection  ******$(tput sgr 0)"
echo

# References:
# http://msmtp.sourceforge.net/doc/msmtp.html
# https://wiki.archlinux.org/index.php/Msmtp

# MSMTP does not provide a default config file so we create one below:
cat <<EOF> /etc/msmtprc
defaults
auth           on
tls            on
tls_starttls   on
logfile        /media/pi/logs/msmtp.log

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
echo "$(tput setaf 5)****** MAIL ALERTS CONFIGURATION: IP Address and Heat  ******$(tput sgr 0)"
echo

# Apple offers means to identify the IP of a device tethered to an iPhone HotSpot.
# This systemd service emails the camera IP address assigned by a HotSpot to email specified in variable "NOTIFICATIONSRECIPIENT"
# Note: This feature will only work if you have configured a working mail relay for the camera to use


cat <<EOF> /home/pi/scripts/email-camera-address.sh
#!/bin/bash

NOTIFICATIONSRECIPIENT='terrence.houlahan.devices@gmail.com'

SNMPV3AUTHPASSWD='"'$SNMPV3AUTHPASSWD'"'
SNMPV3ENCRYPTPASSWD='"'$SNMPV3ENCRYPTPASSWD'"'
SNMPV3ROUSER='"'$SNMPV3ROUSER'"'

# Do *NOT* edit the below variables: these are self-populating and resolve to the ip address of this host
CAMERAIPV4="\$(ip addr list|grep wlan0|awk '{print \$2}'|cut -d '/' -f1|cut -d ':' -f2)"
CAMERAIPV6="\$(ip -6 addr list|grep inet6|grep 'scope link'| awk '{ print \$2}'|cut -d '/' -f1)"

sleep 20
#echo "IP Address of Camera $(hostname) is: \$CAMERAIPV4 / \$CAMERAIPV6" | mutt -s "IP Address of Camera $(hostname)" \$NOTIFICATIONSRECIPIENT

echo "IP Address of Camera $(hostname) is: \$CAMERAIPV4 / \$CAMERAIPV6" | mutt -s "IP Address of Camera: \$(snmpget -v3 -a SHA -x AES -A \$SNMPV3AUTHPASSWD -X \$SNMPV3ENCRYPTPASSWD -l authNoPriv -u \$SNMPV3ROUSER \$CAMERAIPV4 sysLocation.0)" \$NOTIFICATIONSRECIPIENT

EOF


chmod 700 /home/pi/scripts/email-camera-address.sh
chown pi:pi /home/pi/scripts/email-camera-address.sh


cat <<EOF> /etc/systemd/system/email-camera-address.service
[Unit]
Description=Email IP Address of Camera on Boot
#Before=

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=/home/pi/scripts/email-camera-address.sh

[Install]
WantedBy=multi-user.target

EOF


systemctl enable email-camera-address.service



cat <<EOF> /home/pi/scripts/heat-alert.sh
#!/bin/bash

# Edit values in variables belowrather than editing the script itself to avoid introducing a fault
NOTIFICATIONSRECIPIENT='terrence.houlahan.devices@gmail.com'
HEATTHRESHOLDWARN='71'
HEATTHRESHOLDSHUTDOWN='91'

# But do *NOT* edit below variables: these are self-populating and resolve to the ip address of this host
CAMERAIPV4="\$(ip addr list|grep wlan0|awk '{print \$2}'|cut -d '/' -f1|cut -d ':' -f2)"
CAMERAIPV6="\$(ip -6 addr list|grep inet6|grep 'scope link'| awk '{ print \$2}'|cut -d '/' -f1)"


if [[ \$(/opt/vc/bin/vcgencmd measure_temp|cut -d '=' -f2|cut -d '.' -f1) -gt \$HEATTHRESHOLDWARN ]]; then
	echo -e “Temp exceeds WARN threshold: \$HEATTHRESHOLDWARN C \n Timer controlling frequency of this alert: heat-alert.timer \n \$(hostname) \n \$CAMERAIPV4 \n \$CAMERAIPV6” | mail -s "Heat Alert \$(hostname)" \$NOTIFICATIONSRECIPIENT
elif [[ \$(/opt/vc/bin/vcgencmd measure_temp|cut -d '=' -f2|cut -d '.' -f1) -gt \$HEATTHRESHOLDSHUTDOWN ]]; then
	echo -e “Temp exceeds SHUTDOWN threshold: \$HEATTHRESHOLDSHUTDOWN C \n \n Pi was shutdown due to excessive heat condition \n \$(hostname) \n \$CAMERAIPV4 \n \$CAMERAIPV6” | mail -s "Shutdown Alert \$(hostname)" \$NOTIFICATIONSRECIPIENT
	systemctl poweroff
else
	exit
fi

EOF


chmod 700 /home/pi/scripts/heat-alert.sh
chown pi:pi /home/pi/scripts/heat-alert.sh


cat <<EOF> /etc/systemd/system/heat-alert.service
[Unit]
Description=Email Heat Alerts

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=/home/pi/scripts/heat-alert.sh

[Install]
WantedBy=multi-user.target

EOF


systemctl enable heat-alert.service



cat <<EOF> /etc/systemd/system/heat-alert.timer
[Unit]
Description=Email Heat Alerts

[Timer]
OnCalendar=*:0/5
Unit=heat-alert.service

[Install]
WantedBy=timers.target

EOF



systemctl enable heat-alert.timer
systemctl list-timers --all



# Since we are doing mail thingies here we will alias roots mail to a real account:
echo "root: $NOTIFICATIONSRECIPIENT" >> /etc/aliases
newaliases



echo
echo "$(tput setaf 5)****** SET CPU AFFINITY:  ******$(tput sgr 0)"
echo


echo "The Pi 3B+ has a 4-core CPU. Motion in this install is single threaded. We will pin the process to a dedicated core."
echo "By restricting SYSTEM processes to living on CPUs 0-2 when we pin motion to core that leaves 3 uncontended for Motion to use"
echo

cp -p /etc/systemd/system.conf /etc/systemd/system.conf.ORIGINAL

sed -i "s/#CPUAffinity=1 2/CPUAffinity=0 1 2/" /etc/systemd/system.conf


echo
echo "Changes made to/etc/systemd/system.conf by script are $(tput setaf 1)RED$(tput sgr 0)"
echo "Original values are shown in $(tput setaf 2)GREEN$(tput sgr 0)"
echo
diff --color /etc/systemd/system.conf /etc/systemd/system.conf.ORIGINAL
echo



echo "Automate setting CPU Affinity for Motion on boot"
# Note use of * Wants * directive to create a dependent relationship on Motion already being started

cat <<'EOF'> /home/pi/scripts/set-cpu-affinity.sh
#!/bin/bash

# Note: the number following cp is the CPU/core number in this case three
taskset -cp 3 $(pgrep motion|cut -d ' ' -f2)

EOF


chmod 700 /home/pi/scripts/set-cpu-affinity.sh
chown pi:pi /home/pi/scripts/set-cpu-affinity.sh


cat <<EOF> /etc/systemd/system/set-cpu-affinity.service
[Unit]
Description=Set CPU Affinity for the Motion process after it starts on boot
Wants=motion.service

[Service]
User=root
Group=root
Type=oneshot
ExecStart=/home/pi/scripts/set-cpu-affinity.sh

[Install]
WantedBy=multi-user.target

EOF


systemctl enable set-cpu-affinity.service

# Change ownership of all files created by this script FROM user "root" TO user "pi":
chown -R pi:pi /home/pi



echo
echo "$(tput setaf 5)****** /etc/motd CONFIGURATION:  ******$(tput sgr 0)"
echo

echo "Configured Help Messages/Tips in /etc/motd to display on user login"
echo
echo "###############################################################################" >> /etc/motd
echo "##  $(tput setaf 4)If this script saved you lots of time doing manual config buy me a beer either in person or PayPal:$(tput sgr 0) ##" >> /etc/motd
echo "##                      $(tput setaf 4)paypal.me/TerrenceHoulahan $(tput sgr 0)                      ##" >> /etc/motd
echo "###############################################################################" >> /etc/motd
echo >> /etc/motd
echo "Video Camera Status:" >> /etc/motd
echo "$(sudo systemctl status motion)" >> /etc/motd
echo >> /etc/motd
echo "Camera Address: $CAMERAIPV4:8080" >> /etc/motd
echo >> /etc/motd
echo "Print Camera Temperature (below should be between 40-60 C):" >> /etc/motd
echo "/opt/vc/bin/vcgencmd measure_temp" >> /etc/motd
echo >> /etc/motd
echo "Local Images Written To: $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' )" >> /etc/motd
echo >> /etc/motd
echo "To stop/start/reload the Motion daemon:" >> /etc/motd
echo 'sudo systemctl [stop|start|reload] motion' >> /etc/motd
echo >> /etc/motd
echo "Video Camera Logs: /media/pi/logs/motion.log" >> /etc/motd
echo >> /etc/motd
echo "To Print Camera Details" >> /etc/motd
echo "sudo /usr/bin/v4l2-ctl -V" >> /etc/motd
echo >> /etc/motd
echo "To Check Camera Loading Below Command Should Report: supported=1 detected=1" >> /etc/motd
echo 'vcgencmd get_camera' >> /etc/motd
echo >> /etc/motd
echo >> /etc/motd
echo "To Check Camera Driver Loaded Output of Below Command Should Report Value of 1:" >> /etc/motd
echo 'lsmod |grep v4l2' >> /etc/motd
echo >> /etc/motd
echo "Further Check Camera is Correct: video0 * should be Reported When Below Command is Executed:" >> /etc/motd
echo 'ls -al /dev | grep video0' >> /etc/motd
echo >> /etc/motd
echo "To manually change *VIDEO* resolution using Video4Linux driver tailor below example to your use case:" >> /etc/motd
echo 'Step 1: sudo systemctl stop motion' >> /etc/motd
echo 'Step 2: sudo v4l2-ctl --set-fmt-video=width=1920,height=1080,pixelformat=4' >> /etc/motd
echo >> /etc/motd
echo "To obtain resolution and other data from an image file:" >> /etc/motd
echo 'exiv2 /media/pi/imageName.jpg' >> /etc/motd
echo >> /etc/motd
echo "To see metadata for an image or video:" >> /etc/motd
echo 'exiftool /media/pi/videoName.mp4' >> /etc/motd
echo >> /etc/motd
echo "Below tools installed to help troubleshoot networking issues:" >> /etc/motd
echo 'mtr tcpdump and iptraf-ng' >> /etc/motd
echo "To edit or delete these login messages:  vi /etc/motd" >> /etc/motd
echo >> /etc/motd
echo "###############################################################################" >> /etc/motd



echo "$(tput setaf 5)****** CONFIRM DROPBOX ACCESS TOKEN:  ******$(tput sgr 0)"
echo
echo "By default Dropbox API used to upload images breaks scripted automation by requiring user input on first access."
echo 'So we initiate an access then spit back the token supplied in variable DROPBOXACCESSTOKEN and finally acknowledge it is correct'
echo
cd /home/pi/Dropbox-Uploader/
su pi -c "printf '\n'|./dropbox_uploader.sh upload << 'INPUT'
$DROPBOXACCESSTOKEN
y
INPUT"


echo "Note address of your camera below to access it via web browser after reboot:"
echo "$(tput setaf 2) ** Camera Address: "$CAMERAIPV4":8080 ** $(tput sgr 0)"
echo "$(tput setaf 2) ** Camera Address: "$CAMERAIPV6":8080 ** $(tput sgr 0)"
echo
echo "If you SSH into the camera its address will also be printed in the MOTD upon login"

echo
echo
echo "$(tput setaf 1)** WARNING: REMEMBER TO CONFIGURE FIREWALL RULES TO RESTRICT ACCESS TO YOUR CAMERA HOST ** $(tput sgr 0)"
echo
read -p "Press Enter to perform an upgrade and reboot after reviewing script feedback for errors or config detail of interest"
echo

# Change ownership of all files created by this script FROM user "root" TO user "pi":
chown -R pi:pi /home/pi


echo
echo "$(tput setaf 5)****** apt-get upgrade and dist-upgrade: ******$(tput sgr 0)"
echo

echo
echo "Raspbian Version *PRE* Updates"
lsb_release -a
echo
echo "Kernel: $(uname -r)"
echo



echo "Remove any dependencies of uninstalled packages:"
apt-get -qqy autoremove > /dev/null
status-apt-cmd
echo

echo "Now execute the dist-upgrade"
apt-get -qqy dist-upgrade > /dev/null
status-apt-cmd
echo


echo
echo "Raspbian Version *POST* Updates"
lsb_release -a
echo
echo "Kernel: $(uname -r)"
echo

# How to answer "no" to an interactive TUI dialog box in a script for an unattended install:
#	https://unix.stackexchange.com/questions/106552/apt-get-install-without-debconf-prompt
# 	http://www.microhowto.info/howto/perform_an_unattended_installation_of_a_debian_package.html


# * boolean false * is piped to debconf-set-selections to pre-seed the answer to interactive prompt * Should kexec-toolshandle reboots(sysvinit only) *
if [[ $(dpkg -l | grep kexec-tools) = '' ]]; then
	echo kexec-tools kexec-tools/load_exec boolean false | debconf-set-selections
	apt-get -qq install kexec-tools > /dev/null
	status-apt-cmd
	echo
fi


echo "System will reboot in 10 seconds"
sleep 10


# Wipe F1Linux.com pi-cam-config files as clear text passwds live in here:
rm -rf /home/pi/pi-cam-config

#systemctl reboot
