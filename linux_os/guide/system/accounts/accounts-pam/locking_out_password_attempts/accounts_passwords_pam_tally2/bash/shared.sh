# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

set -o pipefail

# fix the 'required' if it's wrong
if grep -q -P '^\s*auth\s+(?!required)[[:alnum:]]+\s+pam_tally2.so' < /etc/pam.d/login ; then
    sed --follow-symlinks -i -E -e 's/^(\s*auth\s+)[[:alnum:]]+(\s+pam_tally2.so)/\1required\2/' /etc/pam.d/login
fi

# fix the deny count if one exists
if grep -q -E '^\s*auth\s+required\s+pam_tally2.so(\s.+)?\s+deny=' < /etc/pam.d/login ; then
    sed --follow-symlinks -i -E -e 's/^(\s*auth\s+required\s+pam_tally2.so(?:\s.+)?\s+)deny=[^[:space:]]+/\1deny=3/' /etc/pam.d/login

fi

# add a deny count if it's missing
if grep -E '^\s*auth\s+required\s+pam_tally2.so' < /etc/pam.d/login | grep -q -E -v '\sdeny=' ; then

    sed --follow-symlinks -i -E -e 's/^(\s*auth\s+required\s+pam_tally2.so)/\1 deny=3/' /etc/pam.d/login
fi

# add a new entry if none exists
if ! grep -q -E '^\s*auth\s+required\s+pam_tally2.so(\s.+)?\s+deny=[123]' < /etc/pam.d/login ; then
    echo 'auth required pam_tally2.so deny=3' >> /etc/pam.d/login
fi
