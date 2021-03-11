#!/bin/bash

touch /etc/modprobe.d/sctp.conf
sed -i '/install sctp/d' /etc/modprobe.d/sctp.conf
