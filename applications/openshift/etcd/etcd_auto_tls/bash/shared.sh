# platform = multi_platform_rhel, multi_platform_ocp
#
# Include source function library
. /usr/share/scap-security-guide/remediation_functions
populate var_etcd_auto_tls

replace_or_append '/etc/etcd/etcd.conf' '^ETCD_AUTO_TLS=' $var_etcd_auto_tls '@CCENUM@' '%s=%s'
