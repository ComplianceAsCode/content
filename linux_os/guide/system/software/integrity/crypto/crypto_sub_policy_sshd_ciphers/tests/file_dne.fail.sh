#!/bin/bash

if [[ -f /etc/crypto-policies/policies/modules/NO-SSHWEAKCIPHERS.pmod ]]
then
  rm /etc/crypto-policies/policies/modules/NO-SSHWEAKCIPHERS.pmod
fi
