#!/bin/bash

# Source utils.sh, which is 2 directories above auditd_utils.sh
script_dir="$( dirname "${BASH_SOURCE[0]}" )"
. $script_dir/../../utils.sh

function prepare_auditd_test_enviroment {
        get_packages audit audispd-plugins
}
