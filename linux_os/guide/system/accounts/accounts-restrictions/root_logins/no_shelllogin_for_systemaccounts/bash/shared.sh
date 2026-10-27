# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = medium

{{% if product == "rhel9" %}}
readarray -t systemaccounts < <(awk -F: '($3 > 0 && $3 < 1000 && \
  $1 !~ /^(root|halt|sync|shutdown)$/ && \
  $7 !~ /(nologin|false)$/) \
  { print $1 }' /etc/passwd)
{{% else %}}
readarray -t systemaccounts < <(awk -F: '($3 < {{{ uid_min }}} && $1 != "root" \
  && $7 != "\/sbin\/shutdown" && $7 != "\/sbin\/halt" && $7 != "\/bin\/sync") \
  { print $1 }' /etc/passwd)
{{% endif %}}

for systemaccount in "${systemaccounts[@]}"; do
{{% if product == "rhel9" %}}
    usermod -s /usr/sbin/nologin "$systemaccount"
{{% else %}}
    usermod -s /sbin/nologin "$systemaccount"
{{% endif %}}
done
