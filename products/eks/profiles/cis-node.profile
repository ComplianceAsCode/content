documentation_complete: true

title: 'CIS Amazon Elastic Kubernetes Service (EKS) Benchmark'

platform: eks-node

metadata:
    SMEs:
        - JAORMX
        - mrogers950
        - jhrozek

description: |-
    TODO
selections:
  # 3.1.1 Ensure that the API server pod specification file permissions are set to 644 or more restrictive
    - file_permissions_worker_kubeconfig