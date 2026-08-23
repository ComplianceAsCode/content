#!/bin/bash

# make sure the file exist
touch /etc/systemd/system.conf


sed -i "/^CtrlAltDelBurstAction.*/d" /etc/systemd/system.conf
