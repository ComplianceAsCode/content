#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu
# remediation = none

useradd testuser_123
usermod -g shadow testuser_123
