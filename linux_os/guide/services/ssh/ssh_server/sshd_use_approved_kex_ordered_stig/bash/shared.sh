# platform = Red Hat Enterprise Linux 7,Oracle Linux 7

KEX_ALGOS="ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,\
diffie-hellman-group-exchange-sha256"

if grep -q -P '^\s*KexAlgorithms\s+' /etc/ssh/sshd_config; then
  sed -i "s/^\s*KexAlgorithms.*/KexAlgorithms ${KEX_ALGOS}/" /etc/ssh/sshd_config
else
  echo "KexAlgorithms ${KEX_ALGOS}" >> /etc/ssh/sshd_config
fi
