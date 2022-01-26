#!/bin/bash

die()
{
	echo "$1" >&2
	exit 1
}

if [ "$#" -ne 1 ]; then
    die "build_profiler.sh requires one argument - product_string"
fi

product_string="$1"

# Create and change to .build_profiling dir 
[ ! -d ".build_profiling" ] && (mkdir .build_profiling || die \
"Creating the .build_profiling directory failed")

cd .build_profiling || die "Changing to the .build_profiling directory failed"

# Create and change to product_string dir 
[ ! -d "$product_string" ] && (mkdir "$product_string" || die \
"Creating the $product_string directory failed")

cd "$product_string" || die "Changing to the $product_string directory failed"

# Set log_number and mode switch for python script
switch=''
if [ -f "0.ninja_log" ]; then
    # set log number to the number of the latest log file and add 1
    log_number=$(ls *.ninja_log | cut -d'.' -f1 | sort -rn | head -n 1)
    ((log_number=log_number+1))
    printf "_____\nComparing logfile $log_number to baseline 0...\n"
else
    printf "_____\nCreating new baseline 0...\n"
    log_number=0
    switch='--baseline'
fi

# create new numbered log file
mv ../../build/.ninja_log "$log_number.ninja_log" || die \
"Creating a new numbered .ninja_log file failed"

# parse and compare log files; show results to user
../../utils/build_profiler_report.py "$log_number.ninja_log" $switch
[ -f "$log_number.ninja_log.webtreemap" ] || die \
"utils/build_profiler_report.py failed to create $log_number.ninja_log.webtreemap"

# check if webtreemap command is available
[ -x "$(command -v webtreemap)" ] || die \
"The webtreemap command is not installed. Please install it using 'sudo npm i webtreemap'. To create \
the HTML from this session, use 'webtreemap -o .build_profiling/$product_string/$log_number.html \
< .build_profiling/$product_string/$log_number.ninja_log.webtreemap'"

# create HTML from .webtreemap file
webtreemap -o "$log_number.html" < "$log_number.ninja_log.webtreemap"
[ -f "$log_number.html" ] || die "utils/build_profiler.sh failed to create $log_number.html"

echo -e "-----\nSee the html buildsystem profiling visualisation here: \
.build_profiling/$product_string/$log_number.html"