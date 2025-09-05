# platform = Red Hat Enterprise Linux 8

cat > /etc/profile.d/openssl-rand.sh <<- 'EOM'
{{{ openssl_strong_entropy_config_file() }}}
EOM
