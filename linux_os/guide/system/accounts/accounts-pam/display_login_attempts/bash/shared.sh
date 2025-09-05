# platform = multi_platform_sle,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu

{{%- if "sle" in product or "ubuntu" in product %}}
{{%- set pam_lastlog_path = "/etc/pam.d/login" %}}
{{%- set after_match = "^\s*session.*include\s+common-session$" %}}
{{%- else %}}
{{%- set pam_lastlog_path = "/etc/pam.d/postlogin" %}}
{{%- set after_match = "^\s*session\s+.*pam_succeed_if\.so.*" %}}
{{%- endif %}}

{{%- if "ol" in product or "ubuntu" in product %}}
{{%- set control = "required" %}}
{{%- elif "sle" in product %}}
{{%- set control = "optional" %}}
{{%- else %}}
{{%- set control = "\[default=1\]" %}}
{{%- endif %}}

{{{ bash_pam_lastlog_enable_showfailed(pam_lastlog_path, control, after_match) }}}
