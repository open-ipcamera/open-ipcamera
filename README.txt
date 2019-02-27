# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.65.04

# "open-ipcamera-config.sh" installs & configs Raspberry Pi as a Motion Detection Camera,
#  and upon a detection event uploads images to Dropbox and emails an alert

# README CONTENTS:
# 	1. LICENCE
#	2. HARDWARE COMPATIBILITY
# 	3. SCRIPT PREREQUISITES
# 	4. OPTIONAL FUNCTIONALITY
# 	5. KEY SCRIPT FEATURES
# 	6. SCRIPT INSTRUCTIONS
#	7. TROUBLESHOOTING
#	8. USEFUL LINKS

# 1. LICENSE: GPL version 3
# Copyright (C) 2018 2019 Terrence Houlahan
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

# 2. HARDWARE COMPATIBILITY:
# - Refer to header in "open-ipcamera-config.sh" for hardware and OS version compatibility details

# 3. SCRIPT PREREQUISITES:
# - DHCP IP addressing: If camera can just catch an address it will configure applications with the right IPv/6 addresses automatically
# - Internet connection (wired or Ethernet)
# - USB flash drive formatted for EXFAT filesystem.  This is used to stored video and images on to avoid write to MicroSD card
# - Dropbox Account Access Token: My script copies images from Pi local USB storage to a Dropbox account in Cloud via Dropbox API.
#   The token needs to be created before executing "open-ipcamera-config.sh" as it must be pasted inside a variable in the script.

# 4. OPTIONAL FUNCTIONALITY:
# -  To receive email alerts for motion detection events an SMTP server with both an MX and PTR DNS record to relay alert emails from the Pi
# -  Either use your own SMTP server to relay alerts or a PAID business Gmail hosted mail account.

# 5. KEY SCRIPT FEATURES:
# - Automatically configures camera IPv4 & IPv6 addressing in any required config files
# - Camera emails you its address so you can find the pi on a network without a local connection to it
# - Enables camera in Raspbian and disables red LED activity light
# - Sets Kernel driver for camera to automatically load on boot
# - Installs and configs "Motion" video camera package
# - Installs and configs "MSMTP" package for email alerts on motion detection
# - Abstracts data from MicroSD card storage which hosts the OS to a USB flashdrive formatted for EXFAT
# - Automounts ExFAT formatted USB Flash Drive storage on ALL 4 USB Ports and unmounts it after 5 minutes of inactivity
# - Uploads camera evidence to a Dropbox account in cloud
# - Sets CPU Affinity run OS process on CPUs 0-2 and the application process exclusively on CPU 3 to ensure zero contention
# - SNMP V3 configured
# - Heat Monitoring for user configurable thresholds: WARN and SHUTDOWN
# - Changes default editor FROM crappy nano TO standardized vim
# - Sets hostname of your specify
# - Disables Autologin and sets passwords for the users 'pi' and 'root'
# - Configs passwordless login by adding a Public Key YOU specify in a variable to "~/.ssh/authorized_keys" and configuring "/etc/ssh/sshd_config"
# - Configs an ECDSA 521 bit SSH Keypair
# - Disables boot splash screen so errors can be observed as host rises-up
# - Creates a graph showing the order SystemD services rise-up in to aid in troubleshooting
# - Troubleshooting script automates fault analysis (to a degree) using a structured approach
# Note: Users must configure firewall rules either on the router in front of the camera or the camera itself to restrict access

# 6. SCRIPT INSTRUCTIONS:
#	With a keyboard, mouse & HDMI cable connected your to Pi and monitor, power Pi on and next:
#	a. Start a terminal session
#	b. Execute "sudo raspi-config"
#	c. Enable SSH:
#   		"5 Interfacing Options" > "P2 SSH" > Choose "Yes" to enable SSH using your TAB key
#      NOTE: Default SSH user is "pi" with default passwd is "raspberry"
#	d. Connect Pi to Internet (requires DHCP to be enabled on your network) either Wired or Wirelessly:
#		1. WIRED: Plug a cable from a switch
#		2. WiFi: Click the little WiFi symbol at top RIGHT of your screen and choose a network and set a password to join it
#	e. variables.sh: Populate the variables files with your data:
#			cd /home/pi/open-ipcamera
#			nano variables.sh
#			nano variables-secure.sh
#	f. open-ipcamera-config.sh:  This is the main install script which read the variables file and calls all the other scripts in the directory
#	   Execute it as below:
#			sudo ./open-ipcamera-config.sh
#	Detailed "open-ipcamera" video instructions can be viewed at:
#			www.YouTube.com/user/LinuxEngineer
#	g. And do not forget to configure firewall rules after the open-ipcamera install completes to restrict access to your camera

# 8. TROUBLESHOOTING:
# Before posting issues in the "open-ipcamera" Github repo, please try to self-resolve issues first by:
#	a. Executing the "troubleshooting-helper.sh" script in the pi user scripts directory and reviewing the output to identify a fault
#	b. Read the "open-ipcamera" Wiki
#	c. Check that you haven't inadvertently deleted one- or both- of the single quotes encasing variables in "open-ipcamera-config.sh"
#		If so, just re-execute the script again to rebuild everything and it should resolve the problem

# 9. USEFUL LINKS:
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
