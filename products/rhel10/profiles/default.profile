documentation_complete: true

hidden: true

title: Default Profile for Red Hat Enterprise Linux 10

description: |-
  This profile contains all the rules that once belonged to the rhel10
  product. This profile won't be rendered into an XCCDF Profile entity,
  nor it will select any of these rules by default. The only purpose of
  this profile is to keep a rule in the product's XCCDF Benchmark.

selections:
  - audit_rules_kernel_module_loading_create
