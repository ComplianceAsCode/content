#!/bin/bash

USER="cac_user"
useradd -M -r $USER
echo "simplepass" | passwd --stdin $USER
