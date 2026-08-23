# platform = multi_platform_slmicro5

if ! semanage fcontext -a -t faillog_t "/var/log/tallylog"; then
    semanage fcontext -m -t faillog_t "/var/log/tallylog"
fi
restorecon -R -v "/var/log/tallylog"
