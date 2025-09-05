#!/bin/bash

source common.sh

subdir="/home/$USER/Documents/deep-down"

mkdir -p "$subdir"

echo "$world_writable_file" >> "$subdir"/.bashrc
