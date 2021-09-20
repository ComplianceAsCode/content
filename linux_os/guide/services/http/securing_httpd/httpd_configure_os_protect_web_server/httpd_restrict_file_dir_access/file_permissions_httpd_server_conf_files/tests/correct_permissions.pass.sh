#!/bin/bash
#

{{{ bash_package_install("httpd") }}}

mkdir -p /etc/httpd/conf/
touch /etc/httpd/conf/cacfile.conf
chmod -R 0640 /etc/httpd/conf/cacfile.conf
