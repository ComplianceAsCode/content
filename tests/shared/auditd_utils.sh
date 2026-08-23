#!/bin/bash

. $SHARED/utils.sh

function prepare_auditd_test_enviroment {
        get_packages audit audispd-plugins
}
