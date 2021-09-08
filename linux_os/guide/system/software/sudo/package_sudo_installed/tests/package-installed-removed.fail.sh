#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora

# sudo is a special package which cannot be normally
# removed so we need to remove it using rpm and without
# removing other dependencies.
rpm -e --nodeps sudo
