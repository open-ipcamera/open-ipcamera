# Author:  Terrence Houlahan
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20181105

# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application drivers and Kernel module

# README CONTENTS:
# 	1. LICENCE
#	2. COMPATIBILITY
# 	3. SCRIPT PREREQUISITES
# 	4. OPTIONAL FUNCTIONALITY
# 	5. SCRIPT FEATURES
# 	6. MINIMAL PI SETUP
#	7. CONFIGURE DROPBOX ACCESS TOKEN
# 	8. SCRIPT INSTRUCTIONS
#	9. POST-SCRIPT EXECUTION

# 1. LICENSE:
# Beer-ware License: If I saved you a few hours/days of manually configuring one or more pi-cams I wouldn't say "no" if you bought me a beer ;-)
#	paypal.me/TerrenceHoulahan

# 2. COMPATIBILITY: Script known to work with following configurations (but might work with others)
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

# 6. MINIMAL PI SETUP:
# Skip these two steps if they've already been completed:
# Using a wireless or wired keyboard connected to a USB port on the Pi:
#	a. Install the Pi's Raspbian OS on a MicroSD card (short video detailing how can be found at below URL):
#		www.YouTube.com/user/LinuxEngineer
#	b. Enable SSH:
#		sudo raspi-config
#		Then choose "Interfacing Options" > "SSH" > Choose "Yes" to enable SSH
#		NOTE: "pi" users password: this will be changed in my script
#	c. Join your Pi to WiFi:
#		raspi-config
#		"Network Options" > "Wi-Fi" > Then enter SSID and password when prompted

# 7. CONFIGURE DROPBOX ACCESS TOKEN:
# Skip this step for all subsequent Pi-Cam setups- only needs to be done just once
#	a. Create a separate Dropbox account to receive images
#	b  Verify email address before proceeding if you haven't already done so
#	c. Go to: https://www.dropbox.com/developers/apps
#		Click "Create App"
#		Choose "Dropbox API"
#		Choose "Full Dropbox-Access"
#		Name your App
#		Click "Create App" (A "Settings" page will next be displayed)
#		Click "Generate" in section "Generated access token"
#		Copy long string of characters to paste into a variable in the next step

# 8. SCRIPT INSTRUCTIONS:
#	a. Login to a Pi connected to the Internet
#	b. Insert USB Flash drive into any of Pi's USB ports
#	NOTE: If Pi Zero W install script execution must either be via SSH or a local connection via a Bluetooth Keyboard.
#		The Zero W only has one Micro USB socket and this is required for image storage. Ensure Bluetooth keyboard paired before executing script

As user "pi" - do not sudo to root- execute following commands:
#	c. Download my Git repo:
#		git clone https://f1linux@bitbucket.org/f1linux/pi-cam-config.git
#	d. Edit variables in "pi-cam-config.sh":
#		nano /home/pi/pi-cam-config/pi-cam-config.sh
#	NOTE: Replace the value ABCD1234 between the single quotes in variable "DROPBOXACCESSTOKEN=" with the Dropbox Access Token you copied in Step 7:
#	e. Execute script:
#		cd /home/pi/pi-cam-config/
#		sudo ./pi-cam-config.sh

# 9. POST-SCRIPT EXECUTION:
#	f. Execute following command and follow instructions presented to verify the Dropbox Access Token:
#		/home/pi/Dropbox-Uploader/dropbox_uploader.sh upload
#
# NOTE: Access Token only needs to be confirmed just the first time you connect 

