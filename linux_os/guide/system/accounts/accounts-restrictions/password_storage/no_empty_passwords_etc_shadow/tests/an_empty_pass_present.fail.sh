#!/bin/bash
# packages = passwd
useradd new_user_with_empty_password
passwd -d new_user_with_empty_password
