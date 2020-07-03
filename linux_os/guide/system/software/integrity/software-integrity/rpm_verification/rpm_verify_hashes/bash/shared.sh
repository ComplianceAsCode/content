# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

# Find which files have incorrect hash and then get files names
# --noconfig ensures that no configuration file is listed
files_with_incorrect_hash="$(rpm -Va --noconfig | grep -E '^..5' | awk '{print $NF}' )"
# From files names get package names and change newline to space, because rpm writes each package to new line
packages_to_reinstall="$(rpm -qf $files_with_incorrect_hash | tr '\n' ' ')"

{{{ pkg_manager }}} reinstall -y $packages_to_reinstall
