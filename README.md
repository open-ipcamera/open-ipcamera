[open-ipcamera Project](https://github.com/f1linux/open-ipcamera)
[Developer: Terrence Houlahan](https://www.linkedin.com/in/terrencehoulahan/)
Contact: terrence.houlahan@open-ipcamera.net
Version 01.68.01

NOTE: This README formatted in [Markdown language](https://guides.github.com/features/mastering-markdown/) for ease of reading on open-ipcamera's project's Github home.
Viewing it in _**vi**_ will obviously display all the underlying markups.

# README CONTENTS:
1. What is open-ipcamera?
2. LICENSE
3. HARDWARE REQUIREMENTS
4. SKILLS REQUIREMENTS
5. open-ipcamera PREQUIREMENTS
6. OPTIONAL FUNCTIONALITY
7. open-ipcamera FEATURES
8. INSTRUCTIONS: Installation & Upgrades
9. TROUBLESHOOTING
10. USEFUL LINKS


# 1. What is open-ipcamera?
---
- a collection of bash scripts that act as a wrapper to configure a comprehensive Linux _**Streaming & Motion Detection Camera System**_.
Upon a detection event it automatically uploads images to _**Dropbox**_ and emails an alert (if the user has specified an SMTP relay).

- a great tool for either learning Linux or transitioning your existing Linux skills from _**sysVinit**_ to _**SystemD**_.

_**Why use bash in lieu of a higher level programming language for open-ipcamera?:**_
- Bash is a lowest common denominator skillset for Linux-heads
- Less chance of breakage due to deprecation and headaches from different versions of dependent librairies, yada yada yada...


# 2. LICENSE: GPL Version 3
---
Copyright (C) 2018 2019 Terrence Houlahan
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, [see](https://www.gnu.org/licenses/)

Full LICENSE found [HERE](./LICENSE)


# 3. HARDWARE REQUIREMENTS:
---
open-ipcamera has been tested and known to work with the following combinations of OS & hardware, but may work with different configuration versions:
- Hardware:   Raspberry Pi 2/3B+
- OS:         Raspbian "Stretch" 9.8 (lsb_release -a)


# 4. SKILLS REQUIREMENTS:
---
You don't have to be a Linux Guru to use _**open-ipcamera**_.  It's beneficial to have functional Linux skills, but not _required_.
In fact you only need to supply values for variables in (2) files and execute the install script.  **HOWEVER** you still must
understand what values you are being asked to supply data for.  But video tutorials on using _**open-ipcamera**_ itself, GPG encryption, 
formatting storage and other skills which _**open-ipcamera**_ require knowledge of can be found [HERE](www.YouTube.com/user/LinuxEngineer)


# 5. open-ipcamera REQUIREMENTS:
---
- Raspberry Pi with a Pi-cam connected to it- the _**Pi NoIR**_recommended as it can video in low-light conditions with IR light
- keyboard, mouse & HDMI cable
- DHCP IP addressing: If the Pi can just catch an address open-ipcamera will take care of the rest of the IP details for you
- Internet connection (wired or Ethernet)
- USB flash drive formatted for EXFAT filesystem- 64GB recommended.  Used to stored video & images to avoid writes to MicroSD card
- Dropbox Account Access Token: open-ipcamera copies images from Pi's local USB storage and punts it to a Dropbox account in Cloud via Dropbox API
The token *MUST* be created & pasted into _**variables-secure.sh**_ **BEFORE** executing _**open-ipcamera-config.sh**_ for Dropbox image transfer to be configured


# 6. OPTIONAL FUNCTIONALITY:
---
1.  GPG Public Key: _**variables-secure.sh**_ contains cleartext passwords. Supply a GPG Public KeyID in _**variables.sh**_ to
have ***variables-secure.sh**_ encrypted & cleartext copy deleted
2. To receive email alerts for motion detection events an SMTP server with both an MX and PTR DNS record to relay alert emails from the Pi
Either use your own SMTP server to relay alerts or a PAID business Gmail hosted mail account.


# 7. open-ipcamera FEATURES:
---
- Automatically configures camera IPv4 & IPv6 addressing in any required config files
- Camera emails you its address so you can find the pi on a network without a local connection to it
- Enables camera in Raspbian and disables red LED activity light
- Sets Kernel driver for camera to automatically load on boot
- Installs & configs _**Motion**_ video camera package
- Installs & configs _**MSMTP**_ package for email alerts on motion detection
- Abstracts data from MicroSD card storage which hosts the OS to a USB flashdrive formatted for EXFAT
- Automounts ExFAT formatted USB Flash Drive storage on ALL 4 USB Ports and unmounts it after 5 minutes of inactivity
- Uploads camera evidence to a Dropbox account in cloud
- Sets CPU Affinity run OS process on CPUs 0-2 and the application process exclusively on CPU 3 to ensure zero contention
- SNMP V3 configured
- Heat Monitoring for user configurable thresholds: **WARN** & **SHUTDOWN**
- Changes default editor FROM nano TO standardized vim
- Sets hostname to value you specified in a variable
- Disables Autologin and sets passwords for users _**pi**_ & _**root**_
- Configs passwordless login by adding a Public Key **YOU** specify in a variable to _**~/.ssh/authorized\_keys**_ and configuring _**/etc/ssh/sshd\_config**_
- Configs an ECDSA 521 bit SSH Keypair
- Configs GPG Public Key Encryption
- Disables boot splash screen so errors can be observed as host rises-up
- Creates a graph showing the order SystemD services rise-up in to aid in troubleshooting
- Troubleshooting script automates fault analysis (to a degree) using a structured approach


# 8. INSTRUCTIONS: Installation & Upgrades
## INSTALLATION:
---
*NOTE:* Detailed  _**open-ipcamera**_ video tutorials can be found [HERE](https://www.YouTube.com/user/LinuxEngineer)
With a keyboard, mouse & HDMI cable connected your to Pi and monitor, power the Pi on and:
1. Start a terminal session
2. Execute "sudo raspi-config"
3. Enable SSH:
    "5 Interfacing Options" > "P2 SSH" > Choose "Yes" to enable SSH using your TAB key
*NOTE:* Default SSH user is "pi" with default password "raspberry"
4. Connect Pi to Internet (requires DHCP- most routers already have this configured):
- WIRED: Use Pi's Ethernet Port to connect it to a switch
	POE Users:  Suggested _**MINIMUM**_ Ethernet cable spec: *CAT6 AWG 24*
- WiFi: Click the little WiFi symbol at top RIGHT of your screen and choose a network and set a password to join it
5. Set Variables: Supply the required values in variables in (2) files:
    cd /home/pi/open-ipcamera
    nano variables.sh
    nano variables-secure.sh
*WARNING 1:* Be careful to *NOT* backspace encasing single/double quotation marks when deleting default variable values to replace them with your own
*WARNING 2:* Remember to set *UNIQUE* hostnames for each Pi
6. open-ipcamera-config.sh:  *ONLY* script required to be executed: it sources the variables & function files and calls all other _**open-ipcamera**_ scripts
    cd open-ipcamera/
    sudo ./open-ipcamera-config.sh
7. Configure firewall rules: after the open-ipcamera-config.sh completes restrict access to your camera by setting appropriate FW rules.

## UPGRADE:
---
Once _**open-ipcamera**_ is installed, future upgrades are managed by the _**open-ipcamera_upgrade.sh**_ script:

To UPGRADE your open-ipcamera installation:
    cd /home/pi/open-ipcamera-scripts/
    sudo ./open-ipcamera_upgrade.sh


# 9. TROUBLESHOOTING:
---
*BEFORE* posting an issue in the ***open-ipcamera*** Github repo, please try to self-resolve issues first by:
1. Executing _**troubleshooting-helper.sh**_ script in /home/pi/open-ipcamera-scripts directory & reviewing output to identify a fault
2. Read the _**open-ipcamera**_ Wiki
3. Check that you haven't inadvertently deleted one- or both- of single quotes encasing variables in _**open-ipcamera-config.sh**_
If so, just fix the error and re-execute _**open-ipcamera-config.sh**_ again to rebuild everything


# 10. USEFUL LINKS:
---
[Motion" Project Documentation](https://motion-project.github.io/motion_guide.html)
[Motion" Config Options](https://motion-project.github.io/motion_config.html)
[Standard PiCam vs Pi NOIR PiCam](https://pimylifeup.com/raspberry-pi-camera-vs-noir-camera/)
[Pi NoIR: What is that blue film included with the camera?](https://www.raspberrypi.org/blog/whats-that-blue-thing-doing-here/)