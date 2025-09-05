#!/bin/bash
# packages = authconfig
# platform = multi_platform_fedora,Red Hat Enterprise Linux 7

authconfig --enablefaillock --faillockargs="even_deny_root" --update
