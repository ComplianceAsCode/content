# platform = multi_platform_rhel,multi_platform_fedora
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

# include our remediation functions library
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("var_sssd_certificate_verification_digest_function") }}}

found=false
for f in /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf; do
	if [ ! -e "$f" ]; then
		continue
	fi
	cert=$( awk '/^\s*\[/{f=0} /^\s*\[sssd\]/{f=1} f{nu=gensub("^\\s*certificate_verification\\s*=\\s*ocsp_dgst\\s*=\\s*(\\w+).*","\\1",1); if($0!=nu){cert=nu}} END{print cert}' "$f" )
	if [ -n "$cert" ] ; then
		if [ "$cert" != $var_sssd_certificate_verification_digest_function ] ; then
			sed -i "s/^certificate_verification\s*=.*/certificate_verification = ocsp_dgst = $var_sssd_certificate_verification_digest_function/" "$f"
		fi
		found=true
	fi
done

if ! $found ; then
	SSSD_CONF="/etc/sssd/conf.d/certificate_verification.conf"
	mkdir -p $( dirname $SSSD_CONF )
	touch $SSSD_CONF
	chown root:root $SSSD_CONF
	chmod 600 $SSSD_CONF
	echo -e "[sssd]\ncertificate_verification = ocsp_dgst = $var_sssd_certificate_verification_digest_function" >> $SSSD_CONF
fi
