#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Acquire { http::Timeout "30"; AllowInsecureRepositories "1"; Retries "3"; };' >> /etc/apt/apt.conf
