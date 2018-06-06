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
# Variables are expanded in sed expressions and auto-populating variables.
# Change or delete specimen values below as appropriate:

### Variables: Linux
#OURHOSTNAME='raspberrypizerow1'
OURHOSTNAME='raspberrypi3-3'
PASSWDPI='Tbh11b2pc'
PASSWDROOT='Tbh11b2pc'

MYPUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/4ujZFHJrXgAracA7eva06dz6XIz75tKei8UPZ0/TMCb8z01TD7OvkhPGMA1nqXv8/ST7OqG22C2Cldknx+1dw5Oz8FNekHEJVmuzVGT2HYvcmqr4QrbloaVfx2KyxdChfr9fMyE1fmxRlxh1ZDIZoD/WrdGlHZvWaMYuyCyqFnLdxEF/ZVGbh1l1iYRV9Et1FhtvIUyeRb5ObfJq09x+OlwnPdS21xJpDKezDKY1y7aQEF+D/EhGk/UzA91axpVVM9ToakupbDk+AFtmrwIO7PELxHsN1TtA91e2dKOps3SmcVDluDoUYjO33ozNGDoLj08I0FJMNOClyFxMmjUGssA4YIdiYIx3+uae3Bjnu4qpwyREPxxiWZwt20vzO6pvyxqhjcU49gmAgp1pOgBXkkkpu/CHiDFGAJW06nk1QgK9NwkNKL2Tbqy30HY4K/px1OkgaDyvXIRvz72HRR+WZIfGHMW8RLa7ceoUU4dXObqgUie0FGAU23b2m2HTjYSyj2wAAFp5ONkp9F6V2yeeW1hyRvEwQnX7ov95NzIMvtvYvn5SIX7GVIy+/8TlLpChMCgBJ4DV13SVWwa5E42HnKILoDKTZ3AG0ILMRQsJdv49b8ulwTmvtEmHZVRt7mEVF8ZpVns68IH3zYWIDJioSoKWpj7JZGNUUPo79PS+wQ== terrence@Terrence-MBP.local'

### Variables: Motion
# NOTE: "motion.conf" has many more adjustable parameters than those below, which are a subset of just very useful or required ones:
IPV6ENABLED='on'
USER='terrence'
PASSWD='xF9e4Ld'

# Max VIDEO Resolution PiCam v2: 1080p30, 720p60, 640x480p90
# Max IMAGE Resolution PiCam v2: 3280 x 2464
WIDTH='1640'
HEIGHT='1232'
FRAMERATE='1'
# Autobrightness can cause wild fluctuations causing it PiCam to register each change as a motion detection creating a gazillion images. Suggested value= "off"
AUTOBRIGHTNESS='off'
QUALITY='65'
FFMPEGOUTPUTMOVIES='on'
MAXMOVIETIME='60'
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
SASLPASSWD='xUn&G5d4RqYk9Lj%4R3D2V8z&2HapP@7EywfG6!b3Mi?B7'
SMTPRELAYFQDN='mail.linuxengineer.co.uk'
SMTPRELAYFROM='terrence@houlahan.co.uk'

# GMAIL SMTP Relay Server:  NOTE: Requires a PAID Google-hosted mail account
GMAILADDRESS='terrence.houlahan.devices@gmail.com'
GMAILPASSWD='ABCD1234'

#### Dropbox-Uploader Variables:

# Dropbox can be used to shift video and pics to the cloud to prevent evidence being destroyed or stolen
# Click "Generate" button under the heading "Generated access token" in the "Developer section of your Dropbox account
DROPBOXACCESSTOKEN='ABCD1234'


# USEFUL RESOURCES:
# https://pimylifeup.com/raspberry-pi-camera-vs-noir-camera/
# https://projects.raspberrypi.org/en/projects/getting-started-with-picamera/5

#############################################################
#                                                           #
# ONLY EDIT BELOW THIS LINE IF YOU KNOW WHAT YOU ARE DOING! #
#                                                           #
#############################################################

echo ''
echo ''
echo '###### DELETE DETRITUS FROM PRIOR INSTALLS ######'
echo ''
echo '### Restore Pi to a predictable known configuration state by deleting debris from prior installs:'
echo ''

# Delete "motion and any related config files for using "apt-get purge" :
if [[ ! $(dpkg -l | grep motion) = '' ]]; then
	apt-get purge -q -y motion&
	wait $!
fi

# Delete the pub key or every time we run the key it will just continue to append a new copy of the key:
if [ -f /home/pi/.ssh/authorized_keys ]; then
sed -i "\|$MYPUBKEY|d" /home/pi/.ssh/authorized_keys
fi

if [ -f /etc/systemd/system/media-pi.automount ]; then
	rm /etc/systemd/system/media-pi.automount
fi

if [ -f /etc/systemd/system/media-pi.mount ]; then
	rm /etc/systemd/system/media-pi.mount
fi

if [ -f /home/pi/scripts/housekeeping.sh ]; then
	rm /home/pi/scripts/housekeeping.sh
fi

# This is NOT part of the Dropbox-uploader script- it just uses it:
if [ -d /home/pi/scripts/Dropbox-Uploader ]; then
	rm -r /home/pi/scripts/Dropbox-Uploader
fi

if [ -f /var/spool/cron/crontabs/pi ]; then
	sed -i '/.*Dropbox-Uploader.sh/d' /var/spool/cron/crontabs/pi
	sed -i '/.*housekeeping.sh/d' /var/spool/cron/crontabs/pi
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
echo '###### Configure A Minimum Security baseline:  ######'
echo ''

# By default no passwords set for users 'pi' and 'root'
echo "*** Set passwd for user 'pi' ***"
echo "pi:$PASSWDPI"|chpasswd

echo "*** Set passwd for user 'root' ***"
echo "root:$PASSWDROOT"|chpasswd

# Only create the SSH keys and furniture if an .ssh folder does not already exist for user pi:
if [ ! -d /home/pi/.ssh ]; then
	mkdir /home/pi/.ssh
	touch /home/pi/.ssh/authorized_keys

	# https://www.ssh.com/ssh/keygen/
	sudo -u pi ssh-keygen -t ecdsa -b 521 -f /home/pi/.ssh/id_ecdsa -q -P ''&
	wait $!

	chmod 700 /home/pi/.ssh
	chmod 600 /home/pi/.ssh/id_rsa
	chmod 644 /home/pi/.ssh/id_rsa.pub
	chown -R /home/pi/

	echo "ECDSA 521 bit keypair created for user pi"
fi

echo ''
echo "$MYPUBKEY" >> /home/pi/.ssh/authorized_keys
echo "Added Your Public Key to 'authorized_keys' file"
echo ''

# There are more options that could be tweaked or course in /etc/ssh/sshd_config
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
sed -i "s|PrintMotd no|PrintMotd yes|" /etc/ssh/sshd_config
sed -i "s|#PrintLastLog yes|PrintLastLog yes|" /etc/ssh/sshd_config
sed -i "s|#TCPKeepAlive yes|TCPKeepAlive yes|" /etc/ssh/sshd_config


echo ''
echo '###### Configure LOCAL Storage ######'
echo ''

# Interesting thread on auto mounting choices:
# https://unix.stackexchange.com/questions/374103/systemd-automount-vs-autofs

apt-get update&
wait $!


if [[ ! $(dpkg -l | grep usbmount) = '' ]]; then
apt-get purge -q -y usbmount&
wait $!
fi


# We want EXFAT because it supports large file sizes and can read be read on Macs and Windows machines:
if [[ $(dpkg -l | grep exfat-fuse) = '' ]]; then
apt-get install -q -y exfat-fuse&
wait $!
fi

# Disable automounting by the default Filemanager "pcmanfm": it steps on the systemd automount which gives us the flexibility to change mount options:
if [ -f /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf ]; then
	sed -i 's/mount_removable=1/mount_removable=0/' /home/pi/.config/pcmanfm/LXDE-pi/pcmanfm.conf
fi


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


# Filename below should match mount point path in "Where":
cat <<EOF> /etc/systemd/system/media-pi.mount
[Unit]
Description=Automount USBstorage
#Before=

[Mount]
What=/dev/sda1
Where=/media/pi
Type=exfat
Options=defaults

[Install]
WantedBy=multi-user.target

EOF


systemctl daemon-reload&
wait $!
systemctl start media-pi.mount&
wait $!


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

systemctl enable media-pi.mount

if [ ! -d /home/pi/scripts ]; then
mkdir -p /home/pi/scripts
fi

# Housekeeping: Prune images after being copied off the device to Dropbox:
cat <<'EOF'> /home/pi/scripts/housekeeping.sh
#!/bin/bash

# Test for valid Internet connection before deleting local images older than 8 minutes ensuring they were shifted to cloud before deletion:
ping -c 1 8.8.8.8
if [ $? -eq 0 ]; then
rm $(find $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' ) -type f -mmin +8 2>/dev/null)
fi

EOF

chmod 700 /home/pi/scripts/housekeeping.sh

# Create crontab entry in user "pi" crontab to schedule deleting local files:
cat <<'EOF'> /var/spool/cron/crontabs/pi
*/8 * * * * /home/pi/scripts/housekeeping.sh

EOF


###### BEGIN INSTALLATION ######

echo ''
echo '###### Configure Sensible Defaults: ######'
echo ''

# raspian-config: How to interface from the CLI:
# https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup

# We first clear any boot param added during a previous build and then we add each parameter back with the most current value set:
# Enable the camera (there is no raspi-config option to do this):
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

# Disable the splash screen to stop it hiding errors as the Pi rises up on boot:
sed -i '/disable_splash=1/d' /boot/config.txt
echo 'disable_splash=1' >> /boot/config.txt

echo 'Disabled boot splash screen so we can see errors while host is rising up.'

systemctl disable autologin@.service&
wait $!
echo 'Disabled autologin.'


echo ''
echo '###### Set New Hostname: ######'
echo ''

hostnamectl set-hostname $OURHOSTNAME
systemctl restart systemd-hostnamed&
wait $!

# hostnamectl does NOT update its own entry in /etc/hosts so have to do it separately:
sed -i "s/127\.0\.1\.1.*/127\.0\.0\.1      $OURHOSTNAME/" /etc/hosts


echo ''
echo '###### Install Software ######'
echo ''


if [[ $(dpkg -l | grep motion) = '' ]]; then
apt-get install -q -y motion&
wait $!
fi


# 'libimage-exiftool-perl' used to get metadata from videos and images from the CLI. Top-notch tool
# http://owl.phy.queensu.ca/~phil/exiftool/
if [[ $(dpkg -l | grep libimage-exiftool-perl) = '' ]]; then
apt-get install -q -y libimage-exiftool-perl&
wait $!
fi


# 'exiv2' is another tool for obtaining and changing media metadata but has limited support for video files- wont handle mp4- compared to 'libimage-exiftool-perl'
# http://www.exiv2.org/
if [[ $(dpkg -l | grep exiv2) = '' ]]; then
apt-get install -q -y exiv2&
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

# vim-tiny- which is crap like nano- will also match unless grep-ed with boundaries:
if [[ $(dpkg -l | grep -w '\Wvim\W') = '' ]]; then
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
echo '###### Configure Cloud Storage ######'
echo ''
echo "https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md"
echo ''

# "Dropbox-Uploader.sh" enables you to copy images to cloud- ensuring evidence not lost if PiCam destroyed or stolen
echo ''

if [ ! -d /home/pi/Dropbox-Uploader ]; then
	git clone https://github.com/andreafabrizi/Dropbox-Uploader.git&
	wait $!
fi


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

modprobe bcm2835-v4l2


echo ''
echo '###### Configure Default Editor ######'
echo ''


# Nano is a piece of crap: change default editor to something more sensible
update-alternatives --set editor /usr/bin/vim.basic

if [ -f /home/pi/.selected_editor ]; then
	sed -i 's|SELECTED_EDITOR="/bin/nano"|SELECTED_EDITOR="/usr/bin/vim"|' /home/pi/.selected_editor
fi

cp /usr/share/vim/vimrc /home/pi/.vimrc

# Below sed expression stops vi from going to "visual" mode when one tries to copy text GRRRRR!
sed -i 's|"set mouse=a      " Enable mouse usage (all modes)|"set mouse=v       " Enable mouse usage (all modes)|' /home/pi/.vimrc


echo ''
echo '###### Configure Camera Application Motion ######'
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
echo '###### Configure Mail for Alerts ######'
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
echo 'Instructions for Configuring Dropbox-Uploader:' >> /etc/motd
echo 'https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md' >> /etc/motd
echo '' >> /etc/motd
echo 'To edit or delete these login messages goto: /etc/motd' >> /etc/motd
echo '' >> /etc/motd
echo '##########################################################################' >> /etc/motd

echo ''
echo "###### Post Config Diagnostics: ######"
echo ''
echo "Output of command 'vcgencmd get_camera' below should report: supported=1 detected=1"
echo '------------------------------------------------------------------------'
vcgencmd get_camera
echo ''
echo 'Value below for camera driver bcm2835_v4l2 should report value of 1 (camera driver loaded). If not your camera will be down:'
echo '------------------------------------------------------------------------'
lsmod |grep v4l2
echo''
echo "Device 'video0' should be shown below. If not your camera will be down:"
echo '------------------------------------------------------------------------'
ls -al /dev | grep video0
echo''
echo "Check Host Timekeeping both correct and automated:"
echo '------------------------------------------------------------------------'
systemctl status systemd-timesyncd.service&
wait $!
echo ''
echo "Open UDP/123 in Router FW if error 'Timed out waiting for reply' is reported"
echo ''
echo ''
echo "*** Dont forget to configure Dropbox-Uploader.sh ***"
echo ''
echo 'Dont forget to delete this script after done iterating through different installs: it contains passwords so wipe it after you are done!'
echo ''


systemctl reboot
