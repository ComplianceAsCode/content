#!/bin/bash

find / -xdev -type f -name "shosts.equiv" -exec rm -f {} \;
