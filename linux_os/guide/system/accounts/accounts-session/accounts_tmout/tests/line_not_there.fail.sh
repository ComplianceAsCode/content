#!/bin/bash

sed -i "/^TMOUT.*/d" /etc/profile
sed -i "/^TMOUT.*/d" /etc/profile.d/*.sh
