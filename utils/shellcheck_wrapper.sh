#!/bin/bash

shellcheck_executable="$1"
shift
scripts_directory="$1"
shift
shellcheck_options=("$@")

shopt -s nullglob
set -- "$scripts_directory"/*
if [ "$#" -eq 0 ]; then
    exit 0
fi
"$shellcheck_executable" "${shellcheck_options[@]}" "$@"
