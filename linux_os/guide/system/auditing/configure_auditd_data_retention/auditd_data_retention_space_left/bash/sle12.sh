# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions

divide_round_up() {
    dividend="$1"
    divisor="$2"

    # to round up instead of truncate the result, we add (divisor - 1) to the dividend
    echo $((($dividend + $divisor - 1) / $divisor))
}

partition_size=$(df -B1M --output=size /var/log/audit | awk 'NR==2 {print $1}')
# threshold is 1 quarter of the partition size
space_left=$(divide_round_up "$partition_size" 4)

replace_or_append '/etc/audit/auditd.conf' '^space_left' "$space_left" '@CCENUM@'
