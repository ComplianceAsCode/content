#!/bin/bash

cp $SHARED/fstab /etc/
sed -i 's/,noexec//' /etc/fstab
