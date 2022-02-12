#!/bin/bash

FIREFOX_PARAM={{{ PARAMETER }}}

firefox_cfg="mozilla.cfg"
firefox_dirs="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"

# Iterate over the possible Firefox install directories
for firefox_dir in ${firefox_dirs}; do
    # write our bad config in every location to ensure remediation fixes it.
    mkdir -p ${firefox_dir}
    touch ${firefox_dir}/${firefox_cfg}

    # delete the parameter if it's present.
    if LC_ALL=C grep -q "^lockPref(\"${FIREFOX_PARAM}\"" $1; then
        sed "/^lockPref(\"${FIREFOX_PARAM}\"/Id" $1
    fi
done
