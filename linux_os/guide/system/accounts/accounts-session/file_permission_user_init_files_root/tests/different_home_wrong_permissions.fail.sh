#!/bin/bash

# variables = var_user_initialization_files_regex=\.init

source common.sh

useradd -d /var/dummy2 dummy2

touch /var/dummy2/.init
chmod 0750 /var/dummy2/.init
