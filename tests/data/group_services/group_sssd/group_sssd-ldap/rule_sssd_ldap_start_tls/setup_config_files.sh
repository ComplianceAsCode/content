#!/bin/bash

setup_simple_correct_configs() {
    configs_dir="example-configs"

    mkdir -p /etc/sysconfig
    cp "$configs_dir/authconfig" /etc/sysconfig/

    mkdir -p /etc/sssd
    cp "$configs_dir/sssd.conf" /etc/sssd/
}
