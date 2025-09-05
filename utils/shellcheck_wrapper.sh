#!/bin/bash

shellcheck_executable="$1"
shift
scripts_directory="$1"
shift
shellcheck_options=("$@")

scripts_count=$(ls "$scripts_directory" | wc -l)
if [ "$scripts_count" -eq 0 ]; then
    exit 0
else
    "$shellcheck_executable" "${shellcheck_options[@]}" "$scripts_directory"/*
fi
