#!/bin/bash
# A system with no repository definitions at all, such as an image mode host,
# has no repository with gpgcheck disabled and therefore satisfies the rule.
rm -rf /etc/yum.repos.d/
mkdir -p /etc/yum.repos.d/
