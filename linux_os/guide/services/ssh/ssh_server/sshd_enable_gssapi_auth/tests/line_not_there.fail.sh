#!/bin/bash

sed -i "/^GSSAPIAuthentication.*/d" /etc/ssh/sshd_config
