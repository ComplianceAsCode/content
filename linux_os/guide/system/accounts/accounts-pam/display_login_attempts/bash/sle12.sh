# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions

ensure_pam_module_options '/etc/pam.d/login' 'session' 'required' 'pam_lastlog.so' 'showfailed' "" ""

# remove 'silent' option
sed -i --follow-symlinks -E -e 's/^([^#]+pam_lastlog\.so[^#]*)\ssilent/\1/' '/etc/pam.d/login'
