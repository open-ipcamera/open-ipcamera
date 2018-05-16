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
# Change or delete specimen values below as appropriate:

### Auth Variables for SMTP to Send Alerts:
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



###### DELETE DETRITUS FROM PRIOR INSTALLS ######

### Delete any files which this script created and/or configured from previous install to ensure host in predictable state:

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


# Blow-away any config files for "Motion" using "apt-get purge" :
if [ ! $(command -v motion) = '' ]; then
apt-get purge -q -y motion&
wait $!
fi



###### BEGIN INSTALLATION ######

### Install our Applications

apt-get update&
wait $!
 
echo '###### Configure Camera Application "Motion" ######'
# https://motion-project.github.io/motion_config.html
# https://www.bouvet.no/bouvet-deler/utbrudd/building-a-motion-activated-security-camera-with-the-raspberry-pi-zero

# If "command -v application" returns nothing install the it: 
if [ $(command -v motion) = '' ]; then
apt-get install -q -y motion&
wait $!
fi

if [ $(command -v msmtp) = '' ]; then
apt-get install -q -y msmtp&
wait $!
fi

if [ $(command -v mutt) = '' ]; then
apt-get install -q -y mutt&
wait $!
fi

if [ $(command -v vim) = '' ]; then
apt-get install -q -y vim&
wait $!
fi

if [ $(command -v git) = '' ]; then
apt-get install -q -y git&
wait $!
fi

# NOTE: following are not required but just included because they are useful
if [ $(command -v mtr) = '' ]; then
apt-get install -q -y mtr&
wait $!
fi

if [ $(command -v tcpdump) = '' ]; then
apt-get install -q -y tcpdump&
wait $!
fi

 
# Nano is a piece of crap: change default editor to something sensible
update-alternatives --set editor /usr/bin/vim.basic

cp /usr/share/vim/vimrc /home/pi/.vimrc

# Below sed expression stops vi from going to "visual" mode when one tries to copy text GRRRRR!
sed -i 's|"set mouse=a      " Enable mouse usage (all modes)|"set mouse=v       " Enable mouse usage (all modes)|' /home/pi/.vimrc
 
# Set "motion" to start on boot:
systemctl enable motion
 
# Load Kernel module for Pi camera on boot:
cat <<'EOF'> /etc/modules-load.d/bcm2835-v4l2.conf
bcm2835-v4l2
 
EOF
 
# Configure *BASIC* Settings (just enough to get things generally working):
sed -i "s/daemon off/daemon on/" /etc/motion/motion.conf
sed -i "s/width 320/width 640/" /etc/motion/motion.conf
sed -i "s/height 240/height 480/" /etc/motion/motion.conf
sed -i "s/framerate 2/framerate 4/" /etc/motion/motion.conf
sed -i "s/; mmalcam_name vc.ril.camera/mmalcam_name vc.ril.camera/" /etc/motion/motion.conf
sed -i "s/ffmpeg_output_movies off/ffmpeg_output_movies on/" /etc/motion/motion.conf
sed -i "s/target_dir \/var\/lib\/motion/target_dir \/home\/pi\/Video/" /etc/motion/motion.conf
sed -i "s/stream_localhost on/stream_localhost off/" /etc/motion/motion.conf
sed -i "s/webcontrol_localhost on/webcontrol_localhost off/" /etc/motion/motion.conf
sed -i "s/webcontrol_port 8080/webcontrol_port 8080/" /etc/motion/motion.conf
sed -i "s/webcontrol_authentication username:password/webcontrol_authentication me: 2468aBcXyX/" /etc/motion/motion.conf
 
# Configure Motion to run by daemon:
# Remark the path is different to the target of foregoing sed expressions
sed -i "s/start_motion_daemon=no/start_motion_daemon=yes/" /etc/default/motion
 
 
echo '###### Configure Mail for Alerts ######'
# References:
# http://msmtp.sourceforge.net/doc/msmtp.html
# https://wiki.archlinux.org/index.php/Msmtp
# https://hostpresto.com/community/tutorials/how-to-send-email-from-the-command-line-with-msmtp-and-mutt/


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
set realname="Alert From PiCam "
set from=$SMTPRELAYFROM
set envelope_from=yes
 
EOF
 
echo '###### Install "Dropbox_Uploader" for Cloud Storage ######'

# "Dropbox-Uploader.sh" enables you to shift pics into cloud- ensuring evidence not destroyed with Pi Cam
# https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md
git clone https://github.com/andreafabrizi/Dropbox-Uploader.git&
wait $!

 
echo "###### Post Config Diagnostics: ######"
echo ''
echo "Check Host Timekeeping is OK:"
systemctl status systemd-timesyncd.service
echo ''
echo "Open UDP/123 in Router FW if error 'Timed out waiting for reply' is reported"
echo ''
echo ''
echo "After host reboots in 15 seconds check all is correct."
echo "In a browser open: "$(ip addr list|grep wlan0|awk '{print $2}'| cut -d '/' -f1| cut -d ':' -f2)":8081 "
echo ''
echo "*** Dont forget to configure Dropbox-Uploader.sh ***"
 
sleep 15
 
systemctl reboot