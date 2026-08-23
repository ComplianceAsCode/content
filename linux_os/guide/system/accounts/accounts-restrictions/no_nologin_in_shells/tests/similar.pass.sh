#!/bin/bash

sed -i --follow-symlinks '/nologin/d' /etc/shells
echo "/sbin/nologinormaybe" >> /etc/shells

 
