#!/bin/bash

source common.sh

useradd -m -d /var/dummy2 dummy2

touch /var/dummy2/.bash_history
chmod 0600 /var/dummy2/.bash_history
