# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application drivers and Kernel module
# Compatibility: Raspbian :     Tested and known to work with Raspian "Stretch" running on a Pi3+ as of 20181105
# Compatibility: Cameras:		Picams 1.3 & 2.1 are known to work with this script and the driver is relies on.
 
# Author:  Terrence Houlahan
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20181105

# TABLE OF CONTENTS:
# 	1. LICENCE
# 	2. SCRIPT PREREQUISITES
# 	3. OPTIONAL
# 	4. SCRIPT FEATURES
# 	5. INSTALLATION INSTRUCTIONS


# 1. LICENSE:
# Beer-ware License: If I saved you a few hours/days of manually configuring one or more pi-cams I wouldn't say "no" if you bought me a beer ;-)
#	paypal.me/TerrenceHoulahan

# 2. SCRIPT PREREQUISITES:
# - Raspberry Pi 3 B+ running Raspbian with a Pi camera and Internet connection
# - USB flash drive formatted for EXFAT filesystem (to ensure cross compatibility of reading & storing large files on Windows & Mac)
# - Dropbox Account Access Token: Script copies images from Pi's local USB storage into cloud via Dropbox's API. See "DROPBOXACCESSTOKEN" variable in script for where to find it
#	3rd Party script that my script uses to call the Dropbox API to shift images into the cloud: https://www.raspberrypi.org/magpi/dropbox-raspberry-pi/

# 3. OPTIONAL: (BUT RECOMMENDED)
# - An SMTP server with both an MX and PTR DNS records to relay alerts the Pi sends on motion detection


# 4. SCRIPT FEATURES:
# - Enables camera in Raspbian and disables its' red LED activity light
# - Sets Kernel driver for camera to automatically load on boot
# - Installs and configures "Motion" video camera package
# - Installs and configures "MSMTP" package for email alerts on motion detection
# - Abstracts data to a USB flashdrive formatted for EXFAT from the OS on the SD card
# - Downloads "Dropbox_Uploader" for copying video & pics to cloud (Note: requires manual config)
# - Configures a SystemD Timer to upload images on USB flash drive to a DropBox account and delete the local copies
# - Changes default editor FROM crappy nano TO standardized vim
# - Sets hostname (by variable)
# - Disables AutologinSets and sets passwords for the users 'pi' and 'root'
# - Configures passwordless login by adding a specified Public Key (by variable) to "~/.ssh/authorized_keys" and configuring "/etc/ssh/sshd_config"
# - Configures an ECDSA 521 bit SSH Keypair
# - Disables boot splash screen so errors can be observed as host rises-up
# Note: Users must configure firewall rules to restrict access to the camera


# 5. INSTALLATION INSTRUCTIONS:
#	1. Login to Raspberry Pi to be configured as a web security camera
#	2. Insert a USB thumb drive into any of the Pi's USB ports.
	NOTE: If installing to a Pi Zero W that a free micro USB port is required for the storage

As user "pi" execute following commands:

#	3. Download my lovely all-singing-and-dancing script:
#		git clone git@bitbucket.org:f1linux/Pi-Cam-Config.git

#	4. Edit variables in "pi-cam-config.sh"
#		vi /home/pi/Pi-Cam-Config/pi-cam-config.sh

#	5. Execute script:
		cd /home/pi/Pi-Cam-Config/
#		sudo ./pi-cam-config.sh

