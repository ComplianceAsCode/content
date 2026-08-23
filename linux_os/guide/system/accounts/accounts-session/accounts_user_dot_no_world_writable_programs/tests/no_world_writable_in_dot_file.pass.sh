#!/bin/bash

source common.sh

echo "# sudo bash $world_writable_file" >> $initialization_dot_file
echo "sudo bash $world_writable_file" >> $not_initialization_dot_file
echo "sudo bash $world_writable_file" >> $alt_non_initialization_dot_file
