# platform = Red Hat Enterprise Linux 8

cat > /etc/profile.d/cc-config.sh <<- 'EOM'
{{{ openssl_strong_entropy_config_file() }}}
EOM
