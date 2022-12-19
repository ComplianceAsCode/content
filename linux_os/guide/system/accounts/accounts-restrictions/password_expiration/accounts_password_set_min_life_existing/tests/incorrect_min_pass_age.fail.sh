#!/bin/bash

# packages = passwd

BAD_PAS_AGE=-1

useradd testuser_123

passwd -n $BAD_PAS_AGE testuser_123
