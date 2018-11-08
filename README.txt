# Author:  Terrence Houlahan
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20181105

# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application drivers and Kernel module

# README CONTENTS:
# 	1. LICENCE
#	2. Compatibility
# 	3. SCRIPT PREREQUISITES
# 	4. OPTIONAL FUNCTIONALITY
# 	5. SCRIPT FEATURES
# 	6. INSTALL INSTRUCTIONS


# 1. LICENSE:
# Beer-ware License: If I saved you a few hours/days of manually configuring one or more pi-cams I wouldn't say "no" if you bought me a beer ;-)
#	paypal.me/TerrenceHoulahan

# 2. Compatibility: Script known to work with following configurations (but might work with others)
# - OS Version:	Raspbian "Stretch"
# - Pi Model:	3B+ and Pi Zero W
# - Cameras:	Picams 1.3 and 2.1

# 3. SCRIPT PREREQUISITES:
# - Internet connection (wired or Ethernet)
# - USB flash drive formatted for EXFAT filesystem
# - Dropbox Account Access Token: My script copies images from the Pi's local USB storage into cloud via Dropbox API. See "DROPBOXACCESSTOKEN" variable in script for further info

# 4. OPTIONAL FUNCTIONALITY:
# -  To receive email alerts for motion detection events an SMTP server with both an MX and PTR DNS record to relay alert emails from the Pi

# 5. SCRIPT FEATURES:
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

# 6. INSTALL INSTRUCTIONS:
#	1. Login to Pi
#	2. Insert USB Flash drive into any of Pi's USB ports
	NOTE: If Pi Zero W install script execution must either be via SSH or a local connection via a Bluetooth Keyboard.
		The Zero W only has one Micro USB socket and this is required for image storage. Ensure Bluetooth keyboard paired before executing script

As user "pi" execute following commands- do not sudo to root!:
#	3. Download my repo:
#		git clone git@bitbucket.org:f1linux/Pi-Cam-Config.git
#	4. Edit variables in "pi-cam-config.sh"
#		vi /home/pi/Pi-Cam-Config/pi-cam-config.sh
#	5. Execute script:
		cd /home/pi/Pi-Cam-Config/
#		sudo ./pi-cam-config.sh
