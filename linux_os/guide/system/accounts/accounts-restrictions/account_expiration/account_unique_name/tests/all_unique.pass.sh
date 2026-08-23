#!/bin/bash

cut -d: -f1 /etc/passwd | sort | uniq -d | while read user_name
do
	userdel "$user_name"
done
