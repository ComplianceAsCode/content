#!/bin/bash

cp libuser.conf /etc/
sed -i "s/crypt_style = sha512/crypt_style = md5/" /etc/libuser.conf
