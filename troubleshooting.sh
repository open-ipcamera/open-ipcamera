#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 1.60.2

######  License: ######
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3:
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not see <https://www.gnu.org/licenses/>.


cat <<'EOF'> $PATHSCRIPTS/troubleshooting-helper.sh
#!/bin/bash
echo
echo 'To help you quickly drill-down potential causes of a fault I wrote this script which provides a structured troubleshooting approach.'
echo 'Please note these tests/tools are not exhaustive but merely a starting point to provide some baseline info to analyze.'
echo


echo '########  COMMON DEVELOPMENT ERRORS:  ########'

echo
echo 'If you broke the build hacking open-ipcamera scripts here are a few tips to help you unbreak it:'
echo
echo 'As a *GENERAL* rule begin hunting for dev errors at the point just above where the script puked its first error'
echo
echo 'A few useful git commands to investigate development changes which caused a break:'
echo
echo 'Show current UNCOMMITTED changes against last COMMITTED change to a named file:'
echo '     git diff open-ipcamera-config.sh'
echo
echo 'Show last 2 logged COMMITTED changes:'
echo '     git log -p -2'
echo
echo 'Some Common Dev Errors to Look For:'
echo '     - Ommitted closing single or double quotes encasing expressions'
echo '     - Ommitted *EOF* ending a Here-Doc or a closing *fi* on an *if* conditional expression'
echo '     - Variables not prefaced with dollar signs or being encased in single quotes which stop their expansion'
echo
echo


echo '########  CHANGE ANALYSIS:  ########'
echo
echo 'If a system previously running correctly is now in error- barring bugs or resourcing issues- likely had help getting broken'
echo 'Too frequently the cause of a fault is poorly planned/tested changes.'
echo
echo 'Check /var/log/apt/history.log for system upgrades from package/library upgrade activity:'

sudo tail -5 /var/log/apt/history.log|grep -i "Commandline"|cut -d ':' -f2

echo
echo
echo 'Any recent transformative and/or non-persistent commands found in the last 15 entries in * pi * and/or * root * bash histories?'
echo
echo '* pi * user last 15 commands issued:'

tail -15 /home/pi/.bash_history

echo
echo '* root * user last 15 commands issued:'

if [ -f /root/.bash_history ]; then
	sudo tail -15 /root/.bash_history
fi

echo
echo 'Review last logins to see who has recently worked on host:'
echo 'NOTE: Command * last * used in lieu of * lastlog * as it shows multiple logins by a single user'

last

echo
echo


echo '########  CHANGE ANALYSIS: Non-Persistent Changes  ########'

echo
echo 'Changes made to running processes in memory from the CLI and *NOT* via a configuration file read by an application on execution will be lost when host rebooted.'
echo 'Check * uptime * and see if the fault can be correlated to a reboot:'
echo

uptime

echo
echo 'Also check to see if the affected application was restarted:'
echo '     sudo systemctl applicationName.service'
echo
echo


echo '########  CHANGE ANALYSIS: Fault Occurs at Predictable Times or Intervals:  ########'
echo
echo
echo 'If fault occur at predictable times check jobs executing from SystemD Timers'
echo 'and any scripts they call:'
echo

systemctl list-timers --all

echo
echo


echo '########  HARDWARE ANALYSIS:  ########'
echo
echo 'Camera Temperature: compare temp below with 63-65C which (in my experience) is normal operating temperature (boot is 38C):'

sudo /opt/vc/bin/vcgencmd measure_temp

echo
echo
echo 'Does the OS know about the camera: Output below should report * supported=1 detected=1 *'

sudo /opt/vc/bin/vcgencmd get_camera

echo
echo
echo 'Does * lsmod * Report a value of * 1 * for * v4l2 * Camera Kernel Module:'

sudo lsmod |grep v4l2

echo
echo
echo 'Check device* * video0 * in reported below:'

sudo ls -al /dev | grep video0

echo
echo
echo 'Camera Details per * v4l2-ctl *:'

sudo /usr/bin/v4l2-ctl -V

echo
echo



echo '########  STORAGE ANALYSIS:  ########'
echo
echo 'Is system at 100 pct disk use:'
echo

df -h

echo
echo
echo 'Is USB flash storage mounting: Mount * /media/automount1 * should be reported below:'
echo

sudo cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }'

echo
echo
echo 'Review Storage Devices as a tree with * lsblk * to see what is- or is NOT- mounting:'
echo

lsblk -o model,name,fstype,size,label,mountpoint

echo
echo 'Review feedback from /var/log/daemon.log to see if any automounting errors'
echo
echo 'tail -fn 100 /var/log/daemon.log'
echo
echo


echo '########  PROCESS ANALYSIS:  ########'
echo
echo 'Check no processes hung at 100 percent:'
echo

ps --sort=-pcpu | head -n 5

echo
echo
echo 'Check key processes are up and running without error:'
echo

sudo systemctl status motion



echo '########  LOG ANALYSIS:  ########'
echo
echo 'Filter logs by priority (-p) to show ALL errors:'
echo

journalctl -p err

echo
echo 'Check application-specific logs for anything interesting:'
echo 'Motion Log:'

journalctl -u motion.service

echo

echo
echo 'Review last 10 messages sent in mail log:'
echo 'Note: All mail alerts sent are logged in the * msmtp.log *'

tail -10 /media/automount1/logs/msmtp.log

echo
echo


echo '########  NETWORKING ANALYSIS:  ########'
echo
echo 'Does host have a routable address? Check DHCP if not'
echo
echo 'IPv4 RFC 1918 Host Address:'

echo "$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"

echo
echo 'IPv6 Global Unicast Host Address:'

echo "$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

echo

echo
echo 'PORT SCANNING: WARNING'
echo

echo 'Port Scanning is testing the accessibility of a port on a * REMOTE * network.'
echo 'No need to port scan a connection between hosts inside your own firewall.'
echo
echo 'Legalities of Port Scanning: Scanning a single port to troubleshoot a connectivity issue'
echo 'will not be seen as *network abuse* by rational people. HOWEVER: Organizations can have'
echo 'automated detection processes in place to police their Acceptable Network Use policies'
echo 'which prohibit port scanning. If running a port scan from your employers network seek'
echo 'the Network Admins permission first.  Although not expressly codified as a crime in most'
echo 'jurisdictions you could still fall afoul of a employers or ISPs Acceptable Network Use policies.'
echo

echo 'With that gentle warning about Port Scanning out of the way a few commands are offered to assist'
echo 'you test the remote end of the connection for of a * SINGLE * port.'
echo
echo 'Interpreting Portscan Results:'
echo
echo '*OPEN* = CORRECT Connectivity'
echo '*FILTERED* = BROKEN Connectivity'


echo
echo 'Check if UDP/123 is open to allow Pi to update its time:'
echo 'Replace *some.ntp.server.com* with a valid ntp server address in following command and then execute it:'
echo "     nmap -sU -p 123 some.ntp.server.com|awk 'FNR==8'|awk '{print $2}'|cut -d '|' -f1"
echo

echo
echo 'Check if TCP/25 is open to allow Pi to relay mail alerts:'
echo 'Replace *some.mail.server.com* with a valid ntp server address in following command and then execute it:'
echo "     nmap -sT -p 25 some.mail.server.com|awk 'FNR==8'|awk '{print $2}'|cut -d '|' -f1"
echo
echo

echo
echo 'Check DNS by pinging Google by DNS name:'
echo

ping -c2 www.google.com

echo
echo
echo 'Ping Google by IP address:'
echo

ping -c2 8.8.8.8

echo
echo 'If pinging by *DNS Name* fails but succeeds by IP then DNS is broken or UDP/53 is blocked'
echo 'If pinging by *IP* fails check your Internet connection and/or firewall'
echo
echo
echo 'Does your gateway look sensible in below routing table:?'

route -n

echo
echo
echo 'Other tools to troubleshoot network issues that I installed during open-ipcamera-config.sh execution:'
echo
echo 'mtr tcpdump and iptraf-ng'
echo
echo


echo 'Although better to understand HOW something broke remember you have the option of just rebuilding the Pi-Cam by'
echo 're-excuting the * open-ipcamera-config.sh * script.  If this resolves the error then fault was configuration-related.'
echo
echo 'If re-executing script does *NOT* resolve error and all values supplied in * variables * section correct then'
echo 'refocus your investigations on things * IN FRONT OF * the Pi-Cam itself such as networking and firewalls.'
echo
echo
echo 'As a last resort if unable to successfully identify source of a fault there is always the Pi forums:'

echo '               https://raspberrypi.stackexchange.com/               '
echo '               https://www.raspberrypi.org/forums/               '

echo 'However you will never up your Linux game asking others to solve your problems. You have to earn your bones.'
echo
echo '     -Terrence Houlahan Linux & Network Engineer F1Linux.com'

EOF

chmod 700 $PATHSCRIPTS/troubleshooting-helper.sh
chown pi:pi $PATHSCRIPTS/troubleshooting-helper.sh


echo "Created $PATHSCRIPTS/troubleshooting-helper.sh"
echo
