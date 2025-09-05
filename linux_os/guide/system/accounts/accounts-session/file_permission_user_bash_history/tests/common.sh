#!/bin/bash

for username in $(awk -F: '($3>={{{ uid_min }}} && $3!=65534) {print $1}' /etc/passwd)
do
    userdel -fr $username
done

useradd -m dummy

touch /home/dummy/.bash_history
chmod 0600 /home/dummy/.bash_history

touch /home/dummy/.ignored_file
chmod 0777 /home/dummy/.ignored_file
