#!/bin/bash

sed -i '/^UMASK.*/d' {{{ login_defs_path }}}
