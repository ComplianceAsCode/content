# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

{{{ bash_package_install("aide") }}}

if ! grep -q "{{{ aide_bin_path }}} --check" /etc/crontab ; then
    echo "05 4 * * * root {{{ aide_bin_path }}} --check" >> /etc/crontab
else
    sed -i '\!^.*{{{ aide_bin_dir }}} --check.*$!d' /etc/crontab
    echo "05 4 * * * root {{{ aide_bin_path }}} --check" >> /etc/crontab
fi
