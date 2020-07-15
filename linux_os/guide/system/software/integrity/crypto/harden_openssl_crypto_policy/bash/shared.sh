# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora

cp="Ciphersuites = TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"
file=/etc/crypto-policies/local.d/opensslcnf-ospp.config


echo "$cp" >> "$file"
update-crypto-policies
