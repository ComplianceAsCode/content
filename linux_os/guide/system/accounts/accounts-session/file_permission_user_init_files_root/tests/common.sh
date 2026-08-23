#!/bin/bash

for username in $(awk -F: '($3>={{{ uid_min }}} && $3!=65534) {print $1}' /etc/passwd)
do
    userdel -fr $username
done

touch /root/.init
chmod 0740 /root/.init

useradd -m dummy

touch /home/dummy/.init
chmod 0740 /home/dummy/.init

touch /home/dummy/.ignored_file
chmod 0777 /home/dummy/.ignored_file
