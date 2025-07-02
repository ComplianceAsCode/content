#!/bin/bash

# Force unset of SYS_UID values
sed -i '/^SYS_UID_MIN/d' {{{ login_defs_path }}}
sed -i '/^SYS_UID_MAX/d' {{{ login_defs_path }}}
