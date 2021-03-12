#!/bin/bash

touch /etc/modprobe.d/dccp.conf
sed -i '/install dccp/d' /etc/modprobe.d/dccp.conf
