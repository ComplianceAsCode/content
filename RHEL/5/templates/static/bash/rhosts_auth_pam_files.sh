# platform = Red Hat Enterprise Linux 5
sed -i '/.*rhosts_auth.*/d' /etc/pam.d/*
