#!/bin/bash

firefox_cfg="policies.json"
firefox_dirs="/usr/lib64/firefox/distribution"

# Write the prerequisite to /usr/lib64/firefox so that the remediation script uses it.
mkdir -p /usr/lib64/firefox
touch /usr/lib64/firefox/firefox-bin
for firefox_dir in ${firefox_dirs}; do
    # write our test config in every location to ensure remediation fixes it.
    mkdir -p ${firefox_dir}
(
cat <<'zzzz1234EOF'
{{{ _CORRECT_CONFIG }}}
zzzz1234EOF
) > ${firefox_dir}/${firefox_cfg}
done
