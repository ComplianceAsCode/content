#!/bin/bash
# platform = multi_platform_rhel

grubby --update-kernel=ALL --args="noexec=off"
