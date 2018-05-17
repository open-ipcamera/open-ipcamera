# "pi-cam-config.sh": Installs & configs Raspberry Pi camera application, drivers and Kernel module
# Compatibility:      Tested and known to work with Raspian "Stretch" running on a Pi3+ as of 20180514
 
# Author:  Terrence Houlahan, LPIC2 Certified Linux Engineer
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: houlahan@F1Linux.com
# Date:    20180514
 
# Beerware License: If I saved you a few hours of your life fiddling with this crap buy me a beer ;-)
#	paypal.me/TerrenceHoulahan

PREREQUISITES:
Raspberry Pi running Raspbian with a camera attached. 

OPTIONAL: (BUT HGHLY RECOMMENDED)
- An SMTP server to relay alerts the Pi will send.  Most sensible SMTP servers wont talk to the rudimentary one on your Pi ;-)
- Dropbox account configured to use their API which enables getting video/pics off the Pi & safely into the Cloud:
	https://www.raspberrypi.org/magpi/dropbox-raspberry-pi/


SCRIPT FUNCTION:
This script creates a very *GENERAL* configuration to get your Pi Cam up and running quickly.
After script executes, edit the relevant config files and tailor them to your specific use-case.


INSTALLATION:
1. Login to Raspberry Pi to be configured as a web security camera

As user "pi" execute following commands:

2. Download the script:
	git clone git@bitbucket.org:f1linux/Pi-Cam-Config.git

3. Edit the variables in "pi-cam-config.sh"
	vi /home/pi/pi-cam-config.sh

4. Execute the script:
	sudo ./pi-cam-config.sh

