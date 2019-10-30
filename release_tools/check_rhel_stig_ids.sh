#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_REPO_ROOT="$(cd "$SCRIPT_DIR" && cd .. && pwd)"
BUILDDIR="$CONTENT_REPO_ROOT/build"

echo Checking missing STIG IDS...
echo Building RHEL6 and RHEL7 content
ncpu=$(nproc) # This won't return number of physical core, but it shouldn't be problem
(cd "$BUILDDIR" && cmake .. && make -j $(ncpu) rhel7 rhel6) &> rhel_build.log || die "Error building RHEL7 content, check rhel_build.log file for errors"
(PYTHONPATH=.. python3 ../build-scripts/profile_tool.py stats -b ../build/ssg-rhel6-xccdf.xml --missing-stig-ids --profile stig) > rhel6-stig-ids.log
echo :: Check rhel6-stig-ids.log for rules missing STIG IDs
(PYTHONPATH=.. python3 ../build-scripts/profile_tool.py stats -b ../build/ssg-rhel7-xccdf.xml --missing-stig-ids --profile stig) > rhel7-stig-ids.log
echo :: Check rhel7-stig-ids.log for rules missing STIG IDs
