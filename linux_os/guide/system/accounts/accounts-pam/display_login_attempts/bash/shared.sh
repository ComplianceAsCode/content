# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_wrlinux

{{% if product == "rhel6" %}}
sed -i --follow-symlinks "/pam_lastlog.so/d" /etc/pam.d/system-auth
sed -i --follow-symlinks '/pam_limits.so/a session\t    required\t  pam_lastlog.so showfailed' /etc/pam.d/system-auth
{{% else %}}
sed -i --follow-symlinks "/pam_lastlog.so/d" /etc/pam.d/postlogin
echo "session     required      pam_lastlog.so showfailed" >> /etc/pam.d/postlogin
{{% endif %}}
