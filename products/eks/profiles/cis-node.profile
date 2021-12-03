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
selections:
  # 3.1.1 Ensure that the API server pod specification file permissions are set to 644 or more restrictive
    - file_permissions_worker_kubeconfig
