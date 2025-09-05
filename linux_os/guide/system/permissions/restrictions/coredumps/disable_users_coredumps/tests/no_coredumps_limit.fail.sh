#!/bin/bash

sed -ir '/\*\s+hard\s+core/d' /etc/security/limits.conf
