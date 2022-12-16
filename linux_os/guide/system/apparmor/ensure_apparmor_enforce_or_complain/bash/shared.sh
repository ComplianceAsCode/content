# platform = multi_platform_ubuntu
# reboot = true
# disruption = high

{{{ bash_instantiate_variables("var_set_apparmor_mode") }}}
aa_mode=${var_set_apparmor_mode}

{{{ bash_package_install("apparmor") }}}
{{{ bash_package_install("apparmor-utils") }}}

if [ -z "${aa_mode}" ] || [ "${aa_mode}" == "complain" ]; then
    aa-complain /etc/apparmor.d/*
else
    aa-enforce /etc/apparmor.d/*
fi
