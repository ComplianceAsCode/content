#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "build_profiler.sh requires one argument - product_string"
    exit 1
fi

product_string="$1"

# Create and change to .build_profiling dir 
if [ ! -d ".build_profiling" ]; then
    mkdir .build_profiling
    if [ $? -ne 0 ]; then
        >&2 echo "Creating the .build_profiling directory failed"
        exit 1
    fi
fi

cd .build_profiling
if [ $? -ne 0 ]; then
    >&2 echo "Changing to the .build_profiling directory failed"
    exit 1
fi

# Create and change to product_string dir 
if [ ! -d "$product_string" ]; then
    mkdir "$product_string"
    if [ $? -ne 0 ]; then
        >&2 echo "Creating the $product_string directory failed"
        exit 1
    fi
fi

cd "$product_string"
if [ $? -ne 0 ]; then
    >&2 echo "Changing to the $product_string directory failed"
    exit 1
fi

# Set log_number
if [ -f "0.ninja_log" ]; then
    # set log number to the number of the latest log file and add 1
    log_number=$(ls *.ninja_log | cut -d'.' -f1 | sort -rn | head -n 1)
    ((log_number=log_number+1))
    echo "-----\nComparing logfile $log_number to baseline 0..."
else
    echo "-----\nCreating new baseline 0..."
    log_number=0
fi

# create new numbered log file
mv ../../build/.ninja_log "$log_number.ninja_log"
if [ $? -ne 0 ]; then
    >&2 echo "Creating a new numbered .ninja_log file failed"
    exit 1
fi

# parse and compare log files; show results to user
../../utils/build_profiler_report.py "$log_number.ninja_log"
if [ ! -f "$log_number.ninja_log.webtreemap" ]; then
    >&2 echo "utils/build_profiler_report.py failed to create $log_number.ninja_log.webtreemap"
    exit 1
fi

# create HTML from .webtreemap file
webtreemap -o "$log_number.html" < "$log_number.ninja_log.webtreemap"
if [ ! -f "$log_number.html" ]; then
    >&2 echo "utils/build_profiler.sh failed to create $log_number.html"
    exit 1
fi
