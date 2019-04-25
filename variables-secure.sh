#!/bin/bash
# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.85.00
# "variables-secure.sh": supplies open-ipcamera-config.sh and other scripts with password data on initial install ONLY.  File is encrypted afterwards
##############  License: ##############
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
##############  Dropbox VARIABLES:Access Token  ##############
# Dropbox used to shift video and pics to cloud precluding evidence being destroyed or stolen Please consult "README.md" for how to obtain the value for below variable
# open-ipcamera configures automatic uploading of motion detection images to dropbox if you provide an access token in the below variable:
DROPBOXACCESSTOKEN='ReplaceThisStringWithYourAccessToken'
##############  USER VARIABLES: Linux  ##############
# These variables configure *LOCAL* PASSWORD access:
PASSWDPI='ChangeMe1234'
PASSWDROOT='ChangeMe1234'
# Below variable *mypubkey* configures *REMOTE* passwordLESS SSH access:
# To copy your SSH Public Key to clipboard and paste it BETWEEN single quotes in below variable:
# 	Mac Users: 	tr -d '\n' < ~/.ssh/id_rsa.pub | pbcopy
# 	Linux Users:	cat ~/.ssh/id_rsa.pub   (copy screen output and paste)
MYPUBKEY=''
##############  USER VARIABLES: Motion Detection Application  ##############
# NOTE: user for Camera application "Motion" login does not need to be a Linux system user account created with "useradd" command: can be arbitrary
USER='me'
# WARNING: Do * NOT * use the special characters ampersand * & * or forward-slash * / * in the variable * PASSWD * when creating a complex password:
# The * PASSWD * variable below is expanded inside a sed expression and these characters will be interpreted even if encased between single quotes:
# https://stackoverflow.com/questions/11307759/how-to-escape-the-ampersand-character-while-using-sed
PASSWD='ChangeMe-But-Dont-Use-Ampersands-Or-Forward-Slashes'
##############  USER VARIABLES: SNMP  ##############
# Can just leave value as "pi" for Read-Only SNMP user
SNMPV3ROUSER='pi'
# ** IMPORTANT: PLEASE READ **:
# NOTE 1: Below two variables are encased between a double and single quote. DO NOT DELETE THEM when setting a password
# NOTE 2: Additionally neither should your complex passwords for below variables incorporate single or double quote marks.  All other special characters OK to use
SNMPV3AUTHPASSWD="'PiDemo1234'"
SNMPV3ENCRYPTPASSWD="'PiDemo1234'"
##############  USER VARIABLES: MSMTP Alert Notifications  ##############
SASLUSER='yourSASLuserName'
SASLPASSWD='yourSASLpasswdGoesHere'
# GMAIL SMTP Relay Server:  This is the secondary MSMTP Relay that is configured
# NOTE 1: Requires a PAID Gmail account to *RELAY* alerts. However you can *RECEIVE* alerts on a free Gmail account.
# NOTE 2: If NOT using a Gmail SMTP Relay then just leave the example values unchanged
GMAILADDRESS='yourAcctName@gmail.com'
GMAILPASSWD='YourGmailPasswdHere'