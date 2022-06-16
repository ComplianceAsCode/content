#!/bin/bash

source common.sh

echo "# sudo bash $world_writable_file" >> $dot_file
echo "sudo bash $world_writable_file" >> $not_dot_file
