#!/bin/bash
# packages = authconfig
# platform = Oracle Linux 7

authconfig --enablefaillock --faillockargs="even_deny_root" --update
