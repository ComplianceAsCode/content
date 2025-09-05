#!/bin/bash

sed -i "/^ClientAliveCountMax.*/d" /etc/ssh/sshd_config
