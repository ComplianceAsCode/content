#!/bin/bash

find -P /lib /lib64 /usr/lib /usr/lib64 ! -group root -type f -exec chgrp root '{}' \;
