# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application, drivers and Kernel module
# Compatibility:      Tested and known to work with Raspian "Stretch" running on a Pi3+ as of 20180514
 
# Author:  Terrence Houlahan, LPIC2 Certified Linux Engineer
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20180514
 
# Beerware License: If I saved you a few hours of your life fiddling with this crap buy me a beer ;-)
#	paypal.me/TerrenceHoulahan


# SCRIPT FEATURES:
# This script does a basic setup to get your Pi Cam up and running quickly. It configures the following
# - "usbmount" to automount USB Storage
# - Downloads "Dropbox_Uploader" to enable you to shoft video/pics to the cloud
# - "Motion" Video Camera Software
# - "MSMTP" for email alerts
# - Sets Kernel driver for camera to load on boot
# - Changes default editor FROM crappy nano TO VIM

# Please note "security" isn't a feature in list! No firewall config is done to protect camera from remote snoopers!
# It's the user's responsibility to tailor their security to their local network environment.

SCRIPT PREREQUISITES:
Raspberry Pi running Raspbian with a camera attached and Internet connection.

OPTIONAL: (BUT RECOMMENDED)
- An SMTP server to relay alerts Pi will send. Most sensible SMTP servers wont talk to the rudimentary one on your Pi ;-)
- Dropbox account configured to use their API which enables getting video/pics off the Pi & safely into the Cloud:
	https://www.raspberrypi.org/magpi/dropbox-raspberry-pi/


INSTALLATION:
1. Login to Raspberry Pi to be configured as a web security camera

As user "pi" execute following commands:

2. Download the script:
	git clone git@bitbucket.org:f1linux/Pi-Cam-Config.git

3. Edit the variables in "pi-cam-config.sh"
	vi /home/pi/pi-cam-config.sh

4. Execute the script:
	sudo ./pi-cam-config.sh

