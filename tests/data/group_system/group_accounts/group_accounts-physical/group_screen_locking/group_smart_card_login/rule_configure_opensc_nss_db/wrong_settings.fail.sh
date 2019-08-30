#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ncp

yum install -y opensc nss-utils

# notice the absence of prefix sql: in -dbdir parameter value, this cause modutil to write in old dabatase format
# which does not write into /etc/pki/nssdb/pkcs11.txt file (our OVAL checks this file)
modutil -add "OpenSC PKCS #11 Module" -dbdir /etc/pki/nssdb/ -libfile opensc-pkcs11.so -force
