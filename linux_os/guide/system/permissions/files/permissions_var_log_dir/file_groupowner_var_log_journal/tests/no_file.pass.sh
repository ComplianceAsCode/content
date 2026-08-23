#!/bin/bash
# platform = Ubuntu 24.04

find /var/log -path "*journal*" -type f -exec rm {} \; 

