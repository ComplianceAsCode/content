#!/bin/bash

USER="cac_user"
world_writable_file="/wwf.exec"
dot_file="/home/$USER/.profile"
not_dot_file="/home/$USER/.notinitfile"

useradd -m $USER

touch $world_writable_file
touch $dot_file
touch $not_dot_file

chmod o+w $world_writable_file
