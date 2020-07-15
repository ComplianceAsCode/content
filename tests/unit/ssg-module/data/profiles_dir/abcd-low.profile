documentation_complete: true
title: ABCD Low for Red Hat Enterprise Linux 8
description: >-
  This profile contains configuration checks that align to
  the ABCD benchmark.
policies:
- id: abcd
  controls:
  - R1
  - R2
  - R3
selections:
  - security_patches_up_to_date
