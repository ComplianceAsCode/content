# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora

cp="CRYPTO_POLICY='-oCiphers=aes256-ctr,aes128-ctr,aes256-cbc,aes128-cbc -oMACs=hmac-sha2-512,hmac-sha2-256 -oGSSAPIKeyExchange=no -oKexAlgorithms=ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group14-sha1 -oHostKeyAlgorithms=ssh-rsa,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256 -oPubkeyAcceptedKeyTypes=rsa-sha2-512,rsa-sha2-256,ssh-rsa,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256'"
file=/etc/crypto-policies/local.d/opensshserver-ospp.config

#blank line at the begining to ease later readibility
echo '' > "$file"
echo "$cp" >> "$file"
update-crypto-policies
