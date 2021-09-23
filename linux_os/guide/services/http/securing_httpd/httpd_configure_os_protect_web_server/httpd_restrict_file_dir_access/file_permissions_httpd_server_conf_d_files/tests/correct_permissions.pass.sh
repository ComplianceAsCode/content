#!/bin/bash
#

{{{ bash_package_install("httpd") }}}

mkdir -p /etc/httpd/conf.d/
touch /etc/httpd/conf.d/cacfile.conf
chmod -R 0640 /etc/httpd/conf.d/
