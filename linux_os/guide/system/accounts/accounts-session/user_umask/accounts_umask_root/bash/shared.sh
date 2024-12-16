# platform = multi_platform_all

sed -i -E -e "s/^([^#]*\bumask)[[:space:]]+[[:digit:]]+/\1 0027/g" /root/.bashrc /root/.profile
