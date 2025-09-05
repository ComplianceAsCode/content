#!/bin/bash
#

# find all TODO files in /usr/share/doc and get first of them
todo_file=$(find /usr/share/doc -name TODO | head -n 1)

# append space to that file, so it will change digest
echo " " >> $todo_file
