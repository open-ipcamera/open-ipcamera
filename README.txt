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
# 	6. PRE-INSTALL INSTRUCTIONS
#	7. CONFIGURE DROPBOX ACCESS TOKEN
# 	8. INSTALL INSTRUCTIONS


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

# 6. PRE-INSTALL INSTRUCTIONS:
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
#	a. Create a separate Dropbox account to receive images
#	b. Once logged-in to thew account, go to the URL:
#		https://www.dropbox.com/developers
#	c. Click "API Explorer" > "token/from_oauth1" > "Get Access Token"
#			Click "Allow" when prompted to dialog "Dropbox API v2 Explorer would like access to the files and folders in your Dropbox"
#	d. Copy & paste the Access Token into the variable "DROPBOXACCESSTOKEN" in "pi-cam-config.sh" script in the variables section

# 8. INSTALL INSTRUCTIONS:
#	a. Login to Pi connected to the Internet
#	b. Insert USB Flash drive into any of Pi's USB ports
#	NOTE: If Pi Zero W install script execution must either be via SSH or a local connection via a Bluetooth Keyboard.
#		The Zero W only has one Micro USB socket and this is required for image storage. Ensure Bluetooth keyboard paired before executing script

As user "pi" execute following commands- do not sudo to root!:
#	c. Download my repo:
#		git clone https://f1linux@bitbucket.org/f1linux/pi-cam-config.git
#	d. Edit variables in "pi-cam-config.sh"
#		nano /home/pi/pi-cam-config/pi-cam-config.sh
#	e. Execute script:
#		cd /home/pi/pi-cam-config/
#		sudo ./pi-cam-config.sh
