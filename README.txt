# Author:  Terrence Houlahan
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20181214
# Version 1.05

# "pi-cam-config.sh": Installs and configs Raspberry Pi as a Motion Detection Camera which sends images to Dropbox acct and sends alerts

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
#	10.TROUBLESHOOTING
#	11.USEFUL LINKS

# 1. LICENSE: GPL version 3
# Copyright (C) 2018 Terrence Houlahan
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# 2. COMPATIBILITY: Script known to work with following configurations (but might work with others)
# - OS Version:	Raspbian "Stretch" 9.6
# - Pi Model:	3B+ and Pi Zero W
# - Cameras:	Picams 1.3 and 2.1

# 3. SCRIPT PREREQUISITES:
# - DHCP IP addressing: If camera can just catch an address it will configure the applications with the right IPv/6 addresses automatically
# - Internet connection (wired or Ethernet)
# - USB flash drive formatted for EXFAT filesystem
# - Dropbox Account Access Token: My script copies images from Pi local USB storage to a Dropbox account in Cloud via Dropbox API.
#   See "DROPBOXACCESSTOKEN" variable in "pi-cam-config.sh" for further details

# 4. OPTIONAL FUNCTIONALITY:
# -  To receive email alerts for motion detection events an SMTP server with both an MX and PTR DNS record to relay alert emails from the Pi
# -  Either use your own SMTP server to relay alerts or a PAID business Gmail hosted mail account.

# 5. SCRIPT FEATURES:
# - Automatically configures camera IP address in configuration files
# - Camera emails you its address so you can find it when connected to a HotSpot
# - Enables camera in Raspbian and disables its' red LED activity light
# - Sets Kernel driver for camera to automatically load on boot
# - Installs and configures "Motion" video camera package
# - Installs and configures "MSMTP" package for email alerts on motion detection
# - Abstracts data from MicroSD card storage which hosts the OS to a USB flashdrive formatted for EXFAT
# - Uploads camera evidence to a Dropbox account in the cloud
# - Sets CPU Affinity run OS process on CPUs 0-2 and the application process exclusively on CPU 3 to ensure zero contention
# - SNMP V3 configured
# - Heat Monitoring for user configurable thresholds: WARN and SHUTDOWN
# - Changes default editor FROM crappy nano TO standardized vim
# - Sets hostname of your specify
# - Disables Autologin and sets passwords for the users 'pi' and 'root'
# - Configures passwordless login by adding a Public Key YOU specify in a variable to "~/.ssh/authorized_keys" and configuring "/etc/ssh/sshd_config"
# - Configures an ECDSA 521 bit SSH Keypair
# - Disables boot splash screen so errors can be observed as host rises-up
# - Troubleshooting script automates fault analysis (do a degree) using a structured approach
# Note: Users must configure firewall rules either on the router in front of the camera or the camer itself to prevent unauthorized access

# 6. MINIMAL PI SETUP:
# Skip below (3) steps if already completed:
# Using a wireless or wired keyboard connected to a USB port on the Pi:
#	a. Install Raspbian OS on a MicroSD card. A short HowTo video is available at:
#		www.YouTube.com/user/LinuxEngineer
#	b. Enable SSH:
#		sudo raspi-config
#		Then choose "Interfacing Options" > "SSH" > Choose "Yes" to enable SSH
#		NOTE: "pi" users password: this will be changed in my script
#	c. Join your Pi to WiFi:
#		raspi-config
#		"Network Options" > "Wi-Fi" > Then enter SSID and password when prompted
#	NOTE: If Camera will also be used with a mobile phone HotSpot additionally configure access to this WiFi network too

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
#	a. Login to a Pi connected to the Internet:
#		NOTE: If using SSH, connect as user "pi" with default passwd "raspberry"
#			
#	b. Insert USB Flash drive into any of Pi's USB ports
#	NOTE: If Pi Zero W install script execution must either be via SSH or a local connection via a Bluetooth Keyboard.
#		The Zero W only has one Micro USB socket and this is required for image storage. Ensure Bluetooth keyboard paired before executing script

# As user "pi" - do not sudo to root- execute following commands:
#	c. Download my Git repo:
#		git clone https://f1linux@bitbucket.org/f1linux/pi-cam-config.git
#	d. Edit variables in "pi-cam-config.sh":
#  WARNING FOR NETWORKING NEOPHYTES: Set hostname variable to a unique hostname before executing script on other cameras
#		nano /home/pi/pi-cam-config/pi-cam-config.sh
#	** WARNING: Record any unique values supplied as variables- ie usernames and passwords- in a file NOT ON THE SECURITY CAMERA.
#				The final step in the script is to delete itself ensuring that no clear-text login data persists on the security camera.
#	NOTE: Replace value "ABCD1234" encased between single quotes in variable "DROPBOXACCESSTOKEN=" with Dropbox Access Token copied in Step 7:
#	e. Execute script:
#		cd /home/pi/pi-cam-config/
#		sudo ./pi-cam-config.sh
#	f. Log into your Pi-Cam at address listed at end of script's screen output "Camera Address:"
#		NOTE: Use the Login credentials that you set in the "### Variables: Motion" section of the script!

# 9. POST-SCRIPT EXECUTION Setup:
#	a. Setup firewall rules to restrict access to your Pi-Cameras to either a specific IP or subnet
#

# 10. TROUBLESHOOTING:
# Before posting issues in Bitbucket, please first:
# 	a. Review the output at the end of the script "###### Post Config Diagnostics: ######"
#	b. Read my repo's Wiki
#	c. Make a few cursory checks of the related firewall ports below if unable to access services listening on them:
#		NOTE: There's no local firewalling configured on the Pi so any blocked ports will be in front of your PI!
#		Can't connect to Pi via SSH:
#			TCP/22	 (SSH)
#		Can't connect to websites or download software via "apt-get":
#			TCP/80	 (HTTP)
#			TCP/8080 (HTTP) Pi-Cameras are accessed on this port
#			TCP/443	 (HTTPS)
#			UDP/123  (NTP)	HTTPS will break if the time is too far off on the system!
#			TCP/53	 (DNS)	Check ping tests in "###### Post Config Diagnostics: ######"
#			UDP/53	 (DNS)
#		Routing issues:
#			mtr IP Address or
#			mtr DNS Name
#	d. Check that you haven't inadvertently deleted one- or both- of the single quotes encasing variables in "pi-cam-config.sh"
#		If you have, just execute the script again to rebuild everything and fix the error

# # USEFUL LINKS:
#  "Motion" Project Documentation:	https://motion-project.github.io/motion_guide.html
#  "Motion" Config Options:         https://motion-project.github.io/motion_config.html
#  Standard PiCam vs Pi NOIR PiCam: https://pimylifeup.com/raspberry-pi-camera-vs-noir-camera/
#  Pi NoIR: https://www.raspberrypi.org/blog/whats-that-blue-thing-doing-here/
#  Pi NoIR: Infrared light modules
#  Pi NoIR: Powering infrared lights via GPIO pins:
#     https://www.sparkfun.com/news/1396
#     https://learn.adafruit.com/cloud-cam-connected-raspberry-pi-security-camera/enclosure
#     https://www.raspberrypi.org/forums/viewtopic.php?t=93350
#     https://projects.raspberrypi.org/en/projects/infrared-bird-box/6
#     https://www.makerspace.marlborougharea.org/Public%2Bprojects%2B-%2BBird%2Bbox%2Bweb%2Bcam%2Bproject
#     http://www.haydnallbutt.com.au/2009/02/18/how-to-assemble-your-own-140-led-infrared-light-source-part-2/
