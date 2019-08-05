# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

# let's start with a clean slate
rm -f /etc/audit/rules.d/*

{{# in rhel7, docs dir are versioned #}
{{% if product == "rhel8" %}}
  {{% set audit_dir="audit" %}}
{{% elif product == "rhel7" %}}
  {{% set audit_dir="audit-2.8.4" %}}
{{% endif %}}

cp /usr/share/doc/{{{ audit_dir }}}/rules/10-base-config.rules /etc/audit/rules.d
cp /usr/share/doc/{{{ audit_dir }}}/rules/11-loginuid.rules /etc/audit/rules.d

{{% if product == "rhel8" %}}
cp /usr/share/doc/{{{ audit_dir }}}/rules/30-ospp-v42.rules /etc/audit/rules.d
{{% elif product == "rhel7" %}}
    #add file manually
{{% endif %}}

cp /usr/share/doc/{{{ audit_dir }}}/rules/43-module-load.rules /etc/audit/rules.d

augenrules --load
