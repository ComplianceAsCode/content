# platform = multi_platform_ocp
#
# Include source function library
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/etcd/etcd.conf' '^ETCD_PEER_KEY_FILE=' /etc/etcd/peer.key '@CCENUM@' '%s=%s'
