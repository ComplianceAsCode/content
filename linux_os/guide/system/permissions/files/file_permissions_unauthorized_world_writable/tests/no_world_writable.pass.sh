#!/bin/bash
#

find / -xdev -type f -perm -002 -exec chmod o-w {} \;
