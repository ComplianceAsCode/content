#!/bin/bash
# packages = authconfig
# platform = Oracle Linux 7,multi_platform_fedora

authconfig --enablefaillock --faillockargs="even_deny_root" --update
