#!/bin/bash

touch /etc/modprobe.d/udf.conf
sed -i '/install udf/d' /etc/modprobe.d/udf.conf
