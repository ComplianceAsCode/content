#!/bin/bash

cp libuser.conf /etc/
sed -i "/crypt_style/d" /etc/libuser.conf
