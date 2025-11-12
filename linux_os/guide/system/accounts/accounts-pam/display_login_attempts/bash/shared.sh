# platform = multi_platform_sle,multi_platform_slmicro,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu,multi_platform_almalinux

{{%- if product in ['sle12', 'sle15', 'slmicro5'] or "ubuntu" in product %}}
{{%- set pam_lastlog_path = "/etc/pam.d/login" %}}
{{%- set pam_lastlog = "pam_lastlog.so" %}}
{{%- if "ubuntu" in product %}}
{{%- set after_match = "BOF" %}}
{{%- else %}}
{{%- set after_match = "^\s*session.*include\s+common-session$" %}}
{{%- endif %}}
{{%- elif product in ['sle16', 'slmicro6'] %}}
{{%- set pam_lastlog_path = "/etc/pam.d/postlogin-session" %}}
{{%- set pam_lastlog = "pam_lastlog2.so" %}}
{{%- else %}}
{{%- set pam_lastlog_path = "/etc/pam.d/postlogin" %}}
{{%- set pam_lastlog = "pam_lastlog.so" %}}
{{%- set after_match = "^\s*session\s+.*pam_succeed_if\.so.*" %}}
{{%- endif %}}

{{%- if "ol" in families or "slmicro" in product or "ubuntu" in product %}}
{{%- set control = "required" %}}
{{%- elif "sle" in product %}}
{{%- set control = "optional" %}}
{{%- else %}}
{{%- set control = "[default=1]" %}}
{{%- endif %}}

{{%- if pam_lastlog == "pam_lastlog.so" %}}
{{{ bash_pam_lastlog_enable_showfailed(pam_lastlog_path, control, after_match) }}}
{{%- else %}}
{{{ bash_pam_lastlog2_enable_showfailed(pam_lastlog_path, control, after_match) }}}
{{%- endif %}}
