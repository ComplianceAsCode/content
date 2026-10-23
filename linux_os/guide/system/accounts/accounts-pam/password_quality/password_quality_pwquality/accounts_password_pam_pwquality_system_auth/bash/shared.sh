# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_almalinux

{{% if product == "rhel8" %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'required', 'pam_pwquality.so', '', '', '^account.*required.*pam_permit\.so') }}}
{{% elif product == "rhel9" %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'required', 'pam_pwquality.so', '', '', '^account.*required.*pam_permit\.so') }}}
{{% elif product == "rhel10" %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'requisite', 'pam_pwquality.so', '', '', '^account.*required.*pam_permit\.so') }}}
{{% else %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'requisite', 'pam_pwquality.so', '', '', '^account.*required.*pam_permit\.so') }}}
{{% endif %}}
