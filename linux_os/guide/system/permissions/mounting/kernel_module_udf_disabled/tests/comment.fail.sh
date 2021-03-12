#!/bin/bash

if [ -f /etc/modprobe.d/udf.conf ]; then
    sed -i '/install udf/d' /etc/modprobe.d/udf.conf
fi
echo "# install udf /bin/true" > /etc/modprobe.d/udf.conf
