#!/bin/bash

if [[ -f /etc/crypto-policies/policies/modules/{{{ MODULE_NAME }}}.pmod ]]
then
  rm /etc/crypto-policies/policies/modules/{{{ MODULE_NAME }}}.pmod
fi
