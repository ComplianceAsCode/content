#!/bin/bash
cat >> /etc/sssd/sssd.conf<< EOF
[certmap/testing.test/rule_name]
matchrule =<SAN>.*EDIPI@mil
maprule = (userCertificate;binary={cert!bin})
domains = testing.test
EOF
