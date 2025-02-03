# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
# packages = authselect,pam

{{%- if ('rhel' in product or 'ol' in families or 'almalinux' in product) and product not in ['ol8', 'ol9', 'rhel8', 'rhel9', 'almalinux9']%}}
# rhel>=10 default profile is now called local
authselect select local --force
{{%- else %}}
authselect select minimal --force
{{%- endif %}}
