#!/bin/bash

USER="cac_user"
useradd -m $USER
mkdir -p /home/"${USER}"/.hiddenfolder
