# platform = multi_platform_all
# packages = sudo

echo '#jen,!fred		ALL, !SERVERS = !/bin/sh' > /etc/sudoers
echo '# somebody ALL=/bin/ls, (!bob,alice) !/bin/cat, /bin/dog' > /etc/sudoers.d/foo
