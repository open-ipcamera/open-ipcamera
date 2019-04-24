#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.81.00

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


# Restore configuration to a predictable known state if a backup exists:
if [ -f /etc/motion/motion.conf.ORIGINAL ]; then
	mv /etc/motion/motion.conf.ORIGINAL /etc/motion/motion.conf
fi


# Make a backup of the default config file- once taken all subsequent tests will fail so backup not overwritten
if [ ! -f /etc/motion/motion.conf.ORIGINAL ]; then
	cp -p /etc/motion/motion.conf /etc/motion/motion.conf.ORIGINAL
fi



# Configure *MINIMAL* Settings: Lots of tweaking possible for any use-case

# *on_event_start:* First sed expression configures the Motion Detection Alerts to include the IP address in the subject of the email
# The second- commented-out - sed expression configures Motion Detection Alerts to send the HOSTNAME in Subject line of email
sed -i "s/; on_event_start value/on_event_start echo \"Subject: Motion Detected $CAMERAIPV4\" | msmtp \"$SNMPSYSCONTACT\"/" /etc/motion/motion.conf | grep on_event_start
#sed -i "s/; on_event_start value/on_event_start echo \"Subject: Motion Detected $(hostname)\" | msmtp \"$SNMPSYSCONTACT\"/" /etc/motion/motion.conf | grep on_event_start


sed -i "s/ipv6_enabled off/ipv6_enabled $IPV6ENABLED/" /etc/motion/motion.conf
sed -i "s/daemon off/daemon on/" /etc/motion/motion.conf
sed -i "s|logfile /var/log/motion/motion.log|logfile $PATHLOGSAPPS/motion.log|" /etc/motion/motion.conf
sed -i "s/log_level 6/log_level $LOGLEVEL/" /etc/motion/motion.conf
sed -i "s/rotate 0/rotate $ROTATE/" /etc/motion/motion.conf
sed -i "s/width 320/width $WIDTH/" /etc/motion/motion.conf
sed -i "s/height 240/height $HEIGHT/" /etc/motion/motion.conf
sed -i "s/framerate 2/framerate $FRAMERATE/" /etc/motion/motion.conf
sed -i "s/auto_brightness off/auto_brightness $AUTOBRIGHTNESS/" /etc/motion/motion.conf
sed -i "s/quality 75/quality $QUALITY/" /etc/motion/motion.conf
sed -i "s/ffmpeg_output_movies off/ffmpeg_output_movies $FFMPEGOUTPUTMOVIES/" /etc/motion/motion.conf
sed -i "s/max_movie_time 0/max_movie_time $MAXMOVIETIME/" /etc/motion/motion.conf
sed -i "s/ffmpeg_video_codec mpeg4/ffmpeg_video_codec $FFMPEGVIDEOCODEC/" /etc/motion/motion.conf
sed -i "s/threshold 1500/threshold $THRESHOLD/" /etc/motion/motion.conf
sed -i "s/locate_motion_mode off/locate_motion_mode $LOCATEMOTIONMODE/" /etc/motion/motion.conf
sed -i "s/locate_motion_style box/locate_motion_style $LOCATEMOTIONSTYLE/" /etc/motion/motion.conf
sed -i "s/output_pictures on/output_pictures $OUTPUTPICTURES/" /etc/motion/motion.conf
sed -i "s|target_dir /var/lib/motion|target_dir $( cat /proc/mounts | grep '/dev/sda1' | awk '{ print $2 }' )|" /etc/motion/motion.conf
sed -i "s/stream_port 8081/stream_port $STREAMPORT/" /etc/motion/motion.conf
sed -i "s/stream_quality 50/stream_quality $STREAMQUALITY/" /etc/motion/motion.conf
sed -i "s/stream_motion off/stream_motion $STREAMMOTION/" /etc/motion/motion.conf
sed -i "s/stream_localhost on/stream_localhost $STREAMLOCALHOST/" /etc/motion/motion.conf
sed -i "s/stream_auth_method 0/stream_auth_method $STREAMAUTHMETHOD/" /etc/motion/motion.conf
sed -i "s/webcontrol_localhost on/webcontrol_localhost $WEBCONTROLLOCALHOST/" /etc/motion/motion.conf
sed -i "s/webcontrol_port 8080/webcontrol_port $WEBCONTROLPORT/" /etc/motion/motion.conf


echo 'Configure Motion to execute as a daemon'
# Remark the path is different to the target of foregoing sed expressions
sed -i "s/start_motion_daemon=no/start_motion_daemon=yes/" /etc/default/motion

echo "Set motion to start on boot"
systemctl enable motion.service

echo
echo 'Further Info: https://motion-project.github.io/motion_config.html'
echo
