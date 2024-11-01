# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

cat > /etc/fapolicyd/rules.d/99-deny-everything.rules << EOF
{{%- if 'ol' not in families %}}
# Red Hat KCS 7003854 (https://access.redhat.com/solutions/7003854)
{{%- endif %}}
deny perm=any all : all
EOF

chmod 644 /etc/fapolicyd/rules.d/99-deny-everything.rules
chgrp fapolicyd /etc/fapolicyd/rules.d/99-deny-everything.rules

{{{ set_config_file(path="/etc/fapolicyd/fapolicyd.conf",
                    parameter="permissive",
                    value="0",
                    create=true,
                    insensitive=true,
                    separator=" = ",
                    separator_regex="\s*=\s*",
                    prefix_regex="^\s*") }}}

systemctl restart fapolicyd
