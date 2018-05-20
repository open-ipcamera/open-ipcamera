#!/bin/bash

# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application, drivers and Kernel module
# Compatibility:      Tested and known to work with Raspian "Stretch" running on a Pi3+ as of 20180514

# Author:  Terrence Houlahan, LPIC2 Certified Linux Engineer
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20180514
 
# Beerware License: If I saved you a few hours of your life fiddling with this crap buy me a beer
#	paypal.me/TerrenceHoulahan


######  Variables: ######
#
# Variables are expanded in sed expressions and 
# Change or delete specimen values below as appropriate:

### Variables: Motion
# NOTE: "motion.conf" has many more adjustable parameters than those below, which are a subset of just very useful or required ones:
IPV6ENABLED='on'
USER='terrence'
PASSWD='xF9e4Ld'
WIDTH='640'
HEIGHT='480'
FRAMERATE='4'
AUTOBRIGHTNESS='off'
QUALITY='75'
FFMPEGOUTPUTMOVIES='on'
MAXMOVIETIME='120'
FFMPEGVIDEOCODEC='mp4'
ONEVENTSTART='echo '"'Subject: Motion Detected ${HOSTNAME}'"' | msmtp terrence.houlahan.devices@gmail.com'
THRESHOLD='1500'
LOCATEMOTIONMODE='preview'
LOCATEMOTIONSTYLE='redbox'
OUTPUTPICTURES='center'
STREAMPORT='8081'
STREAMQUALITY='50'
STREAMMOTION='1'
STREAMLOCALHOST='off'
STREAMAUTHMETHOD='0'
WEBCONTROLLOCALHOST='off'
WEBCONTROLPORT='8080'


### Variables: MSMTP (to send alerts):
# SELF-HOSTED SMTP Relay Mail Server:
SMTPRELAYPORT='25'
SASLUSER='terrence'
SASLPASSWD='vTn&G5dqYk9Lj%4R3V8z&2HapP@7Ewf6!b3Mi?47>'
SMTPRELAYFQDN='mail.linuxengineer.co.uk'
SMTPRELAYFROM='terrence@houlahan.co.uk'

# GMAIL SMTP Relay Server:  NOTE: Requires a PAID Google-hosted mail account
GMAILADDRESS='terrence.houlahan.devices@gmail.com'
GMAILPASSWD='ABCD1234'

#### Dropbox-Uploader Variables:

# Dropbox can be used to shift video and pics to the cloud to prevent evidence being destroyed or stolen
# Click "Generate" button under the heading "Generated access token" in the "Developer section of your Dropbox account
DROPBOXACCESSTOKEN='ABCD1234'


#############################################################
#                                                           #
# ONLY EDIT BELOW THIS LINE IF YOU KNOW WHAT YOU ARE DOING! #
#                                                           #
#############################################################


echo ''
echo '###### Check EXFAT Formatted USB Storage Attached ######'
echo ''
echo 'Check USB storage attached to be a target for the video app:'
echo ''
echo 'We do NOT store video with the OS!'
echo ''

# Exit script if NO USB storage attached:
if [[ $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' ) = '' ]]; then
	echo ''
	echo 'ERROR: Attach an EXFAT formatted USB thumb drive to be a target for video to be written'
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
	echo 'ERROR: USB thumb drive NOT formatted for * EXFAT * filesystem'
	echo 'Re-run script after minimum storage requirements met. Exiting'
	echo ''
	exit
else
	echo ''
	echo 'USB STORAGE IS EXFAT:'
	echo 'Script will proceed'
	echo ''
fi


echo '###### DELETE DETRITUS FROM PRIOR INSTALLS ######'
echo ''
echo  '### Delete files which this script created and/or edited from a previous install to restore host to predictable known state:'
echo ''


if [ -f /home/pi/.vimrc ]; then
	rm /home/pi/.vimrc
fi


if [ -f /etc/msmtprc ]; then
	rm /etc/msmtprc
fi


if [ -f /home/pi/.muttrc  ]; then
	rm /home/pi/.muttrc 
fi


if [ -f /etc/modules-load.d/bcm2835-v4l2.conf  ]; then
	rm /etc/modules-load.d/bcm2835-v4l2.conf
fi


if [ -f /home/pi/scripts/housekeeping.sh ]; then
	rm /home/pi/scripts/housekeeping.sh
fi


if [ -f /home/pi/scripts/Dropbox-Uploader.sh ]; then
	rm /home/pi/scripts/Dropbox-Uploader.sh
fi


if [ -f /var/spool/cron/crontabs/pi ]; then
	sed -i '/.*Dropbox-Uploader.sh/d' /var/spool/cron/crontabs/pi
	sed -i '/.*housekeeping.sh/d' /var/spool/cron/crontabs/pi
fi

# Messages are added by this script to MOTD: wipe for new rebuild
truncate -s 0 /etc/motd


# Delete "motion and any related config files for using "apt-get purge" :
if [ ! $(dpkg -l | grep motion) = '' ]; then
	apt-get purge -q -y motion&
	wait $!
fi

# apt-get purge does not blow-away the log: Lets just truncate it to show only activity related to most recent build:
if [ -f /var/log/motion/motion.log ]; then
	truncate -s 0 /var/log/motion/motion.log
fi



###### BEGIN INSTALLATION ######

apt-get update&
wait $!

echo ''
echo '###### Configure Camera Application Motion ######'
# https://motion-project.github.io/motion_config.html
echo ''


if [[ $(dpkg -l | grep motion) = '' ]]; then
apt-get install -q -y motion&
wait $!
fi

if [[ $(dpkg -l | grep msmtp) = '' ]]; then
apt-get install -q -y msmtp&
wait $!
fi

if [[ $(dpkg -l | grep mutt) = '' ]]; then
apt-get install -q -y mutt&
wait $!
fi

if [[ $(dpkg -l | grep vim) = '' ]]; then
apt-get install -q -y vim&
wait $!
fi

if [[ $(dpkg -l | grep git) = '' ]]; then
apt-get install -q -y git&
wait $!
fi

# NOTE: following are not required but just included because they are useful
if [[ $(dpkg -l | grep mtr) = '' ]]; then
apt-get install -q -y mtr&
wait $!
fi

if [[ $(dpkg -l | grep tcpdump) = '' ]]; then
apt-get install -q -y tcpdump&
wait $!
fi


echo ''
echo '###### Configure Storage ######'
echo ''

# Interesting thread on auto mounting choices:
# https://unix.stackexchange.com/questions/374103/systemd-automount-vs-autofs


if [[ ! $(dpkg -l | grep usbmount) = '' ]]; then
apt-get purge -q -y usbmount&
wait $!
fi


# We want EXFAT because it supports large file sizes and can read be read on Macs and Windows machines:
if [[ $(dpkg -l | grep exfat-fuse) = '' ]]; then
apt-get install -q -y exfat-fuse&
wait $!
fi

# Disable automounting by the default Filemanager "pcmanfm": it steps on systemd automount which gives enables us to change mount options:
sed -i 's/mount_removable=1/mount_removable=0/' /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf


# The filename should match mount point path in "Where":
cat <<EOF> /etc/systemd/system/media-pi.automount
[Unit]
Description=Automount USBstorage

[Automount]
Where=/media/pi
DirectoryMode=0755
TimeoutIdleSec=15

[Install]
WantedBy=multi-user.target

EOF


# The filename should match mount point path in "Where":
cat <<EOF> /etc/systemd/system/media-pi.mount
[Unit]
Description=USBstorage
#Before=

[Mount]
What=/dev/sda1
Where=/media/pi
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF

systemctl enable media-pi.mount
#systemctl daemon-reload
#systemctl start media-pi.mount


# Housekeeping: Do not let images accumulate infinitely.  Prune them:

cat <<EOF> /home/pi/scripts/housekeeping.sh
#!/bin/bash

if [[ \$(find $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' ) -type f -mmin +59 2>/dev/null) ]]; then
rm \$(find $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' ) -type f -mmin +59 2>/dev/null)
fi

EOF

chmod 700 /home/pi/scripts/housekeeping.sh


# Create crontab entry in user "pi" crontab to schedule deleting local files:
cat <<'EOF'> /var/spool/cron/crontabs/pi
*/59 * * * * /home/pi/scripts/housekeeping.sh

EOF


echo ''
echo '###### Configure Cloud Storage ######'
echo ''
echo "https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md"
echo ''

# "Dropbox-Uploader.sh" enables you to shift pics into cloud- ensuring evidence not destroyed with Pi Cam
echo ''

if [ ! -d /home/pi/Dropbox-Uploader ]; then
	git clone https://github.com/andreafabrizi/Dropbox-Uploader.git&
	wait $!
fi

mkdir -p /home/pi/scripts

cat <<EOF> /home/pi/scripts/Dropbox-Uploader.sh
#!/bin/bash

cd /home/pi/Dropbox-Uploader
./dropbox_uploader.sh upload $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' )/*.jpg .&
wait \$!

./dropbox_uploader.sh upload $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' )/*.$FFMPEGVIDEOCODEC .&
wait \$!

EOF

chmod 700 /home/pi/scripts/Dropbox-Uploader.sh
chown pi:pi /home/pi/scripts/Dropbox-Uploader.sh


# Create crontab entry in user "pi" crontab to schedule uploading copies off local files up to cloud:
echo '*/2 * * * * /home/pi/scripts/Dropbox-Uploader.sh'  >> /var/spool/cron/crontabs/pi


chmod 600 /var/spool/cron/crontabs/pi
chown pi:crontab /var/spool/cron/crontabs/pi


echo ''
echo '###### Configure Camera Kernel Driver ######'
echo ''


# Load Kernel module for Pi camera on boot:
cat <<'EOF'> /etc/modules-load.d/bcm2835-v4l2.conf
bcm2835-v4l2

EOF

echo ''
echo '###### Configure Default Editor ######'
echo ''


# Nano is a piece of crap: change default editor to something more sensible
update-alternatives --set editor /usr/bin/vim.basic
sed -i 's|SELECTED_EDITOR="/bin/nano"|SELECTED_EDITOR="/usr/bin/vim"|' /home/pi/.selected_editor

cp /usr/share/vim/vimrc /home/pi/.vimrc

# Below sed expression stops vi from going to "visual" mode when one tries to copy text GRRRRR!
sed -i 's|"set mouse=a      " Enable mouse usage (all modes)|"set mouse=v       " Enable mouse usage (all modes)|' /home/pi/.vimrc


echo ''
echo '###### Configure "Motion" ######'
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
sed -i "s/webcontrol_authentication username:password/webcontrol_authentication $USER:$PASSWD/" /etc/motion/motion.conf


# Configure Motion to run by daemon:
# Remark the path is different to the target of foregoing sed expressions
sed -i "s/start_motion_daemon=no/start_motion_daemon=yes/" /etc/default/motion

# Set "motion" to start on boot:
systemctl enable motion.service


echo ''
echo '###### Configure Mail for Alerts ######'
echo ''
# References:
# http://msmtp.sourceforge.net/doc/msmtp.html
# https://wiki.archlinux.org/index.php/Msmtp

# MSMTP does not provide a default config file so we will create one:
cat <<EOF> /etc/msmtprc
defaults
auth           on
tls            on
tls_starttls   on
logfile        ~/.msmtp.log

# For TLS uncomment either "tls_trustfile_file" *OR* "tls_fingerprint".  NOT BOTH
# Note that "tls_trust_file" wont work with self-signed certs: use "tls_fingerprint" directive in lieu

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


cat <<EOF> /home/pi/.muttrc

set sendmail="/usr/bin/msmtp"
set use_from=yes
set realname="Alert From PiCam"
set from=$SMTPRELAYFROM
set envelope_from=yes

EOF

# Change ownership of all files created by this script FROM "root" TO user "pi":
chown -R pi:pi /home/pi


echo ''
echo '###### Expand Filesystem ######'
echo ''

# Below "raspi-config --expand-rootfs" command will be deleted from this script after it has been run once:

raspi-config --expand-rootfs& # Useful if installing Raspbian from an image smaller than your SD card capacity:
wait $!

sed -i '/raspi-config --expand-rootfs&/{N;d}' $0
# Delete the command expanding the filesystem after running it once:


echo ''
echo '###### Config /etc/motd Messages: ######'
echo ''


echo '##########################################################################' >> /etc/motd
echo '##  pi-cam-config.sh script is Beer-ware: Buy me a beer if you like it! ##' >> /etc/motd
echo '##                      paypal.me/TerrenceHoulahan                      ## ' >> /etc/motd
echo '##########################################################################' >> /etc/motd
echo '' >> /etc/motd
echo "Video Camera Status: $(echo "sudo systemctl status motion")" >> /etc/motd
echo '' >> /etc/motd
echo "Camera Address: "$(ip addr list|grep wlan0|awk '{print $2}'| cut -d '/' -f1| cut -d ':' -f2)":8080 " >> /etc/motd
echo '' >> /etc/motd
echo "Local Images Stored: $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' ) " >> /etc/motd
echo '' >> /etc/motd
echo 'To stop/start/reload the Motion daemon:' >> /etc/motd
echo 'sudo systemctl [stop|start|reload] motion' >> /etc/motd
echo '' >> /etc/motd
echo 'Video Camera Logs: /var/log/motion/motion.log' >> /etc/motd
echo '' >> /etc/motd
echo 'Instructions for Configuring Dropbox-Uploader:' >> /etc/motd
echo 'https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md' >> /etc/motd
echo '' >> /etc/motd
echo 'To edit or delete these login messages goto: /etc/motd' >> /etc/motd
echo '##########################################################################' >> /etc/motd

echo ''
echo "###### Post Config Diagnostics: ######"
echo ''
echo "Check Host Timekeeping is OK:"
systemctl status systemd-timesyncd.service&
wait $!
echo ''
echo "Open UDP/123 in Router FW if error 'Timed out waiting for reply' is reported"
echo ''
echo ''
echo "*** Dont forget to configure Dropbox-Uploader.sh ***"

systemctl reboot
