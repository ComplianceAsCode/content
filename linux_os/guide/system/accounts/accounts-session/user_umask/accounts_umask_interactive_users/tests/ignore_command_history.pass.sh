#!/bin/bash

USER="cac_user"
useradd -m $USER

# Artificially add command to history file
 echo 'umask 077' >> /home/$USER/.bash_history
