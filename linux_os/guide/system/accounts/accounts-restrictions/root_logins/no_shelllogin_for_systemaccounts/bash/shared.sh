# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = medium

readarray -t systemaccounts < <(awk -F: '($3 < {{{ uid_min }}} && $3 != root \
  && $7 != "\/sbin\/shutdown" && $7 != "\/sbin\/halt" && $7 != "\/bin\/sync") \
  { print $1 }' /etc/passwd)

for systemaccount in "${systemaccounts[@]}"; do
    usermod -s /sbin/nologin "$systemaccount"
done
