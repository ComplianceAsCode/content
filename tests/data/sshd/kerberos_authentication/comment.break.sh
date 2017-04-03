#!/bin/bash

sed -i 's/^KerberosAuthentication/#KerberosAuthentication/' /etc/ssh/sshd_config
