#!/bin/bash
#

{{{ bash_package_install("httpd") }}}

mkdir -p /etc/httpd/conf/
touch /etc/httpd/conf/cacfile.conf
chmod 0777 /etc/httpd/conf/cacfile.conf
