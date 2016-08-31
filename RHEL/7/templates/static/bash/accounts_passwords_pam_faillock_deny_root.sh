# platform = Red Hat Enterprise Linux 7

if [ $( grep -c "auth.*required.*pam_faillock.so.*even_deny_root" /etc/pam.d/system-auth ) -eq 0 ]; then
        BEGINNING_TXT=$( cat /etc/pam.d/system-auth | grep "auth.*required.*pam_faillock.so" | sed -e 's/[]\/$*.^|[]/\\&/g' )
	sed -i --follow-symlinks "s/$BEGINNING_TXT/$BEGINNING_TXT even_deny_root/" /etc/pam.d/system-auth
fi

if [ $( grep -c "auth.*default.*die.*pam_faillock.so.*even_deny_root" /etc/pam.d/system-auth ) -eq 0 ]; then
        BEGINNING_TXT=$( cat /etc/pam.d/system-auth | grep "auth.*default.*die.*pam_faillock.so"  | sed -e 's/[]\/$*.^|[]/\\&/g' )
	sed -i --follow-symlinks "s/$BEGINNING_TXT/$BEGINNING_TXT even_deny_root/" /etc/pam.d/system-auth
fi
