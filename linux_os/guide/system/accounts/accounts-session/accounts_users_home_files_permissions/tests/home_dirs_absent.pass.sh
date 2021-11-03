#!/bin/bash

USER="cac_user"
useradd -M $USER
# This make sure home dirs related to test environment users are also removed.
rm -Rf /home/*
