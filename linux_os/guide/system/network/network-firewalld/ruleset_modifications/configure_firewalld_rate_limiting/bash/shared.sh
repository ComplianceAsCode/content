# platform = Red Hat Enterprise Linux 7,multi_platform_wrlinux,multi_platform_ol

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -p tcp -m limit --limit 25/minute --limit-burst 100  -j INPUT_ZONES
firewall-cmd --reload
