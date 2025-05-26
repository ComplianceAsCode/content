# platform = multi_platform_ol

files_with_incorrect_hash="$(rpm -V crypto-policies)"

if [ -n "$files_with_incorrect_hash" ]; then
    {{{ pkg_manager }}} reinstall -y crypto-policies
fi
