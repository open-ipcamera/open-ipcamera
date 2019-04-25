[open-ipcamera Project](https://github.com/open-ipcamera/open-ipcamera)\
[Developer: Terrence Houlahan](https://www.linkedin.com/in/terrencehoulahan/)\
Contact: terrence.houlahan@open-ipcamera.net
# Version 01.85.00

**NOTE:** This README formatted in [Markdown language](https://guides.github.com/features/mastering-markdown/) for ease of reading on _**open-ipcamera's**_ project's Github home.
Viewing it in a cli editor such as _**vi**_ or _**nano**_ will obviously display all the underlying markups.

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
- A collection of bash scripts that act as a wrapper to configure a Linux _**Streaming & Motion Detection Camera System**_ with cloud storage and email alerts.
- An extensible, modular framework that makes it easy to add new functionality to an open-ipcamera system
- A great tool for either learning Linux or transitioning existing Linux skills from _**sysVinit**_ to _**SystemD**_.
- Additionally _**open-ipcamera**_ offers numerous opportunities as a tool to teach IPv4/IPv6 network fundamentals using inexpensive Raspberry Pi's

_**Why use bash in lieu of a higher level programming language for open-ipcamera?:**_
- Bash is a lowest common denominator skillset for Linux-heads. Maybe some know Perl, others Python, but all _**should**_ have bash skills :wink:
- Less chance of breakage due to deprecation and headaches from different versions of dependent librairies, yada yada yada...


# 2. LICENSE: GPL Version 3
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
open-ipcamera has been tested and known to work with following combinations of OS & hardware, but may work with different configurations:
- Hardware:   Raspberry Pi 2/3B+
- OS:         Raspbian "Stretch" 9.8 (lsb_release -a)


# 4. SKILLS REQUIREMENTS:
You don't have to be a Linux Guru to use _**open-ipcamera**_.  It's beneficial to have functional Linux skills, but not _required_.
In fact you only need to supply values for variables in (2) files and execute the install script.  **HOWEVER** you still must
understand what values you are being asked to supply data for.  But video tutorials on using _**open-ipcamera**_ itself, GPG encryption,
formatting storage and other skills which _**open-ipcamera**_ require knowledge of can be found [HERE](www.YouTube.com/user/LinuxEngineer)

The install process was designed to reduce complexity, the instructions are consequently simple, but if you make an error, don't sweat it:\
Just format the MicroSD Card and make a another clean run at installing open-ipcamera.  **DON'T worry about making Errors!**


# 5. open-ipcamera REQUIREMENTS:
- Raspberry Pi with a Pi-cam connected to it- the _**Pi NoIR**_ recommended as it can video in low-light conditions with IR light
- keyboard, mouse & HDMI cable
- DHCP IP addressing: If the Pi can just catch an address open-ipcamera will take care of the rest of the IP details for you
- Internet connection (wired or Ethernet)
- USB flash drive formatted for EXFAT filesystem- 64GB recommended.  Used to stored video & images to avoid writes to MicroSD card
- Dropbox Account Access Token: open-ipcamera copies images from Pi's local USB storage and punts it to a Dropbox account in Cloud via Dropbox API
The token *MUST* be created & pasted into _**variables-secure.sh**_ **BEFORE** executing _**open-ipcamera-config.sh**_ for Dropbox image transfer to be configured


# 6. OPTIONAL FUNCTIONALITY:
1.  GPG Public Key: _**variables-secure.sh**_ contains cleartext passwords. Supply a GPG Public KeyID in _**variables.sh**_ to
have ***variables-secure.sh**_ encrypted & cleartext copy deleted
2. To receive email alerts for motion detection events an SMTP server with both an MX and PTR DNS record to relay alert emails from the Pi
Either use your own SMTP server to relay alerts or a PAID business Gmail hosted mail account.


# 7. open-ipcamera FEATURES:
- **Update in-place** functionality:  No need to uninstall/re-install when a new release is cut
- Automatically configures IPv4 & IPv6 addressing in any required config files
- Camera emails you its' address so you can locate it on a network without a local connection
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
**NOTE:** Detailed _**open-ipcamera**_ video tutorials can be found [HERE](https://www.youtube.com/channel/UCDCqFD71kgL347W6a9RwtmQ)\
With a keyboard, mouse & HDMI cable connected your to Pi and monitor, power the Pi on and:
1. *Install Time:* Longest part of Full install is downloading packages- can take 8 minutes and another 2-3 minutes for the OS upgrade at end.
2. Start a terminal session
3. Execute "sudo raspi-config"
4. Enable SSH:\
    "5 Interfacing Options" > "P2 SSH" > Choose "Yes" to enable SSH using your TAB key\
**NOTE:** Default SSH user is "pi" with default password "raspberry"
5. Connect Pi to Internet (requires DHCP- most routers already have this configured):
- WIRED: Use Pi's Ethernet Port to connect it to a switch\
	POE Users:  Suggested _**MINIMUM**_ Ethernet cable spec: **CAT6 AWG 24**
- WiFi: Click the little WiFi symbol at top RIGHT of your screen and choose a network and set a password to join it
6. Set Variables: Supply required values for variables in following (2) files:\
    `cd /home/pi/open-ipcamera`\
    `nano variables.sh`\
    `nano variables-secure.sh`\
*WARNING 1:* Be careful **NOT** to backspace encasing single/double quotation marks when deleting default variable values when replacing them with your own\
*WARNING 2:* Remember to set **UNIQUE** hostnames for each Pi
*WARNING 3:* The file **variables-secure.sh** will be encrypted at end of install if GPG key provided or deleted if not: keep copy of passwords off the Pi!
7. open-ipcamera-config.sh:  **ONLY** script required to be executed: it sources the variables & function files and calls all other _**open-ipcamera**_ scripts\
    `cd open-ipcamera/`\
    `sudo ./open-ipcamera-config.sh`
8. Configure firewall rules: after the open-ipcamera-config.sh completes restrict access to your camera by setting appropriate FW rules.

## UPGRADE:
Once _**open-ipcamera**_ is installed, subsequent upgrades are managed by the _**open-ipcamera_upgrade.sh**_ script:\

Upgrades are easier and quicker than a full install: the **variables.sh** & **variables-secure.sh** files were completed and packages downloaded.\
To UPGRADE your open-ipcamera installation:\
    `cd /home/pi/open-ipcamera-scripts/`\
    `sudo ./open-ipcamera_upgrade.sh`

Interpreting Release Numbers:\
open-ipcamera uses **Semantic Versioning**:\
    `Major/Minor/Patch`

When upgrade script is executed it downloads the latest GPG signed Git Tagged version available, prints the comments and pauses.\
If after reviewing changes you're not happy with them, just `CTRL C` to exit upgrade. Otherwise press *RETURN* to proceed with upgrade.


# 9. TROUBLESHOOTING:
*BEFORE* posting an issue in the ***open-ipcamera*** Github repo, please try to self-resolve issues first by:
1. Executing _**troubleshooting-helper.sh**_ script in /home/pi/open-ipcamera-scripts directory & reviewing output to identify a fault
2. Read the _**open-ipcamera**_ Wiki
3. Check that you haven't inadvertently deleted one- or both- of single quotes encasing variables in _**open-ipcamera-config.sh**_
If so, just resolve the fault and re-execute _**open-ipcamera-config.sh**_ again to rebuild everything


# 10. USEFUL LINKS:
[open-ipcamera Wiki](https://github.com/open-ipcamera/open-ipcamera/wiki)
["Motion" Project Documentation](https://motion-project.github.io/motion_guide.html)\
["Motion" Config Options](https://motion-project.github.io/motion_config.html)\
[Standard PiCam vs Pi NOIR PiCam](https://pimylifeup.com/raspberry-pi-camera-vs-noir-camera/)\
[Pi NoIR: What is that blue film thingy included with the Pi camera?](https://www.raspberrypi.org/blog/whats-that-blue-thing-doing-here/)
