#!/bin/bash
{{% if 'ubuntu' in product or product in ['debian12', 'debian13'] %}}
# packages = avahi-daemon
{{% else %}}
# packages = avahi
{{% endif %}}
#

systemctl unmask avahi-daemon.service
systemctl unmask avahi-daemon.socket
systemctl disable avahi-daemon.service
systemctl enable avahi-daemon.socket
