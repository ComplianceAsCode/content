#!/bin/bash

find / -xdev -type f -name ".shosts" -exec rm -f {} \;
