 
documentation_complete: true
title: ABCD High for Red Hat Enterprise Linux 8
description: >-
  This profile contains configuration checks that align to
  the ABCD benchmark.
extends: abcd-low
policies:
- id: abcd
  controls:
  - R4
selections:
# override setting from R4.b
  - var_password_pam_ocredit=2
