#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Acquire { http::Timeout "30"; Check-Date "false"; Retries "3"; };' >> /etc/apt/apt.conf
