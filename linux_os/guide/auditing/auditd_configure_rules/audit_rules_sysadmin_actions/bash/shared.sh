# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_debian,multi_platform_almalinux

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

{{% set watch_key = "identity" if product == "rhel10" else "actions" %}}
{{% if audit_watches_style == "modern" %}}
{{% set sudoers_d_path = "/etc/sudoers.d" if product == "rhel10" else "/etc/sudoers.d/" %}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", watch_key, "modern", "b32", "path") }}}
{{% set sudoers_d_filter = "path" if product == "rhel10" else "dir" %}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", watch_key, "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", watch_key, "modern", "b32", "path") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", watch_key, "modern", "b64", "path") }}}
{{{ bash_fix_audit_watch_rule("auditctl", sudoers_d_path, "wa", watch_key, "modern", "b32", sudoers_d_filter) }}}
{{{ bash_fix_audit_watch_rule("auditctl", sudoers_d_path, "wa", watch_key, "modern", "b64", sudoers_d_filter) }}}
{{{ bash_fix_audit_watch_rule("augenrules", sudoers_d_path, "wa", watch_key, "modern", "b32", sudoers_d_filter) }}}
{{{ bash_fix_audit_watch_rule("augenrules", sudoers_d_path, "wa", watch_key, "modern", "b64", sudoers_d_filter) }}}
{{% else %}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", watch_key) }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", watch_key) }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers.d/", "wa", watch_key) }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers.d/", "wa", watch_key) }}}
{{% endif %}}
