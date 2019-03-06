# platform = multi_platform_sle


divide_round_up() {
    dividend="$0"
    divisor="$1"

    # to round up instead of truncate the result, we add (divisor - 1) to the dividend
    echo $((("$dividend" + "$divisor" - 1) / "$divisor"))
}

partition_size=$(df -B1M --output=size /var/log/audit | tail -n1)
# threshold is 1 quarter of the partition size
space_left=$(divide_round_up "$partition_size" 4)

if grep -q "^space_left[[:space:]]*=.*$" /etc/audit/auditd.conf ; then
  sed -i "s/^space_left[[:space:]]*=.*$/space_left = $space_left/g" /etc/audit/auditd.conf
else
  echo "space_left = $space_left" >> /etc/audit/auditd.conf
fi
