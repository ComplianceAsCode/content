# platform = multi_platform_debian

{{{ bash_package_install("aide") }}}

# Debian's aide.conf hashes files through the Checksums group (H, every
# compiled-in hash, by default); the other groups carry no hash. Hash with
# sha512 only.
{{{ bash_replace_or_append(aide_conf_path, '^Checksums', 'sha512', '%s = %s', cce_identifiers=cce_identifiers) }}}
