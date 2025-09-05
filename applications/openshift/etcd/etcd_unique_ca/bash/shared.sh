# platform = multi_platform_ocp
#
# Include source function library
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/etcd/etcd.conf' '^ETCD_TRUSTED_CA_FILE=' '/etc/etcd/ca.crt' '@CCENUM@' '%s=%s'
