#!/bin/bash

systemctl disable debug-shell.service
systemctl stop debug-shell.service
systemctl mask debug-shell.service
