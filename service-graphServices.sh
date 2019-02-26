#!/bin/bash

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Version 01.65.02

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


# The special construction with tee command used below is to facilitate expanding variable containing the version inside HereDoc
tee "$PATHSCRIPTS/boot_service_order_dependencies_graph.sh" > /dev/null <<EOF
#!/bin/bash

# The open-ipcamera Project: www.open-ipcamera.net
# Developer:  Terrence Houlahan Linux Engineer F1Linux.com
# https://www.linkedin.com/in/terrencehoulahan/
# Contact: terrence.houlahan@open-ipcamera.net
# Copyright (C) 2018 2019 Terrence Houlahan
# License: GPL 3


# When iteratively testing service dependency startup ordering we make changes to the .service unit file *Unit* directives After= and Wanted= and reboot.
# We only need to retain a few copies- 1 hours worth- of these plots for comparative purposes until we determine the correct dependent ordering:
find $PATHLOGSAPPS/ -type f -mmin +60 -name '*.svg' -execdir rm -- '{}' \;

# Create a Plot of dependent relationships between services on boot to aid in troubleshooting broken scripts and services
systemd-analyze plot > $PATHLOGSAPPS/boot_service_order_dependencies_graph_`date +%Y-%m-%d_%H-%M-%S`.svg

EOF


chmod 700 $PATHSCRIPTS/boot_service_order_dependencies_graph.sh
chown pi:pi $PATHSCRIPTS/boot_service_order_dependencies_graph.sh


cat <<EOF> /etc/systemd/system/boot_service_order_dependencies_graph.service
[Unit]
Description=Create a Plot of dependent relationships between services on boot to aid in troubleshooting broken scripts and services
After=multi-user.target

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=$PATHSCRIPTS/boot_service_order_dependencies_graph.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/boot_service_order_dependencies_graph.service

systemctl enable boot_service_order_dependencies_graph.service


echo 'To view a graph of dependent relationships on boot to troubleshoot broken scripts or services go to:'
echo "     $(tput setaf 6)$PATHLOGSAPPS/boot_service_order_dependencies_graph_Date.svg$(tput sgr 0)"
echo
