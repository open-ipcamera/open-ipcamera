#!/bin/bash

# Author:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20181116

# "pi-cam-config.sh": Installs and configs Raspberry Pi camera application, related camera Kernel module and motion detection alerts
#   Hardware:   Raspberry Pi 2/3B+ *AND* Pi Zero W
#   OS:         Raspbian "Stretch"

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

# README.txt file distributed with this this script
# VIDEO:  www.YouTube.com/user/LinuxEngineer

# If I saved you a few hours or possibly DAYS of manually configuring one or more pi-cams consider buying me a beer ;-)
# paypal.me/TerrenceHoulahan

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
# Dropbox is used to shift video and pics to the cloud to prevent evidence being destroyed or stolen
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
SASLUSER='yourUserName'
SASLPASSWD='ChangeMe'
SMTPRELAYFQDN='mail.yourRelayDomain.com'
SMTPRELAYFROM='you@domainYouWantPiToAppearToBeSendingAlertsFrom'

# GMAIL SMTP Relay Server:  NOTE: Requires a PAID Google-hosted mail account
GMAILADDRESS='terrence.houlahan.devices@gmail.com'
GMAILPASSWD='YourGmailPasswdHere'


# Specify an email address where IP of camera will be sent to you
# This email address can be different than the one specified in 'ONEVENTSTART' variable below
EMAILCAMERAIP='terrence.houlahan.devices@gmail.com'

### Variables: Camera Application "Motion"
# NOTE: "motion.conf" has many more adjustable parameters than those below, which are a subset of just very useful or required ones:

# Change *ONLY* email address in variable ONEVENTSTART below taking care not to delete any of the encasing single quote marks
ONEVENTSTART='echo '"'Subject: Motion Detected ${HOSTNAME}'"' | msmtp terrence.houlahan.devices@gmail.com'

IPV6ENABLED='on'
# NOTE: user for Camera application "Motion" login does not need to be a Linux system user account created with "useradd" command: can be arbitrary
USER='me'
PASSWD='xF9e4Ldg1'

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
STREAMPORT='8081'
STREAMQUALITY='50'
STREAMMOTION='1'
STREAMLOCALHOST='off'
STREAMAUTHMETHOD='0'
WEBCONTROLLOCALHOST='off'
WEBCONTROLPORT='8080'



#############################################################
# ONLY EDIT BELOW THIS LINE IF YOU KNOW WHAT YOU ARE DOING! #
#############################################################

# Below variable is self-populating- there is no need to modify if
CAMERAIPV4="$(ip addr list|grep wlan0|awk '{print $2}'|cut -d '/' -f1|cut -d ':' -f2)"
CAMERAIPV6="$(ip -6 addr list|grep inet6|grep 'scope link'| awk '{ print $2}')"

echo ''
echo "$(tput setaf 5)****** LICENSE:  ******$(tput sgr 0)"
echo ''

echo '"pi-cam-config.sh" Copyright (C) 2018 Terrence Houlahan'
echo ''
echo 'This program comes with ABSOLUTELY NO WARRANTY express or implied.'
echo 'This is free software and you are welcome to redistribute it under certain conditions.'
echo 'Consult "LICENSE.txt" for terms of GPL 3 License and conditions of use.'

read -p 'Press "Enter" to ACCEPT license and warranty terms to continue or "CTRL C" to EXIT'



echo ''
echo "$(tput setaf 5)****** DELETE DETRITUS FROM PRIOR INSTALLS:  ******$(tput sgr 0)"
echo ''
echo '### Restore Pi to predictable known state prior prior to starting the install: ###'
echo ''

# Reset the hosts file back to default state
sed -i "s/127\.0\.0\.1.*/127\.0\.1\.1      raspberrypi/" /etc/hosts
sed -i "s/::1.*/::1     raspberrypi/" /etc/hosts

hostnamectl set-hostname raspberrypi
systemctl restart systemd-hostnamed&
wait $!


# Delete "motion and any related config files for using "apt-get purge" :
if [[ ! $(dpkg -l | grep motion) = '' ]]; then
	apt-get purge -q -y motion
fi

# Delete "Dropbox-Uploader"
if [ -d /home/pi/Dropbox-Uploader ]; then
	rm -rf /home/pi/Dropbox-Uploader
fi

if [ -d /home/pi/.ssh ]; then
	rm -R /home/pi/.ssh
fi

# Delete our pub key or every time we run the key it will just continue to append a new copy of the key:
if [ -f /home/pi/.ssh/authorized_keys ]; then
sed -i "\|$MYPUBKEY|d" /home/pi/.ssh/authorized_keys
fi


### Uninstall any SystemD services and their related files previously created by this script:

# Uninstall automount service for the USB storage:
if [ -f /etc/systemd/system/media-pi.mount ]; then
	systemctl stop media-pi.mount
	systemctl disable media-pi.mount
	systemctl daemon-reload
	rm /etc/systemd/system/media-pi.mount
fi

if [ -f /etc/systemd/system/media-pi.automount ]; then
	rm /etc/systemd/system/media-pi.automount
fi


# Uninstall dropbox photo uploader SystemD service:
# NOTE: This is NOT part of the Dropbox-uploader script- it just uses it
if [ -f /etc/systemd/system/Dropbox-Uploader.service ]; then
	systemctl disable Dropbox-Uploader.service
	systemctl disable Dropbox-Uploader.timer
	systemctl daemon-reload
	rm /etc/systemd/system/Dropbox-Uploader.service
	rm /etc/systemd/system/Dropbox-Uploader.timer
fi

if [ -d /home/pi/scripts/Dropbox-Uploader ]; then
	rm -r /home/pi/scripts/Dropbox-Uploader
fi



if [ -f /etc/modules-load.d/bcm2835-v4l2.conf  ]; then
	rm /etc/modules-load.d/bcm2835-v4l2.conf
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

# apt-get purge does not delete log which will contain errors from previous builds: We truncate it to show only new stuff related to most recent build:
if [ -f /var/log/motion/motion.log ]; then
	truncate -s 0 /var/log/motion/motion.log
fi

# Messages are appended to MOTD by this script:truncate the file to wipe existing messages to stop being repeatedly appended
truncate -s 0 /etc/motd



echo ''
echo "$(tput setaf 5)****** SECURITY: Set Passwords - Disable Autologin - Enable Public Key Access ******$(tput sgr 0)"
echo ''

# By default no passwords set for users 'pi' and 'root'
echo "*** Set passwd for user 'pi' ***"
echo "pi:$PASSWDPI"|chpasswd

echo "*** Set passwd for user 'root' ***"
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

	echo "ECDSA 521 bit keypair created for user pi"
fi

echo ''
echo "$MYPUBKEY" >> /home/pi/.ssh/authorized_keys
echo "Added Your Public Key to 'authorized_keys' file"
echo ''

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
sed -i "s|#PermitEmptyPasswords no|#PermitEmptyPasswords no|" /etc/ssh/sshd_config
sed -i "s|#X11Forwarding yes|X11Forwarding yes|" /etc/ssh/sshd_config
sed -i "s|PrintMotd yes|PrintMotd no|" /etc/ssh/sshd_config
sed -i "s|#PrintLastLog yes|PrintLastLog yes|" /etc/ssh/sshd_config
sed -i "s|#TCPKeepAlive yes|TCPKeepAlive yes|" /etc/ssh/sshd_config

# No need for autologin now that we enabled Public Key Access so we disable it:
sed -i "s/autologin-user=pi/#autologin-user=pi/" /etc/lightdm/lightdm.conf
systemctl disable autologin@.service
echo 'Disabled autologin'



echo ''
echo "$(tput setaf 5)****** USB Flash Storage Configuration:  ******$(tput sgr 0)"
echo ''

# Interesting thread on auto mounting choices:
# https://unix.stackexchange.com/questions/374103/systemd-automount-vs-autofs

apt-get update


if [[ ! $(dpkg -l | grep usbmount) = '' ]]; then
	apt-get purge -q -y usbmount
fi


# We want EXFAT because it supports large file sizes and can be read on Mac and Windows:
if [[ $(dpkg -l | grep exfat-fuse) = '' ]]; then
	apt-get install -q -y exfat-fuse
fi

# Disable automounting by the default Filemanager "pcmanfm": it steps on the SystemD automount which gives us flexibility to change mount options:
if [ -f /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf ]; then
	sed -i 's/mount_removable=1/mount_removable=0/' /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf
fi


# SystemD mount file created below should be named same as its mountpoint as specified in "Where" directive below:
cat <<EOF> /etc/systemd/system/media-pi.mount
[Unit]
Description=Create mount for USB storage
#Before=

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
Description=Automount the USB storage mount

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
	echo ''
	echo 'ERROR: Attach an EXFAT formatted USB flash drive to be a target for video to be written'
	echo 'Re-run script after minimum storage requirements met. Exiting'
	echo ''
	exit
else
	echo ''
	echo 'USB STORAGE FOUND'
fi

# Exit script USB storage attached but not formatted for EXFAT filesystem:
if [[ $(lsblk -f|grep sda1|awk '{print $2}') = '' ]]; then
	echo ''
	echo 'ERROR: USB flash drive NOT formatted for * EXFAT * filesystem'
	echo 'Re-run script after minimum storage requirements met. Exiting'
	echo ''
	exit
else
	echo ''
	echo 'USB STORAGE IS EXFAT:'
	echo 'Script will proceed'
	echo ''
fi

systemctl enable media-pi.mount

if [ ! -d /home/pi/scripts ]; then
mkdir -p /home/pi/scripts
fi



echo ''
echo "$(tput setaf 5)****** SET BOOT PARAMS:  ******$(tput sgr 0)"
echo ''

# raspian-config: How to interface from the CLI:
# https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup

# Clear any boot params added during a previous build and then add each back with most current value set:
# Enable camera (No raspi-config option to script this):
sed -i '/start_x=1/d' /boot/config.txt
echo 'start_x=1' >> /boot/config.txt

sed -i '/disable_camera_led=1/d' /boot/config.txt
echo 'disable_camera_led=1' >> /boot/config.txt


if [ $(cat /proc/device-tree/model | awk '{ print $3 }') != 'Zero' ]; then
	echo "NOT PI ZERO!"
	sed -i '/gpu_mem=128/d' /boot/config.txt
	echo 'gpu_mem=128' >> /boot/config.txt
else
	echo "PI ZERO"
#	sed -i '/gpu_mem=512/d' /boot/config.txt
#	echo 'gpu_mem=512' >> /boot/config.txt
fi


echo 'Camera enabled'
echo 'Camera LED light disabled'

# Disable splash screen to stop it hiding any errors as Pi rises up on boot:
sed -i '/disable_splash=1/d' /boot/config.txt
echo 'disable_splash=1' >> /boot/config.txt

echo 'Disabled boot splash screen so we can see errors while host is rising up.'




echo ''
echo "$(tput setaf 5)******  SET HOSTNAME:  ******$(tput sgr 0)"
echo ''

hostnamectl set-hostname $OURHOSTNAME.$OURDOMAIN
systemctl restart systemd-hostnamed&
wait $!

# hostnamectl does NOT update its own entry in /etc/hosts so must do separately:
sed -i "s/127\.0\.1\.1.*/127\.0\.0\.1      $OURHOSTNAME $OURHOSTNAME.$OURDOMAIN/" /etc/hosts
sed -i "s/::1.*/::1     $OURHOSTNAME $OURHOSTNAME.$OURDOMAIN/" /etc/hosts


echo ''
echo "$(tput setaf 5)****** PACKAGE INSTALLATION:  ******$(tput sgr 0)"
echo ''


if [[ $(dpkg -l | grep motion) = '' ]]; then
	apt-get install -q -y motion
fi


# 'libimage-exiftool-perl' used to get metadata from videos and images from the CLI. Top-notch tool
# http://owl.phy.queensu.ca/~phil/exiftool/
if [[ $(dpkg -l | grep libimage-exiftool-perl) = '' ]]; then
	apt-get install -q -y libimage-exiftool-perl
fi


# 'exiv2' is another tool for obtaining and changing media metadata but has limited support for video files- wont handle mp4- compared to 'libimage-exiftool-perl'
# http://www.exiv2.org/
if [[ $(dpkg -l | grep exiv2) = '' ]]; then
	apt-get install -q -y exiv2
fi


if [[ $(dpkg -l | grep msmtp) = '' ]]; then
	apt-get install -q -y msmtp
fi

if [[ $(dpkg -l | grep mutt) = '' ]]; then
	apt-get install -q -y mutt
fi

# vim-tiny- which is crap like nano- will also match unless grep-ed with boundaries:
if [[ $(dpkg -l | grep -w '\Wvim\W') = '' ]]; then
	apt-get install -q -y vim
fi

if [[ $(dpkg -l | grep git) = '' ]]; then
	apt-get install -q -y git
fi


if [[ $(dpkg -l | grep mailutils) = '' ]]; then
	apt-get install -q -y mailutils
fi


# NOTE: following are not required but just included because they are useful

# mtr is like traceroute on steroids.  All network engineers I know use this in preference to "traceroute" or "tracert":
if [[ $(dpkg -l | grep mtr) = '' ]]; then
	apt-get install -q -y mtr
fi

# tcpdump is a packet sniffer you can use to investigate connectivity issues and analyze traffic:
if [[ $(dpkg -l | grep tcpdump) = '' ]]; then
	apt-get install -q -y tcpdump
fi

# iptraf-ng can be used to investigate bandwidth issues if you are puking too many chunky images over a thin connection:
if [[ $(dpkg -l | grep iptraf-ng) = '' ]]; then
	apt-get install -q -y iptraf-ng
fi


echo ''
echo "$(tput setaf 5)****** DROPBOX Storage Configuration:  ******$(tput sgr 0)"
echo ''
echo "https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md"
echo ''

# "Dropbox-Uploader" facilitates copying images from local USB Flash storage to cloud safeguarding evidence from theft or destruction of Pi-Cam
echo ''

if [ ! -d /home/pi/Dropbox-Uploader ]; then
	cd /home/pi
	git clone https://github.com/andreafabrizi/Dropbox-Uploader.git
	else
	echo 'Failed to download dependent repo https://github.com/andreafabrizi/Dropbox-Uploader.git- script will exit'
	exit
fi


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


# Useful SystemD Timer References to help you Transition from using Cron: 
#	https://wiki.archlinux.org/index.php/Systemd/Timers
#	https://unix.stackexchange.com/questions/126786/systemd-timer-every-15-minutes
#	https://www.freedesktop.org/software/systemd/man/systemd.time.html
#	https://unix.stackexchange.com/questions/427346/im-writing-a-systemd-timer-what-value-should-i-use-for-wantedby


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



echo ''
echo "$(tput setaf 5)****** CAMERA KERNEL DRIVER: Load on Boot  ******$(tput sgr 0)"
echo ''


# Load Kernel module for Pi camera on boot:
cat <<'EOF'> /etc/modules-load.d/bcm2835-v4l2.conf
bcm2835-v4l2

EOF

# Rebuild Kernel modules dependencies map
depmod -a

# Load the Camera Kernel Module
modprobe bcm2835-v4l2


echo ''
echo "$(tput setaf 5)****** DEFAULT EDITOR: Change FROM *Nano* TO *vi*  ******$(tput sgr 0)"
echo ''


# Nano is crap: change default editor to a universal Unix standard vi
update-alternatives --set editor /usr/bin/vim.basic

if [ -f /home/pi/.selected_editor ]; then
	sed -i 's|SELECTED_EDITOR="/bin/nano"|SELECTED_EDITOR="/usr/bin/vim"|' /home/pi/.selected_editor
fi

cp /usr/share/vim/vimrc /home/pi/.vimrc

# Below sed expression stops vi from going to "visual" mode when one tries to copy text GRRRRR!
sed -i 's|^"set mouse=a.*|set mouse-=a|' /home/pi/.vimrc
sed -i 's|^"set mouse=a.*|set mouse-=a|' /etc/vim/vimrc


echo ''
echo "$(tput setaf 5)****** Camera Software *MOTION* Configuration  ******$(tput sgr 0)"
echo ''
echo 'Further Info: https://motion-project.github.io/motion_config.html'
echo ''

# Configure *BASIC* Settings (just enough to get things generally working):
sed -i "s/ipv6_enabled off/ipv6_enabled $IPV6ENABLED/" /etc/motion/motion.conf
sed -i "s/daemon off/daemon on/" /etc/motion/motion.conf
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


# Configure Motion to run by daemon:
# Remark the path is different to the target of foregoing sed expressions
sed -i "s/start_motion_daemon=no/start_motion_daemon=yes/" /etc/default/motion

# Set "motion" to start on boot:
systemctl enable motion.service


echo ''
echo "$(tput setaf 5)****** MAIL ALERTS CONFIGURATION:  ******$(tput sgr 0)"
echo ''

# References:
# http://msmtp.sourceforge.net/doc/msmtp.html
# https://wiki.archlinux.org/index.php/Msmtp

# MSMTP does not provide a default config file so we create one below:
cat <<EOF> /etc/msmtprc
defaults
auth           on
tls            on
tls_starttls   on
logfile        ~/.msmtp.log

# For TLS support uncomment either "tls_trustfile_file" *OR* "tls_fingerprint": NOT BOTH
# Note: "tls_trust_file" wont work with self-signed certs: use the "tls_fingerprint" directive instead

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




echo ''
echo "$(tput setaf 5)****** SNMP Configuration:  ******$(tput sgr 0)"
echo ''


apt-get install -q -y snmp snmpd snmp-mibs-downloader libsnmp-dev

# *DISABLE* local-only connections to SNMP daemon
sed -i "s/agentAddress  udp:127.0.0.1:161/#agentAddress  udp:127.0.0.1:161/" /etc/snmp/snmpd.conf

# *ENABLE* remote SNMP connectivity to cameras:
# A further Reminder to please restrict access by firewall to your cameras
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


systemctl enable snmpd.service
systemctl start snmpd.service


# Test our SNMPv3 config works correctly by checking Camera Location
snmpget -v3 -a SHA -x AES -A $SNMPV3AUTHPASSWD -X $SNMPV3ENCRYPTPASSWD -l authNoPriv -u pi $CAMERAIPV4 sysLocation.0





echo ''
echo "$(tput setaf 5)****** Email NOTIFICATIONS: IP and HEAT ALERTS  ******$(tput sgr 0)"
echo ''

# Apple offers no way to identify the IP of a device tethered to an iPhone HotSpot.
# This systemd service emails the camera IP address assigned by a HotSpot to email specified in variable "EMAILCAMERAIP"
# Note: This feature will only work if you have configured a working mail relay for the camera to use


# Create Mutt configuration file for user "pi"
cat <<EOF> /home/pi/.muttrc

set sendmail=$(command -v msmtp)"
set use_from=yes
set realname="$HOSTNAME"
set from="pi@$HOSTNAME.$OURDOMAIN"
set envelope_from=yes
set editor="vim.basic"

EOF



cat <<EOF> /home/pi/scripts/email-camera-address.sh
#!/bin/bash

sleep 30
echo -e “$HOSTNAME \n $CAMERAIPV4 \n $CAMERAIPV6” | mutt -s "IP Address of Camera $HOSTNAME" $EMAILCAMERAIP

EOF



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

if [ \$(/opt/vc/bin/vcgencmd measure_temp|cut 'd=' -f2|cut -d '.' -f1) -gt \$HEATTHRESHOLDWARN ]; then
	echo -e “Temp exceeds WARN threshold: \$HEATTHRESHOLD C \n Timer controlling frequency of this alert: heat-alert.timer \n \$HOSTNAME \n \$CAMERAIPV4 \n \$CAMERAIPV6” | mutt -s "Heat Alert \$HOSTNAME" \$EMAILCAMERAIP
elif [ \$(/opt/vc/bin/vcgencmd measure_temp|cut 'd=' -f2|cut -d '.' -f1) -gt \$HEATTHRESHOLDSHUTDOWN ]; then
	echo -e “Temp exceeds SHUTDOWN threshold: \$HEATTHRESHOLD C \n \n Pi was shutdown due to excessive heat condition \n \$HOSTNAME \n \$CAMERAIPV4 \n \$CAMERAIPV6” | mutt -s "Shutdown Alert \$HOSTNAME" \$EMAILCAMERAIP
	systemctl poweroff
else
	exit
fi

EOF


cat <<EOF> /etc/systemd/system/heat-alert.service
[Unit]
Description=Email Heat Alerts
#Before=

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




# Change ownership of all files created by this script FROM user "root" TO user "pi":
chown -R pi:pi /home/pi



echo ''
echo "$(tput setaf 5)****** /etc/motd CONFIGURATION:  ******$(tput sgr 0)"
echo ''


echo '' >> /etc/motd
echo "Video Camera Status: $(echo "sudo systemctl status motion")" >> /etc/motd
echo '' >> /etc/motd
echo "Camera Address: $CAMERAIPV4:8080" >> /etc/motd
echo '' >> /etc/motd
echo "Local Images Written To: $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' )" >> /etc/motd
echo '' >> /etc/motd
echo 'To stop/start/reload the Motion daemon:' >> /etc/motd
echo 'sudo systemctl [stop|start|reload] motion' >> /etc/motd
echo '' >> /etc/motd
echo 'Video Camera Logs: /var/log/motion/motion.log' >> /etc/motd
echo '' >> /etc/motd
echo "$(v4l2-ctl -V)" >> /etc/motd
echo '' >> /etc/motd
echo 'To manually change *VIDEO* resolution using Video4Linux driver tailor below example to your use case:' >> /etc/motd
echo 'Step 1: sudo systemctl stop motion' >> /etc/motd
echo 'Step 2: sudo v4l2-ctl --set-fmt-video=width=1920,height=1080,pixelformat=4' >> /etc/motd
echo '' >> /etc/motd
echo 'To obtain resolution and other data from an image file:' >> /etc/motd
echo 'exiv2 /media/pi/imageName.jpg' >> /etc/motd
echo '' >> /etc/motd
echo 'To see metadata for an image or video:' >> /etc/motd
echo 'exiftool /media/pi/videoName.mp4' >> /etc/motd
echo '' >> /etc/motd
echo 'Below tools were installed to assist you in troubleshooting any networking issues:' >> /etc/motd
echo 'mtr, tcpdump and iptraf-ng'
echo 'To edit or delete these login messages:  vi /etc/motd' >> /etc/motd
echo '' >> /etc/motd
echo '##########################################################################' >> /etc/motd

echo ''
echo "$(tput setaf 5)****** POST-CONFIG DIAGNOSTICS:  ******$(tput sgr 0)"
echo ''
echo 'Pi Temperature reported by "vcgencmd measure_temp" below should be between 40-60 degrees Celcius:'
echo '------------------------------------------------------------------------'
/opt/vc/bin/vcgencmd measure_temp
echo ''
echo 'Output of command "vcgencmd get_camera" below should report: supported=1 detected=1'
echo '------------------------------------------------------------------------'
vcgencmd get_camera
echo ''
echo 'Value below for camera driver bcm2835_v4l2 should report value of 1 (camera driver loaded). If not camera will be down:'
echo '------------------------------------------------------------------------'
lsmod |grep v4l2
echo''
echo 'Device "video0" should be shown below. If not your camera will be down:'
echo '------------------------------------------------------------------------'
ls -al /dev | grep video0
echo''
echo 'Check Host Timekeeping both correct and automated:'
echo '------------------------------------------------------------------------'
systemctl status systemd-timesyncd.service
echo ''
echo 'Open UDP/123 in Router FW if error "Timed out waiting for reply" is reported'
echo ''
echo ''
ping -c 2 www.google.com
echo ''
ping -c 2 8.8.8.8
echo ''
echo 'If Pinging "www.google.com" by name failed but pinging "8.8.8.8" succeeded check that port UDP/53 is open'
echo ''
echo ''

# Wipe F1Linux.com "pi-cam-config" files as clear text passwds live in here:
rm -rf /home/pi/pi-cam-config

echo ''
echo "$(tput setaf 5)****** Paste Dropbox Access Token when prompted to:  ******$(tput sgr 0)"
echo ''
echo ''
/home/pi/Dropbox-Uploader/dropbox_uploader.sh upload
echo ''
echo ''

echo 'Big Thanks to ANDREA FABRIZI:'
echo '-----------------------------------------------------------------------------------------------------------------'
echo 'My script "pi-cam-config.sh" downloads and uses his repo to shift images from local USB Flash storage to Dropbox'
echo "		$(tput setaf 5) https://github.com/andreafabrizi/Dropbox-Uploader.git $(tput sgr 0)"
echo ''
echo ''

echo "Note below address of your camera to access via web browser after reboot:"
echo "$(tput setaf 2) ** Camera Address: "CAMERAIPV4":8080 ** $(tput sgr 0)"
echo "$(tput setaf 2) ** Camera Address: "CAMERAIPV6":8080 ** $(tput sgr 0)"

echo '' >> /etc/motd
echo '' >> /etc/motd

echo '###############################################################################' >> /etc/motd
echo "##  $(tput setaf 4)If this script saved you lots of time doing manual config buy me a beer!$(tput sgr 0) ##" >> /etc/motd
echo "##                      $(tput setaf 4)paypal.me/TerrenceHoulahan $(tput sgr 0)                      ##" >> /etc/motd
echo '###############################################################################' >> /etc/motd

echo '' >> /etc/motd
echo '' >> /etc/motd
echo "$(tput setaf 1)** WARNING: DO NOT FORGET TO CONFIGURE FIREWALL RULES TO RESTRICT ACCESS TO YOUR CAMERA HOSTS ** $(tput sgr 0)"

read -p "Press Enter to reboot after reviewing script feedback above"

systemctl reboot
