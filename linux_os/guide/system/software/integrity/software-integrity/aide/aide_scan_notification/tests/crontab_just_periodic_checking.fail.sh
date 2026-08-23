#!/bin/bash
# packages = aide,crontabs

# configured in crontab
echo '0 5 * * * root {{{ aide_bin_path }}}  --check' >> /etc/crontab
