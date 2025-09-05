documentation_complete: true

title: 'CIS Amazon Elastic Kubernetes Service (EKS) Benchmark - Node'

platform: eks-node

metadata:
    SMEs:
        - JAORMX
        - mrogers950
        - jhrozek

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Amazon Elastic Kubernetes Service (EKS) Benchmark™, V1.0.1.

    This profile includes Center for Internet Security®
    Amazon Elastic Kubernetes Service (EKS)™ content.

    This profile is applicable to EKS 1.21 and greater.

filter_rules: '"eks-node" in platforms'

selections:
    - cis_eks:all:level_2
