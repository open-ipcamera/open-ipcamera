#!/bin/bash
 
# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application, drivers and Kernel module
# Compatibility:      Tested and known to work with Raspian "Stretch" running on a Pi3+ as of 20180514
 
# Author:  Terrence Houlahan, LPIC2 Certified Linux Engineer
# Contact: houlahan@F1Linux.com
# Date:    20180514
 
# Beerware License: If I saved you a few hours of your life fiddling with this crap buy me a beer
 
apt-get update&
wait $!
 
###### Configure Camera Application: "Motion" ######
# https://motion-project.github.io/motion_config.html
# https://www.bouvet.no/bouvet-deler/utbrudd/building-a-motion-activated-security-camera-with-the-raspberry-pi-zero
 
 
# https://motion-project.github.io/motion_config.html
# NOTE: "mtr" and "tcpdump" not essential- just included because they are useful thingies
apt-get install -q -y motion msmtp mutt vim git mtr tcpdump&
wait $!
 
# Nano is crap: change default editor to vi
update-alternatives --set editor /usr/bin/vim.basic
 
cp /usr/share/vim/vimrc /home/pi/.vimrc
 
# Below sed expression stops vi from going to visual mode when you are trying to copy text GRRRRRRRRRRR!
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
 
 
# "Dropbox-Uploader.sh" enables you to shift pics into cloud- ensuring evidence not destroyed with Pi Cam
# https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md
git clone https://github.com/andreafabrizi/Dropbox-Uploader.git&
wait $!
 
###### Configure Mail ######
# References:
# http://msmtp.sourceforge.net/doc/msmtp.html
# https://wiki.archlinux.org/index.php/Msmtp
# https://hostpresto.com/community/tutorials/how-to-send-email-from-the-command-line-with-msmtp-and-mutt/
 
# MSMTP does not provide a default config file so we will create one:
cat <<'EOF'> /etc/msmtprc
defaults
auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log
 
# Gmail
account     gmail
host        smtp.gmail.com
port        587
from        terrence.houlahan.dropbox@gmail.com
user        terrence.houlahan.dropbox@gmail.com
password    b^jA!9hY-:m>p5+x%{T3Di&[z?q!u5L=s@1[)2
 
# Self-Hosted Mail Account
account         houlahan.co.uk
host            mail.linuxengineer.co.uk
port            25
from            terrence@houlahan.co.uk
user=terrence
password=vTn&G5dqYk9Lj%4R3V8z&2HapP@7Ewf6!b3Mi?47>
 
account default : houlahan.co.uk
 
EOF
 
 
cat <<'EOF'> /home/pi/.muttrc 
 
set sendmail="/usr/bin/msmtp"
set use_from=yes
set realname="Alert From PiCam "
set from=terrence.houlahan.dropbox@gmail.com
set envelope_from=yes
 
EOF
 
 
 
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