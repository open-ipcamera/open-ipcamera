#!/bin/bash

# Author:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20190201
# Version 1.20

# "open-ipcamera-config.sh": Installs and configs Raspberry Pi camera application, related camera Kernel module and motion detection alerts
#   Hardware:   Raspberry Pi 2/3B+
#   OS:         Raspbian "Stretch" 9.6 (lsb_release -a)

######  License: ######
#
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


######  INSTALL INSTRUCTIONS: ######

# README.txt file distributed with this script
# VIDEO:  www.YouTube.com/user/LinuxEngineer
#         The Video contains all steps required to produce an enterprise-grade Motion Detection Camera using this script
#         And most helpfully the video begins with a section index to enable skipping directly to the section you want

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

# ** WARNING ** REPLACE MY PUBLIC KEY BELOW WITH YOUR OWN. If your camera is behind a NATed connection I cannot reach it however bad security granting PubKey access folks without need
MYPUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/4ujZFHJrXgAracA7eva06dz6XIz75tKei8UPZ0/TMCb8z01TD7OvkhPGMA1nqXv8/ST7OqG22C2Cldknx+1dw5Oz8FNekHEJVmuzVGT2HYvcmqr4QrbloaVfx2KyxdChfr9fMyE1fmxRlxh1ZDIZoD/WrdGlHZvWaMYuyCyqFnLdxEF/ZVGbh1l1iYRV9Et1FhtvIUyeRb5ObfJq09x+OlwnPdS21xJpDKezDKY1y7aQEF+D/EhGk/UzA91axpVVM9ToakupbDk+AFtmrwIO7PELxHsN1TtA91e2dKOps3SmcVDluDoUYjO33ozNGDoLj08I0FJMNOClyFxMmjUGssA4YIdiYIx3+uae3Bjnu4qpwyREPxxiWZwt20vzO6pvyxqhjcU49gmAgp1pOgBXkkkpu/CHiDFGAJW06nk1QgK9NwkNKL2Tbqy30HY4K/px1OkgaDyvXIRvz72HRR+WZIfGHMW8RLa7ceoUU4dXObqgUie0FGAU23b2m2HTjYSyj2wAAFp5ONkp9F6V2yeeW1hyRvEwQnX7ov95NzIMvtvYvn5SIX7GVIy+/8TlLpChMCgBJ4DV13SVWwa5E42HnKILoDKTZ3AG0ILMRQsJdv49b8ulwTmvtEmHZVRt7mEVF8ZpVns68IH3zYWIDJioSoKWpj7JZGNUUPo79PS+wQ== terrence@Terrence-MBP.local'

#### Dropbox-Uploader Variables:
# Dropbox used to shift video and pics to the cloud to prevent evidence being destroyed or stolen
# Please consult "README.txt" for how to obtain the value for below variable
DROPBOXACCESSTOKEN='ReplaceThisStringWithYourAccessToken'

# Set a threshold value to be notified when Pi temperature exceeds it:
HEATTHRESHOLDWARN='60'
# WARNING: Do NOT set SHUTDOWN threshold too low or test will evaluate true as soon as pi boots causing it to just keep rebooting
# NOTE: Pi3B+ can run hot: https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=138193
HEATTHRESHOLDSHUTDOWN='75'

### Variables: SNMP Monitoring
# "SNMPLOCATION" is a descriptive location of the area the camera covers
SNMPLOCATION='Back Door'

# NOTE: The email address specified in variable SNMPSYSCONTACT will be the one used for ALL System Alerts
SNMPSYSCONTACT='accountToReceiveAlerts@domain.com'

# ** IMPORTANT: PLEASE READ **:
# NOTE 1: Below two variables are encased between a double and single quote. DO NOT DELETE THEM when setting a password
# NOTE 2: Additionally neither should your complex passwords for below variables incorporate single or double quote marks.  All other special characters OK to use
SNMPV3AUTHPASSWD="'PiDemo1234'"
SNMPV3ENCRYPTPASSWD="'PiDemo1234'"

# Can just leave value as "pi" for Read-Only SNMP user
SNMPV3ROUSER='pi'

### Variables: MSMTP (to send alerts):

# NOTE: Both Self-Hosted and GMAIL SMTP Relay Accounts will be configured using below variables.
#	However only 1 of the 2 accounts needs to work for the email alerts to start flowing

# SELF-HOSTED SMTP Relay Mail Server: This is the Primary MSMTP relay account that is configured
SMTPRELAYPORT='25'
SASLUSER='yourSASLuserName'
SASLPASSWD='yourSASLpasswdGoesHere'
SMTPRELAYFQDN='mail.your-SMTP-relay-goes-here.co.uk'
SMTPRELAYFROM='yourName@domainYouWantAlertsToAppearToBeSentFrom.com'

# GMAIL SMTP Relay Server:  This is the secondary MSMTP Relay that is configured
# NOTE 1: Requires a PAID Gmail account to *RELAY* alerts. However you can *RECEIVE* alerts on a free Gmail account.
# NOTE 2: If NOT using a Gmail SMTP Relay then just leave the example values unchanged
GMAILADDRESS='yourAcctName@gmail.com'
GMAILPASSWD='YourGmailPasswdHere'


### Variables: Camera Application "Motion"
# NOTE: "motion.conf" has many more adjustable parameters than those below, which are a subset of just very useful or required ones:

IPV6ENABLED='on'
# NOTE: user for Camera application "Motion" login does not need to be a Linux system user account created with "useradd" command: can be arbitrary
USER='me'

# WARNING: Do * NOT * use the special characters ampersand * & * or forward-slash * / * in the variable * PASSWD * when creating a complex password:
# The * PASSWD * variable below is expanded inside a sed expression and these characters will be interpreted even if encased between single quotes:
# https://stackoverflow.com/questions/11307759/how-to-escape-the-ampersand-character-while-using-sed
PASSWD='ChangeMe-But-Dont-Use-Ampersands-Or-Forward-Slashes'

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


# DO NOT EDIT BELOW VARIABLES: they self-resolve host IPv4/6v addresses so they can be automatically inserted in config files to avoid manual configuration

# * CAMERAIPV4 * Prints first non-local IPv4 address. If connected both wired and wirelessly the IP of eth0 will take precedence based on implied logic cable was connected for some reason
CAMERAIPV4="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
# * CAMERAIPV6 * Looks for and prints an IPv6 Global Unicast Address if such an interface is configured
CAMERAIPV6="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"


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
echo "My script is a wrapper that stitches together the work of the below projects into a complete Motion Detection Camera Solution."
echo "Just wanted to take a moment to thank these Open Source folks who toil in anonymity that provided me with the key components for my efforts:"
echo
echo "Dropbox_Uploader Developer Andrea Fabrizi whose scripts are used by my wrapper to shift images from local USB Flash storage to Dropbox"
echo "		$(tput setaf 2) https://github.com/andreafabrizi/Dropbox-Uploader.git $(tput sgr 0)"
echo
echo "Motion Project Developers Joseph Heenan * Mr-Dave *  Tosiara.  Motion is used for motion detection image capture"
echo "		$(tput setaf 2) https://github.com/orgs/Motion-Project/people$(tput sgr 0)"
echo
echo "MSMTP Developer Martin Lambers: SMTP client used to relay alerts"
echo "		$(tput setaf 2) https://gitlab.marlam.de/marlam/msmtp$(tput sgr 0)"
echo
echo "And kudos to DROPBOX for providing their Enterprise-grade API used for shifting images from the USB storage up to the cloud.  Outstanding company."
echo
echo "$(tput setaf 6)     - Terrence Houlahan Linux Engineer ( houlahan@F1Linux.com )$(tput sgr 0)"
echo


echo
echo "$(tput setaf 5)****** LICENSE:  ******$(tput sgr 0)"
echo

echo '*open-ipcamera-config.sh* Copyright (C) 2018 2019 Terrence Houlahan'
echo
echo "This program comes with ABSOLUTELY NO WARRANTY express or implied."
echo "This is free software and you are welcome to redistribute it under certain conditions."
echo "Consult * LICENSE.txt * for terms of GPL 3 License and conditions of use."

read -p "Press ENTER to accept license and warranty terms to continue or close this bash shell to exit script"



echo
echo "$(tput setaf 5)****** DELETE LIBRE OFFICE:  ******$(tput sgr 0)"
echo
echo "Checking if Libre Office present and will remove that pig if found."
echo


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
echo "$(tput setaf 5)******  DELETE DETRITUS FROM PRIOR INSTALLS:  ******$(tput sgr 0)"
echo
echo "$(tput setaf 2)### Restore Pi to predictable known state by removing artefacts left by prior executions of this script: ###$(tput sgr 0)"
echo

# Reset the /etc/hosts file back to default state
sed -i "s/127\.0\.0\.1.*/127\.0\.1\.1      raspberrypi/" /etc/hosts
sed -i "s/::1.*/::1     raspberrypi/" /etc/hosts

# Restore default hostname:
hostnamectl set-hostname raspberrypi
systemctl restart systemd-hostnamed&
wait $!


# Reset TimesyncD Config back to the default:
if [ -f /etc/systemd/timesyncd.conf.ORIGINAL ]; then
	mv /etc/systemd/timesyncd.conf.ORIGINAL /etc/systemd/timesyncd.conf
fi


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
	rm /usr/share/snmp/snmpd.conf
	apt-get -qqy purge snmp snmpd snmp-mibs-downloader libsnmp-dev > /dev/null
fi


# Delete SSH keys and furniture if an .ssh folder exists for user pi:
if [ -d /home/pi/.ssh ]; then
	rm -r /home/pi/.ssh
fi

# Reset sshd config back to default
if [ -f /etc/ssh/sshd_config.ORIGINAL ]; then
	mv /etc/ssh/sshd_config.ORIGINAL /etc/ssh/sshd_config
fi

# Reset JournalD config back to default:
if [ -f /etc/systemd/journald.conf.ORIGINAL ]; then
	mv /etc/systemd/journald.conf.ORIGINAL /etc/systemd/journald.conf
fi

# Delete * Dropbox-Uploader *
if [ -d /home/pi/Dropbox-Uploader ]; then
	rm -rf /home/pi/Dropbox-Uploader
fi

# Delete file that loads the camera kernel module on boot:
if [ -f /etc/modules-load.d/bcm2835-v4l2.conf  ]; then
	rm /etc/modules-load.d/bcm2835-v4l2.conf
fi


### Uninstall any SystemD Services and their related files:

if [ -f /etc/systemd/system/set-cpu-affinity.service ]; then
	systemctl disable set-cpu-affinity.service
	rm /etc/systemd/system/set-cpu-affinity.service
	rm /home/pi/scripts/set-cpu-affinity.sh
fi


# Uninstall dropbox photo uploader SystemD service:
# NOTE: This is NOT part of the Dropbox-uploader script- it just uses it
if [ -f /etc/systemd/system/Dropbox-Uploader.service ]; then
	systemctl disable Dropbox-Uploader.service
	systemctl disable Dropbox-Uploader.timer
	rm /etc/systemd/system/Dropbox-Uploader.service
	rm /etc/systemd/system/Dropbox-Uploader.timer
	rm /home/pi/scripts/Dropbox-Uploader.sh
fi


if [ -f /etc/systemd/system/email-camera-address.service ]; then
	systemctl disable email-camera-address.service
	rm /etc/systemd/system/email-camera-address.service
	rm /home/pi/scripts/email-camera-address.sh
fi


if [ -f /etc/systemd/system/motion-detection-camera-address.service ]; then
	systemctl disable motion-detection-camera-address.service
	rm /etc/systemd/system/motion-detection-camera-address.service
	rm /home/pi/scripts/motion-detection-camera-address.sh
fi


if [ -f /etc/systemd/system/heat-alert.service ]; then
	systemctl stop heat-alert.timer
	systemctl disable heat-alert.timer
	systemctl stop heat-alert.service
	systemctl disable heat-alert.service
	rm /etc/systemd/system/heat-alert.service
	rm /etc/systemd/system/heat-alert.timer
	rm /home/pi/scripts/heat-alert.sh
fi


if [ -f /etc/systemd/system/boot_service_order_dependencies_graph.service ]; then
	systemctl disable boot_service_order_dependencies_graph.service
	rm /etc/systemd/system/boot_service_order_dependencies_graph.service
	rm /home/pi/scripts/boot_service_order_dependencies_graph.sh
fi


# Uninstall automount service for USB flash storage:
if [ -f /etc/systemd/system/media-automount1.automount ]; then
	systemctl stop media-automount1.automount
	systemctl disable media-automount1.automount
	rm /etc/systemd/system/media-automount1.mount
	rm /etc/systemd/system/media-automount1.automount
fi


if [ -f /etc/systemd/system/media-automount2.automount ]; then
	systemctl stop media-automount2.automount
	systemctl disable media-automount2.automount
	rm /etc/systemd/system/media-automount2.mount
	rm /etc/systemd/system/media-automount2.automount
fi

if [ -f /etc/systemd/system/media-automount3.automount ]; then
	systemctl stop media-automount3.automount
	systemctl disable media-automount3.automount
	rm /etc/systemd/system/media-automount3.mount
	rm /etc/systemd/system/media-automount3.automount
fi


if [ -f /etc/systemd/system/media-automount4.automount ]; then
	systemctl stop media-automount4.automount
	systemctl disable media-automount4.automount
	rm /etc/systemd/system/media-automount4.mount
	rm /etc/systemd/system/media-automount4.automount
fi


if [ -f /home/pi/scripts/troubleshooting-helper.sh ]; then
	rm /home/pi/scripts/troubleshooting-helper.sh
fi


systemctl daemon-reload


# Delete scripts home-rolled scripts created by here-doc from previous runs of*"open-ipcamera-config.sh* that SystemD services were calling:

if [ -d /home/pi/scripts ]; then
	rm -r /home/pi/scripts
fi

if [ -d /media/automount1/logs ]; then
	rm -r /media/automount1/logs
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



# Remove any aliases created for sending roots mail in /etc/aliases:
if [ -f /etc/aliases ]; then
	sed  -i "/root: $SNMPSYSCONTACT/d" /etc/aliases
fi


# Revert CPU Affinity back to default:
if [ -f /etc/systemd/system.conf.ORIGINAL ]; then
	mv /etc/systemd/system.conf.ORIGINAL /etc/systemd/system.conf
fi


# Truncate any messages previously appended to MOTD by this script:
truncate -s 0 /etc/motd



echo
echo "$(tput setaf 5)******  Create a Scripts Directory:  ******$(tput sgr 0)"
echo

if [ ! -d /home/pi/scripts ]; then
	mkdir /home/pi/scripts
	chown pi:pi /home/pi/scripts
	chmod 751 /home/pi/scripts
	echo "Created /home/pi/scripts Directory"
fi





echo
echo "$(tput setaf 5)****** USB Flash Storage Configuration:  ******$(tput sgr 0)"
echo

echo "To stop frequent writes from trashing MicroSD card where the Pi OS lives"
echo "directories with frequent write activity will be mounted on USB storage"
echo


# The package * usbmount * will interfere with SystemD Auto-mounts which we will use for the USB Flash Drive where video and images are written locally to.
# We check to see if it is present and if test evalutes *true* we get rid of it
if [[ ! $(dpkg -l | grep usbmount) = '' ]]; then
	apt-get -qqy purge usbmount > /dev/null
	status-apt-cmd
fi


# Disable automounting by default Filemanager * pcmanfm * if present: it steps on our SystemD automount which offers greater flexibility to change mount options:
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




echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 6)* Automount 1 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo

# Benefits of using SystemD automounts vs hard mounts:
# https://www.theregister.co.uk/2016/08/22/systemd_adds_filesystem_mount_tool/

if [ ! -d /media/automount1 ]; then
	mkdir /media/automount1
fi

chmod 775 /media/automount1
chown pi:pi /media/automount1

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount1.mount
[Unit]
Description=Create automount1 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sda1
Where=/media/automount1
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount1.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount1.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount1
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount1
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount1.automount

systemctl disable media-automount1.mount
systemctl enable media-automount1.automount

systemctl daemon-reload

systemctl start media-automount1.automount

echo
echo 'Created media-automount1.automount'
echo




echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 3)* Automount 2 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo


if [ ! -d /media/automount2 ]; then
	mkdir /media/automount2
fi

chmod 775 /media/automount2
chown pi:pi /media/automount2

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount2.mount
[Unit]
Description=Create automount2 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sdb1
Where=/media/automount2
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount2.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount2.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount2
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount2
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount2.automount

systemctl disable media-automount2.mount
systemctl enable media-automount2.automount

echo
echo 'Created media-automount2.automount'
echo




echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 1)* Automount 3 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo


if [ ! -d /media/automount3 ]; then
	mkdir /media/automount3
fi

chmod 775 /media/automount3
chown pi:pi /media/automount3

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount3.mount
[Unit]
Description=Create automount3 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sdc1
Where=/media/automount3
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount3.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount3.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount3
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount3
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount3.automount

systemctl disable media-automount3.mount
systemctl enable media-automount3.automount

echo
echo 'Created media-automount3.automount'
echo




echo
echo "$(tput setaf 5)******  Config USB Storage $(tput sgr 0)$(tput setaf 4)* Automount 4 *$(tput sgr 0)$(tput setaf 5):  ******$(tput sgr 0)"
echo


if [ ! -d /media/automount4 ]; then
	mkdir /media/automount4
fi

chmod 775 /media/automount4
chown pi:pi /media/automount4

# SystemD mount file created below should be named same as its mountpoint as specified in *Where* directive below:
cat <<EOF> /etc/systemd/system/media-automount4.mount
[Unit]
Description=Create automount4 mount for USB storage for videos and images
Requires=local-fs.target
After=local-fs.target

[Mount]
What=/dev/sdd1
Where=/media/automount4
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount4.mount


# NOTE: SystemD automount file created below should be named same as its mountpoint as specified in "Where" directive below:
cat <<EOF> /etc/systemd/system/media-automount4.automount
[Unit]
Description=Automount USB storage mount for videos and images on /media/automount4
Requires=local-fs.target
After=local-fs.target

[Automount]
Where=/media/automount4
DirectoryMode=0755
TimeoutIdleSec=300

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/media-automount4.automount

systemctl disable media-automount4.mount
systemctl enable media-automount4.automount

systemctl daemon-reload

echo
echo 'Created media-automount4.automount'
echo


# Testing revealed where automounts were started where no block device was loaded in a USB port it was broke parts of script which followed.
# So we only start automounts for additional (sda1 must load as the images and logs are stored on it) block devices if found:

if [[ $(lsblk|grep sdb1) != '' ]]; then
	systemctl start media-automount2.automount
fi


if [[ $(lsblk|grep sdc1) != '' ]]; then
	systemctl start media-automount3.automount
fi


if [[ $(lsblk|grep sdd1) != '' ]]; then
	systemctl start media-automount4.automount
fi




echo
echo "$(tput setaf 5)******  Check USB ExFAT Formatted Storage for Images Present:  ******$(tput sgr 0)"
echo

# Test a USB Flash Drive is present:
if [[ $(ls /dev|grep sda1) != '' ]]; then
	echo
	echo 'Storage Found: Testing for ExFAT Formatting next'
else
	echo 'ERROR: No USB Flash Storage Found to Write Images to.'
	echo 'Please insert an ExFAT formatted USB Flash Drive and re-execute this script'
	echo 'Script exiting.'
	exit
fi


# Test the USB Flash Drive formatted for ExFAT:
if [ $(lsblk -f|grep sda1|awk '{print $2}') = 'exfat' ]; then
	echo
	echo 'Storage is formatted for ExFAT. Script will continue'
	echo
else
	echo
	echo 'ERROR: ExFAT formatted USB flash drive REQUIRED to write video to'
	echo "Format a USB Flash Drive for ExFAT and re-excute $0. Exiting script"
	echo
	exit
fi


# Create a folder on the USB flash storage to write our persistent logs to.
# We do this to avoid abusing the MicroSD card housing the OS with frequent writes
if [ ! -d /media/automount1/logs ]; then
	mkdir /media/automount1/logs
	chmod 751 /media/automount1/logs
else
	echo 'Directory /media/automount1/logs already exists on USB Flash Storage'
fi




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

# raspian-config: How to interface from CLI:
# https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup

# Clear any boot params added during a previous build and then add each back with most current value set:
# Enable camera (No raspi-config option to script this):
sed -i '/start_x=1/d' /boot/config.txt
echo 'start_x=1' >> /boot/config.txt

sed -i '/disable_camera_led=1/d' /boot/config.txt
echo 'disable_camera_led=1' >> /boot/config.txt

echo "Determine if Pi is a Zero W or NOT to set GPU memory value appropriately:"

if [ $(cat /proc/device-tree/model | awk '{ print $3 }') != 'Zero' ]; then
	echo 'NOT PI ZERO!'
	echo 'Setting GPU Memory to 128'
	sed -i '/gpu_mem=128/d' /boot/config.txt
	echo 'gpu_mem=128' >> /boot/config.txt
else
	echo 'PI ZERO'
#	echo "Setting GPU Memory to 512"
#	sed -i '/gpu_mem=512/d' /boot/config.txt
#	echo 'gpu_mem=512' >> /boot/config.txt
fi

echo
echo 'Camera ENABLED'
echo
echo 'Camera LED light DISABLED'
echo

sed -i '/disable_splash=1/d' /boot/config.txt
echo 'disable_splash=1' >> /boot/config.txt
echo 'Boot Splash Screen DISABLED'



echo
echo "$(tput setaf 5)****** CAMERA KERNEL DRIVER: Load on Boot  ******$(tput sgr 0)"
echo


# Load Kernel module for Pi camera on boot:
cat <<EOF> /etc/modules-load.d/bcm2835-v4l2.conf
bcm2835-v4l2

EOF

echo 'File created to automatically load camera driver on boot:'
echo "/etc/modules-load.d/bcm2835-v4l2.conf"

# Rebuild Kernel modules dependencies map
depmod -a

# Load Camera Kernel Module
# Will automatically load on reboot at end of script- modprobe command disabled
#modprobe bcm2835-v4l2




echo
echo "$(tput setaf 5)****** Configure Logging:  ******$(tput sgr 0)"
echo

echo 'Default System log data is non-persistent. It exists im memory and is lost on every reboot'
echo 'Logging will be made persistent by writing it to disk in lieu of memory'

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

echo 'LOGGING NOTES:'
echo '--------------'
echo '1. Although SystemD logging has been changed to persistent by writing the logs to disk'
echo 'verbosity was also reduced to limit writes to bare minimum to avoid hammering MicroSD card.'
echo
echo '2. Application log paths have been changed to /media/automount1/logs on USB storage to limit abuse to MicroSD card.'
echo 'Was not possible to change path of /etc/systemd/journald.conf so JournalD still writes to MicroSD card'
echo
echo "3. Changes in $(tput setaf 1)RED$(tput sgr 0) can be reverted in: /etc/systemd/journald.conf"





echo
echo "$(tput setaf 5)****** Create Graph of Dependent Relationships Between Services on Boot:  ******$(tput sgr 0)"
echo


echo 'To see a graph of dependent relationships on boot to troubleshoot broken scripts or services go to:'
echo "     $(tput setaf 5)/media/automount1/logs/boot_service_order_dependencies_graph_Date.svg$(tput sgr 0)"
echo

cat <<'EOF'> /home/pi/scripts/boot_service_order_dependencies_graph.sh
#!/bin/bash


# When iteratively testing service dependency startup ordering we make changes to .service file *Unit* directives *After=* and *Wanted=* and reboot.
# We only need to retain a few copies- here 1 hours worth- of these plots for comparative purposes until we determine the correct dependent ordering:
find /media/automount1/logs/ -type f -mmin +60 -name '*.svg' -execdir rm -- '{}' \;

# Create a Plot of dependent relationships between services on boot to aid in troubleshooting broken scripts and services
systemd-analyze plot > /media/automount1/logs/boot_service_order_dependencies_graph_`date +%Y-%m-%d_%H-%M-%S`.svg

EOF


chmod 700 /home/pi/scripts/boot_service_order_dependencies_graph.sh
chown pi:pi /home/pi/scripts/boot_service_order_dependencies_graph.sh


cat <<'EOF'> /etc/systemd/system/boot_service_order_dependencies_graph.service
[Unit]
Description=Create a Plot of dependent relationships between services on boot to aid in troubleshooting broken scripts and services
After=multi-user.target

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=/home/pi/scripts/boot_service_order_dependencies_graph.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/boot_service_order_dependencies_graph.service

systemctl enable boot_service_order_dependencies_graph.service





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
echo "$(tput setaf 5)****** PACKAGE INSTALLATION:  ******$(tput sgr 0)"
echo

echo 'The following packages could be installed in a single command but are done separately both to'
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


# Ensure git is installed: required to grab repos using * git clone *
if [[ $(dpkg -l | grep git) = '' ]]; then
	until apt-get -qqy install git > /dev/null
	do
		status-apt-cmd
		echo "$(tput setaf 3)CTRL +C to exit if failing endlessly$(tput sgr 0)"
		echo
		sleep 2
	done
fi


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


# bc is a useful tool for working with calculations in scripts
if [[ $(dpkg -l | grep bc) = '' ]]; then
	apt-get -qqy install bc > /dev/null
	status-apt-cmd
fi


# *expect* is a tool for automating interactive processes in scripts by providing an answer to a question that would break unattended execution of a script
if [[ $(dpkg -l | grep expect) = '' ]]; then
	apt-get -qqy install expect > /dev/null
	status-apt-cmd
fi





echo
echo "$(tput setaf 5)****** Set Host Time: systemd-timesyncd.service Config ******$(tput sgr 0)"
echo


# USEFUL REFERENCES:
#       https://www.digitalocean.com/community/tutorials/how-to-set-up-time-synchronization-on-ubuntu-16-04
#       https://wiki.archlinux.org/index.php/systemd-timesyncd
#       https://www.freedesktop.org/software/systemd/man/timedatectl.html


echo
echo "$(tput setaf 6)Config Pi-Cam to keep accurate time when recording security events$(tput sgr 0)"
echo


# NOTE: When time servers are allocated by DHCP they can be found at below path:
#	   /run/dhcpcd/ntp.conf/wlan0.dhcp

# Set systemd-timesyncd to start on boot if it is not already:
if [[ $(systemctl list-unit-files|grep systemd-timesyncd.service|awk '{print $2}') = 'enabled' ]]; then
        timedatectl set-ntp on
        systemctl start systemd-timesyncd
fi


# Backup default timesyncd.conf config file before we start modifying it
cp -p /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.ORIGINAL

sed -i "s/#NTP=/NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org/" /etc/systemd/timesyncd.conf
sed -i "s/#FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org/FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org/" /etc/systemd/timesyncd.conf

# Below (3) directives absent from Raspbian default timesyncd.conf config file as of Raspbian v9.6 Stretch.
# Check to see if they were written previously by script and if not whack them in:
#
if [[ $(grep "RootDistanceMaxSec" /etc/systemd/timesyncd.conf) = '' ]]; then
        # *RootDistanceMaxSec*: 5 seconds is default value
        echo "RootDistanceMaxSec=5" >> /etc/systemd/timesyncd.conf
fi

if [[ $(grep "PollIntervalMinSec" /etc/systemd/timesyncd.conf) = '' ]]; then
        # *PollIntervalMinSec*: 32 seconds is default value NOTE: Cannot be less than 16 seconds
        echo "PollIntervalMinSec=32" >> /etc/systemd/timesyncd.conf
fi

if [[ $(grep "PollIntervalMaxSec" /etc/systemd/timesyncd.conf) = '' ]]; then
        # *PollIntervalMaxSec*: 2048 seconds is default value NOTE: Cannot be less than value set for *PollIntervalMinSec*
        echo "PollIntervalMaxSec=2048" >> /etc/systemd/timesyncd.conf
fi


# Re-read config with our changes:
systemctl daemon-reload
echo 'Output of *timedatectl status* Follows:'
echo
timedatectl status
echo



echo
echo "$(tput setaf 5)****** USER CONFIGURATION: ******$(tput sgr 0)"
echo

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

cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.ORIGINAL

# Modify default SSH access behaviour by tweaking below directives in /etc/ssh/sshd_config
sed -i "s|#ListenAddress 0.0.0.0|ListenAddress 0.0.0.0|" /etc/ssh/sshd_config
sed -i "s|#ListenAddress ::|ListenAddress ::|" /etc/ssh/sshd_config
sed -i "s|#SyslogFacility AUTH|SyslogFacility AUTH|" /etc/ssh/sshd_config

# LogLevel Values: QUIET \ FATAL \ ERROR \ INFO (default) \ VERBOSE \ DEBUG \ DEBUG1 \ DEBUG2 \ DEBUG3. DEBUG and DEBUG1 equivalent. Using a DEBUG level violates users privacy
sed -i "s|#LogLevel INFO|LogLevel VERBOSE|" /etc/ssh/sshd_config

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
# Disable autologin now that Public Key Access enabled:
sed -i "s/autologin-user=pi/#autologin-user=pi/" /etc/lightdm/lightdm.conf
systemctl disable autologin@.service
echo
echo "Disabled autologin"
echo

echo "Change default editor from crap * nano * to a universal Unix standard * vi *"
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

# Below sed expression stops vi from going to * visual * mode when one tries to copy text
sed -i 's|^"set mouse=a.*|set mouse-=a|' /home/pi/.vimrc
sed -i 's|^"set mouse=a.*|set mouse-=a|' /etc/vim/vimrc

chown pi:pi /home/pi/.vimrc
chmod 600 /home/pi/.vimrc

echo "Created /home/pi/.vimrc"

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



echo
echo "$(tput setaf 5)****** SNMP Configuration:  ******$(tput sgr 0)"
echo


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

echo 'Validate SNMPv3 config is correct by executing an snmpget of sysLocation.0 (camera location):'
echo '---------------------------------------------------------------------------------------------'
snmpget -v3 -a SHA -x AES -A $SNMPV3AUTHPASSWD -X $SNMPV3ENCRYPTPASSWD -l authNoPriv -u $(tail -1 /usr/share/snmp/snmpd.conf|cut -d ' ' -f 2) $CAMERAIPV4 sysLocation.0
echo
echo "Expected result of the snmpget should be: * $SNMPLOCATION *"
echo




echo
echo "$(tput setaf 5)****** DROPBOX Storage Configuration:  ******$(tput sgr 0)"
echo
echo 'https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md'
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

# Script searches /media/automount1 for jpg and mp4 files and pipes those it finds to xargs which
# first uploads them to dropbox and then deletes them ensuring storage does not fill to 100 percent

find /media/automount1 -name '*.jpg' -print0 -o -name '*.mp4' -print0 | xargs -d '/' -0 -I % sh -c '/home/pi/Dropbox-Uploader/dropbox_uploader.sh upload % . && rm %'

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


chmod 644 /etc/systemd/system/Dropbox-Uploader.service


cat <<EOF> /etc/systemd/system/Dropbox-Uploader.timer
[Unit]
Description=Execute Dropbox-Uploader.sh script every 5 min to safeguard camera evidence

[Timer]
OnCalendar=*:0/5
Unit=Dropbox-Uploader.service

[Install]
WantedBy=timers.target

EOF


chmod 644 /etc/systemd/system/Dropbox-Uploader.timer


systemctl daemon-reload
systemctl enable Dropbox-Uploader.service
systemctl enable Dropbox-Uploader.timer



echo
echo "$(tput setaf 5)****** Camera Software *MOTION* Configuration  ******$(tput sgr 0)"
echo
echo 'Further Info: https://motion-project.github.io/motion_config.html'
echo

# Configure *BASIC* Settings (just enough to get things generally working):

# *on_event_start:* First sed expression configures the Motion Detection Alerts to include the IP address in the subject of the email
# The second (commented) sed expression configures the Motion Detection Alerts to send the HOSTNAME in the Subject line of the email.
sed -i "s/; on_event_start value/on_event_start echo \"Subject: Motion Detected $CAMERAIPV4\" | msmtp \"$SNMPSYSCONTACT\"/" /etc/motion/motion.conf | grep on_event_start
#sed -i "s/; on_event_start value/on_event_start echo \"Subject: Motion Detected $(hostname)\" | msmtp \"$SNMPSYSCONTACT\"/" /etc/motion/motion.conf | grep on_event_start

# Below 2 sed expressions inject the auth credentials for camera by expanding variables so they have a special construction to stop special characters in complex passwords being interpreted
sed -i 's/; stream_authentication username:password/stream_authentication '"$USER:$PASSWD"'/' /etc/motion/motion.conf
sed -i 's/; webcontrol_authentication username:password/webcontrol_authentication '"$USER:$PASSWD"'/' /etc/motion/motion.conf

sed -i "s/ipv6_enabled off/ipv6_enabled $IPV6ENABLED/" /etc/motion/motion.conf
sed -i "s/daemon off/daemon on/" /etc/motion/motion.conf
sed -i 's|logfile /var/log/motion/motion.log|logfile /media/automount1/logs/motion.log|' /etc/motion/motion.conf
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
sed -i "s/webcontrol_localhost on/webcontrol_localhost $WEBCONTROLLOCALHOST/" /etc/motion/motion.conf
sed -i "s/webcontrol_port 8080/webcontrol_port $WEBCONTROLPORT/" /etc/motion/motion.conf



echo 'Configure Motion to run by daemon'
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
logfile        /media/automount1/logs/msmtp.log

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
echo 'If you do *NOT* receive alerts from a self-hosted SMTP mail relay check the * tls_fingerprint * directive for a fingerprint in /etc/msmtprc'
echo




echo
echo "$(tput setaf 5)****** MAIL ALERTS CONFIGURATION: IP Address and Heat  ******$(tput sgr 0)"
echo

# Apple offers no means to identify the IP of a device tethered to an iPhone HotSpot.
# This systemd service emails camera IP address assigned by a HotSpot to email specified in variable *SNMPSYSCONTACT*
# If you want to change the email address this notification (or any other system alert) is sent to edit *sysContact* in /etc/snmp/snmpd.conf directly.
# Note: email alerts will only work if a valid mail relay with correct credentials has been specified.


cat <<'EOF'> /home/pi/scripts/email-camera-address.sh
#!/bin/bash

# Redirect output of * set -x * to a log to capture any potential errors as script executed as a SystemD Service
# varFD is an arbitrary variable name and used here to assign the next unused File Descriptor to redirect output to the log
exec {varFD}>/media/automount1/logs/script-email-camera-address.log
BASH_XTRACEFD=$varFD

set -x

# A * sleep * has been inserted before variable declaration section to allow * CAMERAIPV4= * and * CAMERAIPV6= * to populate correctly AFTER networking has settled
# The SystemD Service target * Requires=network-online.target * this script has a dependency on is met before the network has fully risen up.  Known bug:
# https://github.com/coreos/bugs/issues/1966
# https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/
sleep 10


SCRIPTLOCATION="$(readlink -f $0)"

#CAMERALOCATION: sed expression matches * sysLocation * all spaces after it and only prints everything AFTER the match: the human readable location
CAMERALOCATION="$(sudo sed -n 's/sysLocation.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit alert recipient in below variable. To change alert address edit value of * sysContact * directly in /etc/snmp/snmpd.conf
SYSCONTACT="$(sudo sed -n 's/sysContact.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit below variables: they are self-populating and resolve to the ip address of this host
CAMERAIPV4="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
CAMERAIPV6="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"



echo -e "Subject: IP of Camera: $( echo $CAMERAIPV4 )\r\n\r\nIP Address of $CAMERALOCATION Camera $(hostname) is: $CAMERAIPV4 / $CAMERAIPV6 '\n' Script sending this email: $SCRIPTLOCATION" |msmtp $SYSCONTACT

# Below comand has the --debug switch: uncomment if you want to tweak the command and get granular visibility
#echo -e "Subject: IP of Camera: $( echo $CAMERAIPV4 )\r\n\r\nIP Address of $CAMERALOCATION Camera $(hostname) is: $CAMERAIPV4 / $CAMERAIPV6 '\n' Script sending this email: $SCRIPTLOCATION" |msmtp --debug $SYSCONTACT

EOF


chmod 700 /home/pi/scripts/email-camera-address.sh
chown pi:pi /home/pi/scripts/email-camera-address.sh


cat <<'EOF'> /etc/systemd/system/email-camera-address.service
[Unit]
Description=Email IP Address of Camera on Boot
Requires=network-online.target
After=motion.service

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=/home/pi/scripts/email-camera-address.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/email-camera-address.service

systemctl enable email-camera-address.service




cat <<'EOF'> /home/pi/scripts/motion-detection-camera-address.sh
#!/bin/bash

# Redirect output of * set -x * to a log to capture any potential errors as script executed as a SystemD Service
# varFD is an arbitrary variable name and used here to assign the next unused File Descriptor to redirect output to the log
exec {varFD}>/media/automount1/logs/script-motion-detection-camera-address.log
BASH_XTRACEFD=$varFD

set -x

# A * sleep * has been inserted before variable declaration section to allow * CAMERAIPV4= * and * CAMERAIPV6= * to populate correctly AFTER networking has settled
# The SystemD Service target * Requires=network-online.target * this script has a dependency on is met before the network has fully risen up.  Known bug:
# https://github.com/coreos/bugs/issues/1966
# https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/
sleep 10


SCRIPTLOCATION="$(readlink -f $0)"

#CAMERALOCATION: sed expression matches * sysLocation * all spaces after it and only prints everything AFTER the match: the human readable location
CAMERALOCATION="$(sudo sed -n 's/sysLocation.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit alert recipient in below variable. To change alert address edit value of * sysContact * directly in /etc/snmp/snmpd.conf
SYSCONTACT="$(sudo sed -n 's/sysContact.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit below variables: they are self-populating and resolve to the ip address of this host
CAMERAIPV4="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
CAMERAIPV6="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

if [ ! -f /etc/motion/motion.conf.ORIGINAL ]; then
        cp -p /etc/motion/motion.conf /etc/motion/motion.conf.ORIGINAL
fi


if [[ $( grep "on_event_start" /etc/motion/motion.conf ) != '' ]]; then

sed -i "/on_event_start/d" /etc/motion/motion.conf

fi


echo 'on_event_start echo '"\"Subject: Motion Detected $CAMERAIPV4\""' | msmtp '"\"$SYSCONTACT\""'' >> /etc/motion/motion.conf

systemctl restart motion

EOF



chmod 700 /home/pi/scripts/motion-detection-camera-address.sh
chown pi:pi /home/pi/scripts/motion-detection-camera-address.sh



cat <<'EOF'> /etc/systemd/system/motion-detection-camera-address.service
[Unit]
Description=Update IP of Camera in motion.conf for notify email generated on motion detection events ensuring if DHCP IP changes it is automatically updated every boot
Requires=network-online.target
After=motion.service

[Service]
User=root
Group=root
Type=oneshot
ExecStart=/home/pi/scripts/motion-detection-camera-address.sh

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/motion-detection-camera-address.service

systemctl enable motion-detection-camera-address.service




cat <<'EOF'> /home/pi/scripts/heat-alert.sh
#!/bin/bash


# Redirect output of * set -x * to a log to capture any errors as script executed as a SystemD Service
# varFD is an arbitrary variable name and used here to assign the next unused File Descriptor to redirect output to the log
exec {varFD}>/media/automount1/logs/script-heat-alert.log
BASH_XTRACEFD=$varFD

set -x

# A * sleep * has been inserted before variable declaration section to allow * CAMERAIPV4= * and * CAMERAIPV6= * to populate correctly AFTER networking has settled
# The SystemD Service target * Requires=network-online.target * this script has a dependency on is met before the network has fully risen up.  Known bug:
# https://github.com/coreos/bugs/issues/1966
# https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/
sleep 10


# Edit values in variables below rather than editing script itself to avoid introducing a fault
# NOTE1: Do NOT restart service after changing a threshhold value- script is fired-off anew every 5 minutes by the SystemD timer * heat-alert.timer *.
# NOTE2: Temperature units are in CELCIUS
# NOTE3: Baseline temperature of a cold Pi at boot is about 35C
HEATTHRESHOLDWARN='60'
HEATTHRESHOLDSHUTDOWN='75'


SCRIPTLOCATION="$(readlink -f $0)"

#CAMERALOCATION: Do *NOT edit this variable directly: edit value of * sysLocation * in /etc/snmp/snmpd.conf which this variable pulls the value from
# sed expression matches * sysLocation * all spaces after it and only prints everything AFTER the match: the human readable location
CAMERALOCATION="$(sudo sed -n 's/sysLocation.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit alert recipient in below variable. To change alert address edit value of * sysContact * directly in /etc/snmp/snmpd.conf
SYSCONTACT="$(sudo sed -n 's/sysContact.[[:space:]]*//p' /etc/snmp/snmpd.conf)"

# Do *NOT* edit below variables: these are self-populating and resolve to the ip address of this host
CAMERAIPV4="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
CAMERAIPV6="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"


# NOTE: A delay (* sleep 20 *) is inserted before shutdown where HEATTHRESHOLDSHUTDOWN tests TRUE to a) allow time to send the notification and
# b) to give you time to edit "/home/pi/scripts/heat-alert.sh" to increase value if set too low causing Pi to just reboot in a loop

if [[ $(/opt/vc/bin/vcgencmd measure_temp|cut -d '=' -f2|cut -d '.' -f1) -gt $HEATTHRESHOLDWARN ]]; then
	echo -e “Temp exceeds WARN threshold: $HEATTHRESHOLDWARN C. '\n' To adjust WARN alert Threshold edit: $SCRIPTLOCATION '\n' Sender of Alert: $(hostname) / $CAMERAIPV4 / $CAMERAIPV6 '\n' Alert Sent: $(date)” | mutt -s "Heat Alert Camera $(echo $CAMERAIPV4)" $SYSCONTACT
elif [[ $(/opt/vc/bin/vcgencmd measure_temp|cut -d '=' -f2|cut -d '.' -f1) -gt $HEATTHRESHOLDSHUTDOWN ]]; then
	echo -e “Pi shutdown due to Heat Threshold: $HEATTHRESHOLDSHUTDOWN C being reached '\n' To adjust shutdown Heat Threshold edit: $SCRIPTLOCATION '\n' Sender of Alert: $(hostname) $CAMERAIPV4 / $CAMERAIPV6 '\n' Alert Sent: $(date)” | mutt -s "Shutdown Alert Camera $(echo $CAMERAIPV4)" $SYSCONTACT
	sleep 20
	systemctl poweroff
else
	exit
fi

EOF


chmod 700 /home/pi/scripts/heat-alert.sh
chown pi:pi /home/pi/scripts/heat-alert.sh


cat <<'EOF'> /etc/systemd/system/heat-alert.service
[Unit]
Description=Email Heat Alerts
Requires=network-online.target
After=motion.service

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=/home/pi/scripts/heat-alert.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/heat-alert.service

systemctl enable heat-alert.service



cat <<'EOF'> /etc/systemd/system/heat-alert.timer
[Unit]
Description=Email Heat Alerts

[Timer]
OnCalendar=*:0/5
Unit=heat-alert.service

[Install]
WantedBy=timers.target

EOF


chmod 644 /etc/systemd/system/heat-alert.timer

systemctl enable heat-alert.timer
systemctl list-timers --all





echo
echo "$(tput setaf 5)****** TROUBLESHOOTING SCRIPT:  ******$(tput sgr 0)"
echo


cat <<'EOF'> /home/pi/scripts/troubleshooting-helper.sh
#!/bin/bash
echo
echo 'To help you quickly drill-down potential causes of a fault I wrote this script which provides a structured troubleshooting approach.'
echo 'Please note these tests/tools are not exhaustive but merely a starting point to provide some baseline info to analyze.'
echo


echo '########  COMMON DEVELOPMENT ERRORS:  ########'

echo
echo 'If you broke the build hacking my script tweaking it a few tips to help you unbreak it:'
echo
echo 'As a *GENERAL* rule begin hunting for dev errors at the point just above where the script went haywire.'
echo
echo 'A few useful git commands to investigate development changes which caused a break:'
echo
echo 'Show current UNCOMMITTED changes against last COMMITTED change to a named file:'
echo '     git diff open-ipcamera-config.sh'
echo
echo 'Show last 2 logged COMMITTED changes:'
echo '     git log -p -2'
echo
echo 'Some Common Dev Errors to Look For:'
echo '     - Ommitted closing single or double quotes encasing expressions'
echo '     - Ommitted *EOF* ending a Here-Doc or a closing *fi* on an *if* conditional expression'
echo '     - Variables not prefaced with dollar signs or being encased in single quotes which stop their expansion'
echo
echo


echo '########  CHANGE ANALYSIS:  ########'
echo
echo 'If a system previously running correctly is now in error- barring bugs or resourcing issues- likely had help getting broken'
echo 'Too frequently the cause of a fault is poorly planned/tested changes.'
echo
echo 'Check /var/log/apt/history.log for system upgrades from package/library upgrade activity:'

sudo tail -5 /var/log/apt/history.log|grep -i "Commandline"|cut -d ':' -f2

echo
echo
echo 'Any recent transformative and/or non-persistent commands found in the last 15 entries in * pi * and/or * root * bash histories?'
echo
echo '* pi * user last 15 commands issued:'

tail -15 /home/pi/.bash_history

echo
echo '* root * user last 15 commands issued:'

if [ -f /root/.bash_history ]; then
	sudo tail -15 /root/.bash_history
fi

echo
echo 'Review last logins to see who has recently worked on host:'
echo 'NOTE: Command * last * used in lieu of * lastlog * as it shows multiple logins by a single user'

last

echo
echo


echo '########  CHANGE ANALYSIS: Non-Persistent Changes  ########'

echo
echo 'Changes made to running processes in memory from the CLI and *NOT* via a configuration file read by an application on execution will be lost when host rebooted.'
echo 'Check * uptime * and see if the fault can be correlated to a reboot:'
echo

uptime

echo
echo 'Also check to see if the affected application was restarted:'
echo '     sudo systemctl applicationName.service'
echo
echo


echo '########  CHANGE ANALYSIS: Fault Occurs at Predictable Times or Intervals:  ########'
echo
echo
echo 'If fault occur at predictable times check jobs executing from SystemD Timers'
echo 'and any scripts they call:'
echo

systemctl list-timers --all

echo
echo


echo '########  HARDWARE ANALYSIS:  ########'
echo
echo 'Camera Temperature: compare temp below with 63-65C which (in my experience) is normal operating temperature (boot is 38C):'

sudo /opt/vc/bin/vcgencmd measure_temp

echo
echo
echo 'Does the OS know about the camera: Output below should report * supported=1 detected=1 *'

sudo /opt/vc/bin/vcgencmd get_camera

echo
echo
echo 'Does * lsmod * Report a value of * 1 * for * v4l2 * Camera Kernel Module:'

sudo lsmod |grep v4l2

echo
echo
echo 'Check device* * video0 * in reported below:'

sudo ls -al /dev | grep video0

echo
echo
echo 'Camera Details per * v4l2-ctl *:'

sudo /usr/bin/v4l2-ctl -V

echo
echo



echo '########  STORAGE ANALYSIS:  ########'
echo
echo 'Is system at 100 pct disk use:'
echo

df -h

echo
echo
echo 'Is USB flash storage mounting: Mount * /media/automount1 * should be reported below:'
echo

sudo cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }'

echo
echo
echo 'Review Storage Devices as a tree with * lsblk * to see what is- or is NOT- mounting:'
echo

lsblk -o model,name,fstype,size,label,mountpoint

echo
echo 'Review feedback from /var/log/daemon.log to see if any automounting errors'
echo
echo 'tail -fn 100 /var/log/daemon.log'
echo
echo


echo '########  PROCESS ANALYSIS:  ########'
echo
echo 'Check no processes hung at 100 percent:'
echo

ps --sort=-pcpu | head -n 5

echo
echo
echo 'Check key processes are up and running without error:'
echo

sudo systemctl status motion



echo '########  LOG ANALYSIS:  ########'
echo
echo 'Filter logs by priority (-p) to show ALL errors:'
echo

journalctl -p err

echo
echo 'Check application-specific logs for anything interesting:'
echo 'Motion Log:'

journalctl -u motion.service

echo

echo
echo 'Review last 10 messages sent in mail log:'
echo 'Note: All mail alerts sent are logged in the * msmtp.log *'

tail -10 /media/automount1/logs/msmtp.log

echo
echo


echo '########  NETWORKING ANALYSIS:  ########'
echo
echo 'Does host have a routable address? Check DHCP if not'
echo
echo 'IPv4 RFC 1918 Host Address:'

echo "$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"

echo
echo 'IPv6 Global Unicast Host Address:'

echo "$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

echo

echo
echo 'PORT SCANNING: WARNING'
echo

echo 'Port Scanning is testing the accessibility of a port on a * REMOTE * network.'
echo 'No need to port scan a connection between hosts inside your own firewall.'
echo
echo 'Legalities of Port Scanning: Scanning a single port to troubleshoot a connectivity issue'
echo 'will not be seen as *network abuse* by rational people. HOWEVER: Organizations can have'
echo 'automated detection processes in place to police their Acceptable Network Use policies'
echo 'which prohibit port scanning. If running a port scan from your employers network seek'
echo 'the Network Admins permission first.  Although not expressly codified as a crime in most'
echo 'jurisdictions you could still fall afoul of a employers or ISPs Acceptable Network Use policies.'
echo

echo 'With that gentle warning about Port Scanning out of the way a few commands are offered to assist'
echo 'you test the remote end of the connection for of a * SINGLE * port.'
echo
echo 'Interpreting Portscan Results:'
echo
echo '*OPEN* = CORRECT Connectivity'
echo '*FILTERED* = BROKEN Connectivity'


echo
echo 'Check if UDP/123 is open to allow Pi to update its time:'
echo 'Replace *some.ntp.server.com* with a valid ntp server address in following command and then execute it:'
echo "     nmap -sU -p 123 some.ntp.server.com|awk 'FNR==8'|awk '{print $2}'|cut -d '|' -f1"
echo

echo
echo 'Check if TCP/25 is open to allow Pi to relay mail alerts:'
echo 'Replace *some.mail.server.com* with a valid ntp server address in following command and then execute it:'
echo "     nmap -sT -p 25 some.mail.server.com|awk 'FNR==8'|awk '{print $2}'|cut -d '|' -f1"
echo
echo

echo
echo 'Check DNS by pinging Google by DNS name:'
echo

ping -c2 www.google.com

echo
echo
echo 'Ping Google by IP address:'
echo

ping -c2 8.8.8.8

echo
echo 'If pinging by *DNS Name* fails but succeeds by IP then DNS is broken or UDP/53 is blocked'
echo 'If pinging by *IP* fails check your Internet connection and/or firewall'
echo
echo
echo 'Does your gateway look sensible in below routing table:?'

route -n

echo
echo
echo 'Other tools to troubleshoot network issues that I installed during open-ipcamera-config.sh execution:'
echo
echo 'mtr tcpdump and iptraf-ng'
echo
echo


echo 'Although better to understand HOW something broke remember you have the option of just rebuilding the Pi-Cam by'
echo 're-excuting the * open-ipcamera-config.sh * script.  If this resolves the error then fault was configuration-related.'
echo
echo 'If re-executing script does *NOT* resolve error and all values supplied in * variables * section correct then'
echo 'refocus your investigations on things * IN FRONT OF * the Pi-Cam itself such as networking and firewalls.'
echo
echo
echo 'As a last resort if unable to successfully identify source of a fault there is always the Pi forums:'

echo '               https://raspberrypi.stackexchange.com/               '
echo '               https://www.raspberrypi.org/forums/               '

echo 'However you will never up your Linux game asking others to solve your problems. You have to earn your bones.'
echo
echo '     -Terrence Houlahan Linux & Network Engineer F1Linux.com'

EOF

chmod 700 /home/pi/scripts/troubleshooting-helper.sh
chown pi:pi /home/pi/scripts/troubleshooting-helper.sh


echo '/home/pi/scripts/troubleshooting-helper.sh'
echo
echo


echo
echo "$(tput setaf 5)****** SET CPU AFFINITY:  ******$(tput sgr 0)"
echo


echo 'The Pi 3B+ has a 4-core CPU. Motion in this install is single threaded. We will pin the process to a dedicated core.'
echo 'By restricting SYSTEM processes to living on CPUs 0-2 when we pin motion to core that leaves 3 uncontended for Motion to use'
echo

cp -p /etc/systemd/system.conf /etc/systemd/system.conf.ORIGINAL

sed -i "s/#CPUAffinity=1 2/CPUAffinity=0 1 2/" /etc/systemd/system.conf


echo
echo "Changes made to/etc/systemd/system.conf by script are $(tput setaf 1)RED$(tput sgr 0)"
echo "Original values are shown in $(tput setaf 2)GREEN$(tput sgr 0)"
echo
diff --color /etc/systemd/system.conf /etc/systemd/system.conf.ORIGINAL
echo



echo 'Automate setting CPU Affinity for Motion on boot'

cat <<'EOF'> /home/pi/scripts/set-cpu-affinity.sh
#!/bin/bash

# Note: the number following cp is the CPU/core number in this case 3
taskset -cp 3 $(pgrep motion|cut -d ' ' -f2)

EOF


chmod 700 /home/pi/scripts/set-cpu-affinity.sh
chown pi:pi /home/pi/scripts/set-cpu-affinity.sh

# Note use of * Wants * directive to create a dependent relationship on Motion already being started
cat <<EOF> /etc/systemd/system/set-cpu-affinity.service
[Unit]
Description=Set CPU Affinity for the Motion process after it starts on boot
Wants=motion.service
After=motion.service

[Service]
User=root
Group=root
Type=oneshot
ExecStart=/home/pi/scripts/set-cpu-affinity.sh

[Install]
WantedBy=multi-user.target

EOF

chmod 644 /etc/systemd/system/set-cpu-affinity.service

systemctl enable set-cpu-affinity.service

chown -R pi:pi /home/pi



echo
echo "$(tput setaf 5)****** /etc/motd CONFIGURATION:  ******$(tput sgr 0)"
echo

echo 'Configured Help Messages/Tips in /etc/motd to display on user login'
echo >> /etc/motd
echo >> /etc/motd
echo '###############################################################################################################' >> /etc/motd
echo "##  $(tput setaf 4)If I saved you lots of time manually configuring buy me a beer either in person or PayPal:$(tput sgr 0) ##" >> /etc/motd
echo "##                          $(tput setaf 4)paypal.me/TerrenceHoulahan $(tput sgr 0)                          ##" >> /etc/motd
echo '###############################################################################################################' >> /etc/motd
echo >> /etc/motd
echo >> /etc/motd
echo 'Troubleshooting: Execute below script to gather data to investigate the fault:' >> /etc/motd
echo 'cd /home/pi/scripts' >> /etc/motd
echo './troubleshooting-helper.sh' >> /etc/motd
echo >> /etc/motd
echo 'Camera Feed Access: Append :8080 to IP of this host in a web browser to view camera stream' >> /etc/motd
echo >> /etc/motd
echo 'stop/start/reload Motion daemon:' >> /etc/motd
echo 'sudo systemctl [stop|start|reload] motion' >> /etc/motd
echo >> /etc/motd
echo 'Manually change *VIDEO* resolution using Video4Linux driver: tailor below example to your own use-case:' >> /etc/motd
echo 'Step 1: sudo systemctl stop motion' >> /etc/motd
echo 'Step 2: sudo v4l2-ctl --set-fmt-video=width=1920,height=1080,pixelformat=4' >> /etc/motd
echo >> /etc/motd
echo 'Obtain resolution and other data from an image file:' >> /etc/motd
echo 'exiv2 /media/pi/imageName.jpg' >> /etc/motd
echo >> /etc/motd
echo 'To see metadata for an image or video:' >> /etc/motd
echo 'exiftool /media/pi/videoName.mp4' >> /etc/motd
echo >> /etc/motd
echo >> /etc/motd
echo 'To edit or delete these login messages:  vi /etc/motd' >> /etc/motd
echo >> /etc/motd
echo '###############################################################################' >> /etc/motd
echo >> /etc/motd
echo >> /etc/motd

echo
echo
echo "$(tput setaf 5)****** CONFIRM DROPBOX ACCESS TOKEN:  ******$(tput sgr 0)"
echo
echo 'By default Dropbox API used to upload images breaks scripted automation by requiring user input on first access.'
echo 'So we initiate an access then spit back the token supplied in variable DROPBOXACCESSTOKEN and finally acknowledge it is correct'
echo

touch /home/pi/test_`date +%Y-%m-%d_%H-%M-%S`.txt

cd /home/pi/Dropbox-Uploader/
su pi -c "printf '\n'|./dropbox_uploader.sh upload /home/pi/test*.txt / << 'INPUT'
$DROPBOXACCESSTOKEN
y
INPUT"
rm /home/pi/test*.txt




echo
echo
echo "$(tput setaf 1)** WARNING: REMEMBER TO CONFIGURE FIREWALL RULES TO RESTRICT ACCESS TO YOUR CAMERA HOST ** $(tput sgr 0)"
echo
read -p 'Press Enter to perform an upgrade and reboot after reviewing script feedback for errors or config detail of interest'
echo

# Change ownership of all files created by this script FROM user "root" TO user "pi":
chown -R pi:pi /home/pi


echo
echo "$(tput setaf 5)****** apt-get upgrade and dist-upgrade: ******$(tput sgr 0)"
echo

echo
echo 'Raspbian Version *PRE* Updates'
lsb_release -a
echo
echo "Kernel: $(uname -r)"
echo



echo 'Remove any dependencies of uninstalled packages:'
apt-get -qqy autoremove > /dev/null
status-apt-cmd
echo

echo 'Now execute the dist-upgrade'
apt-get -qqy dist-upgrade > /dev/null
status-apt-cmd
echo


echo
echo 'Raspbian Version *POST* Updates'
lsb_release -a
echo
echo "Kernel: $(uname -r)"
echo



# Ensure autologin remains disabled after an upgrade:
sed -i "s/autologin-user=pi/#autologin-user=pi/" /etc/lightdm/lightdm.conf
systemctl disable autologin@.service
echo



# How to answer "no" to an interactive TUI dialog box in a script for an unattended install:
#	https://unix.stackexchange.com/questions/106552/apt-get-install-without-debconf-prompt
# 	http://www.microhowto.info/howto/perform_an_unattended_installation_of_a_debian_package.html


# * boolean false * is piped to debconf-set-selections to pre-seed the answer to interactive install question *Should kexec-tools handle reboots(sysvinit only)?*
if [[ $(dpkg -l | grep kexec-tools) = '' ]]; then
	echo kexec-tools kexec-tools/load_exec boolean false | debconf-set-selections
	apt-get -qq install kexec-tools > /dev/null
	status-apt-cmd
	echo
fi



echo 'Note address of your camera below to access it via web browser after reboot:'
echo "$(tput setaf 2) ** Camera IPv4 Address: "$CAMERAIPV4":8080 ** $(tput sgr 0)"

if [[ $CAMERAIPV6 != '' ]]; then
	echo "$(tput setaf 2) ** Camera IPv6 Address: "$CAMERAIPV6":8080 ** $(tput sgr 0)"
fi


# Wipe F1Linux.com open-ipcamera-config.sh files as clear text passwds live in that file:
rm -rf /home/pi/pi-cam-config

echo 'Deleted the pi-cam-config repo directory which has clear-text passwords in it.'


echo 'System will reboot in 10 seconds'
sleep 10


systemctl reboot


# "open-ipcamera-config.sh" is Copyright (C) 2018 2019 Terrence Houlahan
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
