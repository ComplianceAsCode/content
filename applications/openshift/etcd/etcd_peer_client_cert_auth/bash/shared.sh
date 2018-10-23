# platform = multi_platform_ocp
#
# Include source function library
. /usr/share/scap-security-guide/remediation_functions
populate var_etcd_peer_client_cert_auth

replace_or_append '/etc/etcd/etcd.conf' '^ETCD_PEER_CLIENT_CERT_AUTH=' $var_etcd_peer_client_cert_auth '@CCENUM@' '%s=%s'
