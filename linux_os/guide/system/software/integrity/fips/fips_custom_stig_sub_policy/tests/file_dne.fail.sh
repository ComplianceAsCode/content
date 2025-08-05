#!/bin/bash

if [[ -f /etc/crypto-policies/policies/modules/STIG.pmod ]]
then
  rm /etc/crypto-policies/policies/modules/STIG.pmod
fi
