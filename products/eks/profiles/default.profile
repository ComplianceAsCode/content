documentation_complete: true

hidden: true

title: Default Profile for Amazon Elastic Kubernetes Service

description: |-
    This profile contains all the rules that once belonged to the
    eks product via 'prodtype'. This profile won't
    be rendered into an XCCDF Profile entity, nor it will select any
    of these rules by default. The only purpose of this profile
    is to keep a rule in the product's XCCDF Benchmark.

selections:
    - kubelet_enable_streaming_connections_deprecated
