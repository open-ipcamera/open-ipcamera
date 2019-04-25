#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.85.00

######  LICENSE: ######
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

# WARNING:  Before executing this script please Edit:
#	  variables.sh
#	  variables-secure.sh
#  with your unique data info before executing this script

# README.md file distributed with this script contains full installation instructions for open-ipcamera

######  DEVELOPER BEER-FUND: ######

# Developing Open Source projects is thirsty work.  If you found this project useful and want to buy me a beer:
#   paypal.me/TerrenceHoulahan

#########################################


# Check that this script is being executed using sudo: if not then warn and exit
if [ "$(whoami)" != "root" ]; then
        echo "This script has insufficient perms to continue:"
        echo "Please re-execute it with sudo"
        exit 1
fi



echo
echo "$(tput setaf 5)******  GPL3 LICENSE:  ******$(tput sgr 0)"
echo

echo 'All scripts/files in the open-ipcamera repository are Copyright (C) 2018 2019 Terrence Houlahan'
echo
echo "This program comes with ABSOLUTELY NO WARRANTY express or implied."
echo "This is free software and you are welcome to redistribute it under certain conditions."
echo "Consult * LICENSE.txt * for terms of GPL 3 License and conditions of use."

read -p "Press ENTER to accept GPL v3 license terms to continue or terminate this bash shell to exit script"


echo
echo "$(tput setaf 5)****** CREDITS:  ******$(tput sgr 0)"
echo
echo "open-ipcamera is a collection of GPL3 bash scripts that stitch together other opensource projects into a complete Motion Detection Camera Solution."
echo "Just wanted to take a moment to thank these other opensource folks who toil in anonymity that provided me with the key components for this project:"
echo
echo "Dropbox_Uploader Developer Andrea Fabrizi whose scripts are used by open-ipcamera to shift images from local USB Flash storage to Dropbox"
echo "		$(tput setaf 2) https://github.com/andreafabrizi/Dropbox-Uploader.git $(tput sgr 0)"
echo
echo "Motion Project Developers Joseph Heenan * Mr-Dave *  Tosiara.  Motion used for motion detection image capture"
echo "		$(tput setaf 2) https://github.com/orgs/Motion-Project/people$(tput sgr 0)"
echo
echo "MSMTP Developer Martin Lambers: SMTP client used to relay alerts"
echo "		$(tput setaf 2) https://gitlab.marlam.de/marlam/msmtp$(tput sgr 0)"
echo
echo "And kudos to DROPBOX for providing an Enterprise-class API we used for shifting images from USB storage to cloud"
echo
echo "$(tput setaf 6)     - Terrence Houlahan Linux Engineer and open-ipcamera Project Founder terrence.houlahan@open-ipcamera.net$(tput sgr 0)"
echo




echo
echo "$(tput setaf 5)******  Create open-ipcamera Directories:  ******$(tput sgr 0)"
echo

if [ ! -d $PATHLOGINSTALL ]; then
	mkdir -p $PATHLOGINSTALL
	chown pi:pi $PATHLOGINSTALL
	chmod 751 $PATHLOGINSTALL
	echo "Created Directory $PATHLOGINSTALL"
	echo
fi



if [ ! -d $PATHSCRIPTS ]; then
	mkdir -p $PATHSCRIPTS
	chown pi:pi $PATHSCRIPTS
	chmod 751 $PATHSCRIPTS
	echo "Created Directory $PATHSCRIPTS"
	echo
fi

# Set markers in *INSTALL* logs
echo '####################################################################################################################' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo "$0 open-ipcamera v$VERSIONLATEST STARTED: `date +%Y-%m-%d_%H-%M-%S`" >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo 'Only events related to open-ipcamera installation write here.' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo "Applications log to: $PATHLOGSAPPS" >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log




echo
echo "$(tput setaf 5)****** PACKAGE MANAGEMENT:  ******$(tput sgr 0)"
echo
echo 'Elapsed Time for Package Management will be printed after this section completes:'
echo


time ./packages.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!




echo
echo "$(tput setaf 5)****** GPG: Import open-ipcamera Developers Public Key  ******$(tput sgr 0)"
echo


./encryption.sh 2>&1 |tee -a $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!
echo



echo
echo "$(tput setaf 5)****** IMAGE STORAGE CONFIGURATION:  ******$(tput sgr 0)"
echo

# Test if automount1 configured and if so then other aoutmounts will have also been done:
if [[ "$(systemctl is-active media-automount1.automount)" != "active" ]]; then
	./storage.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
else
	echo "Storage Already Configured"
fi




# Set markers in *APPLICATION* logs
# NOTE: This happens AFTER storage because the logging path does not exist until the USB storage has been configured
echo '####################################################################################################################' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo "$0 v$VERSIONLATEST STARTED: `date +%Y-%m-%d_%H-%M-%S`" >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo 'Only events related to open-ipcamera applications write here.' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo "Install-related operations log to: $PATHLOGINSTALL" >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log




echo
echo "$(tput setaf 5)****** CONFIGURE LOGGING:  ******$(tput sgr 0)"
echo


# Only configure logging is storage has not already been configured to be persistent
if [[ "$(grep -o 'Storage=persistent' /etc/systemd/journald.conf)" = '' ]]; then
	./log-config.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi




echo
echo "$(tput setaf 5)******  SET HOSTNAME:  ******$(tput sgr 0)"
echo

./hostname.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!




echo
echo "$(tput setaf 5)******  systemd-timesyncd.service CONFIGURATION  ******$(tput sgr 0)"
echo

./timedate.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!




echo
echo "$(tput setaf 5)****** SET BOOT PARAMS:  ******$(tput sgr 0)"
echo

./boot-params.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!



echo
echo "$(tput setaf 5)****** CAMERA KERNEL DRIVER: Load on Boot  ******$(tput sgr 0)"
echo


if [ ! -f /etc/modules-load.d/bcm2835-v4l2.conf ]; then
	./kernel-drivers.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi





echo
echo "$(tput setaf 5)****** Create Graph of Dependent Relationships Between Services on Boot:  ******$(tput sgr 0)"
echo



if [ ! -f $PATHSCRIPTS/boot_service_order_dependencies_graph.sh ]; then
	./service-graphServices.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi




echo
echo "$(tput setaf 5)******  /etc/ssh/sshd_config CONFIGURATION  ******$(tput sgr 0)"
echo

./sshd-config.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!




echo
echo "$(tput setaf 5)****** DROPBOX CONFIGURATION  ******$(tput sgr 0)"
echo


# Skip downloading and configuring DropboxUploader if the service is found and it is enabled
if [[ "$(systemctl is-active Dropbox-Uploader.service)" != "active" ]]; then
	./service-dropboxUploader.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
else
	echo "Dropbox Service Already Configured"
fi


echo
echo "$(tput setaf 5)****** Camera Software *MOTION* Configuration  ******$(tput sgr 0)"
echo

# The below scripts just execute sed expressions, so if they don not match they do nothing

./service-motion.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!

./users-motion.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!




echo
echo "$(tput setaf 5)****** MAIL ALERTS CONFIGURATION: SMTP Relay Configuration  ******$(tput sgr 0)"
echo

# MSMTP does not ship with a default config file: if it exists it implies MSMTP already configured
if [ ! -f /etc/msmtprc ]; then
	./smtpRelay-msmtp.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi



echo
echo "$(tput setaf 5)****** MAIL ALERTS CONFIGURATION: IP Address and Heat  ******$(tput sgr 0)"
echo


if [ ! -f $PATHSCRIPTS/email-camera-address.sh ]; then
	./service-emailCameraAddress.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi


if [ ! -f $PATHSCRIPTS/motion-detection-camera-address.sh ]; then
	./service-emailMotionDetectionCameraAddress.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi


if [ ! -f $PATHSCRIPTS/heat-alert.sh ]; then
	./service-heatAlert.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi




echo
echo "$(tput setaf 5)****** TROUBLESHOOTING SCRIPT:  ******$(tput sgr 0)"
echo


if [ ! -f $PATHSCRIPTS/troubleshooting-helper.sh ]; then
	./troubleshooting.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi



echo
echo "$(tput setaf 5)****** SET CPU AFFINITY:  ******$(tput sgr 0)"
echo


if [ ! -f $PATHSCRIPTS/set-cpu-affinity.sh ]; then
	./service-CPUaffinity.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi


echo
echo "$(tput setaf 5)****** Login Messages CONFIGURATION:  ******$(tput sgr 0)"
echo

./login-messages.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!



echo
echo
echo "$(tput setaf 5)****** SET DROPBOX ACCESS TOKEN:  ******$(tput sgr 0)"
echo


# Test if a Dropbox Access Token has previously saved and if not only then execute the script:
if [ ! -f /home/pi/.dropbox_uploader ]; then
	./dropbox-accessToken.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi



echo
echo
echo "$(tput setaf 5)****** CONFIGURE USERS:  ******$(tput sgr 0)"
echo


# The .ssh folder in user pi home directory does not exist by default: we test for its presence to determine if user config has been done previously and do it if not
if [ ! -d /home/pi/.ssh ]; then
	./users-linux.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi



echo
echo "$(tput setaf 5)****** SNMP CONFIGURATION:  ******$(tput sgr 0)"
echo


./monitoring-snmp.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!


# Test if an SNMP v3 ro user has been created by the presence of /usr/share/snmp/snmpd.conf and if not then execute the script:
if [ ! -f /usr/share/snmp/snmpd.conf ]; then
	./users-snmp.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi




echo
echo "$(tput setaf 5)****** apt-get upgrade and dist-upgrade: ******$(tput sgr 0)"
echo
echo "Elapsed Time to execute UPGRADE will be printed after it completes:"
echo


time ./os-upgrade.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!






echo
echo "$(tput setaf 5)****** Config Local DNS Caching Stub Resolver and Networking: ******$(tput sgr 0)"
echo
echo "Elapsed Time to execute UPGRADE will be printed after it completes:"
echo


time ./networking.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!







echo
echo "$(tput setaf 5)******  POST-INSTALL OPERATIONS:  ******$(tput sgr 0)"
echo


time ./open-ipcamera_post-install.sh 2>> $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!




echo
echo "$(tput setaf 5)****** Show open-ipcamera Services Executing on Timers  ******$(tput sgr 0)"
echo

systemctl list-timers --all




echo
echo
echo "$(tput setaf 1)** WARNING: * variables-secure.sh * will be encrypted when you press ENTER: Ensure passwords recorded elsewhere ** $(tput sgr 0)"
echo
echo "$(tput setaf 3)                              ** Remember to configure firewall rules ** $(tput sgr 0)"
echo
read -p 'Press * Enter * to reboot Pi after reviewing open-ipcamera install script feedback'
echo



echo
echo "$(tput setaf 5)****** Backup and Encrypt *variables-secure.sh* File: ******$(tput sgr 0)"
echo


# If an encrypted GPG backup of variables-secure.sh does not exist then execute the backup script:
if [ ! -f $PATHSCRIPTS/variables-secure.sh.asc ]; then
	./variables-secure.sh_backup.sh 2>&1 |tee -a $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
	wait $!
fi




echo
echo "$(tput setaf 5)****** DELETE open-ipcamera REPO ******$(tput sgr 0)"
echo

# After open-ipcamera is configured the following script deletes the install directory containing the scripts:
./open-ipcamera_delete.sh 2>&1 |tee -a $PATHLOGINSTALL/install_v$VERSIONLATEST.log&
wait $!
echo




echo '' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo "$0 v$VERSIONLATEST COMPLETED:: `date +%Y-%m-%d_%H-%M-%S`" >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo '####################################################################################################################' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGINSTALL/install_v$VERSIONLATEST.log



echo '' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo "$0 v$VERSIONLATEST COMPLETED:: `date +%Y-%m-%d_%H-%M-%S`" >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo '####################################################################################################################' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log
echo '' >> $PATHLOGSAPPS/install_v$VERSIONLATEST.log




echo
echo 'System will now be rebooted'

systemctl reboot
