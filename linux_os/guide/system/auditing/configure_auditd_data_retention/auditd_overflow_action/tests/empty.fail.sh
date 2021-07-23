#!/bin/bash
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh

if [[ -f $config_file ]]; then
    echo '' > $config_file
fi
