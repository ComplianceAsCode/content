#!/bin/bash

configs_dir="$( dirname "${BASH_SOURCE[0]}" )/example-configs"

setup_correct_sssd_config() {
    mkdir -p /etc/sssd
    cp "$configs_dir/sssd.conf" /etc/sssd/
}

setup_correct_auth_and_sssd_configs() {
    mkdir -p /etc/sysconfig
    cp "$configs_dir/authconfig" /etc/sysconfig/

    setup_correct_sssd_config
}
