cat > /etc/pam.d/system-auth-local <<'STOP_HERE'
auth        include      system-auth-ac
account     include      system-auth-ac
password    include      system-auth-ac
session     include      system-auth-ac
STOP_HERE
ln -sf /etc/pam.d/system-auth-local /etc/pam.d/system-auth
