#!/bin/bash
# variables = var_user_initialization_files_regex=^\.[\w\- ]+$

source common.sh

echo "$world_writable_file" >> $not_initialization_dot_file
