#!/bin/bash
# packages = bind
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8


BIND_CONF='/etc/named.conf'

cat << EOF > "$BIND_CONF"
options {
	listen-on port 53 { 127.0.0.1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	/* 
	 - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
	*/
	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";

	/* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
};
EOF

