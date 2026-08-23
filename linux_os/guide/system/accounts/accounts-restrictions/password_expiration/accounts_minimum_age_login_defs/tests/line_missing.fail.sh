#!/bin/bash

sed -i "/PASS_MIN_DAYS.*/d" {{{ login_defs_path }}}
