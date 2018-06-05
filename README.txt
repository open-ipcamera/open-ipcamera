# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application, drivers and Kernel module
# Compatibility: Raspbian :     Tested and known to work with Raspian "Stretch" running on a Pi3+ as of 20180514
# Compatibility: Cameras:		Picams 1.3 & 2.1 are know to work with this script and the driver is relies on.
 
# Author:  Terrence Houlahan, LPIC2 Certified Linux Engineer
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20180604

# TABLE OF CONTENTS:
# 	1. LICENCE
# 	2. SCRIPT PREREQUISITES
# 	3. OPTIONAL
# 	4. SCRIPT FEATURES
# 	5. INSTALLATION INSTRUCTIONS


# 1. LICENSE:
# Beer-ware License: If I saved you a few hours of your life fiddling with this crap buy me a beer ;-)
#	paypal.me/TerrenceHoulahan

# 2. SCRIPT PREREQUISITES:
# - USB thumb drive formatted for the EXFAT filesystem (allows reading media on Windows & Mac machines)
# - Raspberry Pi running Raspbian with a camera attached and Internet connection.

# 3. OPTIONAL: (BUT RECOMMENDED)
# - An SMTP server to relay alerts Pi sends on motion detection events. Most SMTP servers wont talk to others tucked which are not at a min dont have public DNS records
# - Dropbox account configured to use their API to facilitate copying video/pics on Pi into the Cloud:
#	https://www.raspberrypi.org/magpi/dropbox-raspberry-pi/
#	Dropbox isn't required, but without it if your Pi is stolen, the video of the theft of it goes with the thief ;->

# 4. SCRIPT FEATURES:
# This script does a very comprehensive configuration but you need to tailor it to your specific use-case.
# - Enables camera in Raspbian
# - Disables Camera's red LED light
# - Sets Kernel driver for camera to automatically load on every boot
# - Installs & configures "Motion" Video Camera Software
# - Installs & configures "MSMTP" for email alerts
# - Downloads "Dropbox_Uploader" to enable you to shift video/pics to the cloud (Note: you must configure this manually)
# - Abstracts data from being written to the SD card containing the OS to a USB flash drive formatted for EXFAT automagically
# - Configures a cron to upload images on the removable USB storage to your DropBox Account.
# - Configures a 2nd cron to delete media from *LOCAL* USB storage older than 1 hour to stop Motion from filling up storage to 100%
# - Sends Motion Detection Alerts with Pi's hostname sending the alert in the email's Subject Line
# - Changes default editor FROM evil nano TO lovely VIM !
# - Sets hostname
# - Sets passwords for users 'pi' and 'root' with variables
# - Configures an ECDSA 521 bit SSH Keypair
# - Adds your Public key to ~/.ssh/authorrized_keys
# - Configures /etc/ssh/sshd_config for public key access
# - Disables Autologin
# - Disables boot Splash Screen so errors can be observed as host rises-up

# Please note "security" isn't a feature in list! No firewall config is done to protect the Pi camera from remote snoopers!
# It's the *USER'S* responsibility to tailor their security to their local network environment.


# 5. INSTALLATION INSTRUCTIONS:
#	1. Login to Raspberry Pi to be configured as a web security camera
#	2. Insert a USB thumb drive into any of the Pi's USB ports.
	NOTE: If installing to a Pi Zero you'll need to keep that micro USB port free for the USB storage if you have anything in it!

As user "pi" execute following commands:

#	3. Download my lovely all-singing-and-dancing script:
#		git clone git@bitbucket.org:f1linux/Pi-Cam-Config.git

#	4. Edit the variables in "pi-cam-config.sh"
#		vi /home/pi/pi-cam-config.sh

#	5. Execute the script:
#		sudo ./pi-cam-config.sh

