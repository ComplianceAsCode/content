# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_almalinux

{{{ bash_package_install("aide") }}}

{{% if "ubuntu" in product or "debian" in product %}}
{{{ bash_package_install("cron") }}}
{{% else %}}
{{{ bash_package_install("cronie") }}}
{{% endif %}}

{{% if product in ["sle15", "sle16"] %}}
CRON_FILE="/etc/cron.d/dailyaidecheck"
{{% else %}}
CRON_FILE="/etc/crontab"
{{% endif %}}

if ! grep -q "{{{ aide_bin_path }}} --check" "${CRON_FILE}" ; then
    echo "05 4 * * * root {{{ aide_bin_path }}} --check" >> "${CRON_FILE}"
else
    sed -i '\!^.*{{{ aide_bin_dir }}} --check.*$!d' "${CRON_FILE}"
    echo "05 4 * * * root {{{ aide_bin_path }}} --check" >> "${CRON_FILE}"
fi
