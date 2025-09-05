#!/bin/bash

find -P /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin \! -group root -type f -exec chgrp --no-dereference root '{}' \; || true
