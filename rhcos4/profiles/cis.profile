documentation_complete: true

title: 'CIS Red Hat OpenShift Container Platform 4 Benchmark'

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat OpenShift Container Platform 4 Benchmark™, V0.3, currently unreleased.

    This profile includes Center for Internet Security®
    Red Hat OpenShift Container Platform 4 CIS Benchmarks™ content.

    Note that this part of the profile is meant to run on the Nodes that
    Red Hat OpenShift Container Platform 4 runs on top of.

selections:
  ### 4 Worker Nodes
  ###
  #### 4.1 Worker node configuration
  # 4.1.1 Ensure that the kubelet service file permissions are set to 644 or more restrictive
    - file_permissions_kubelet_service
  # 4.1.2 Ensure that the kubelet service file ownership is set to root:root
    - file_ownership_kubelet_service
  # 4.1.5 Ensure that the --kubeconfig kubelet.conf file permissions are set to 644 or more restrictive
    # - create a rule based on file_permissions_kubelet_service that checks the perms of /etc/kubernetes/kubelet.conf
  # 4.1.6 Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root
    # - create a rule based on file_ownership_kubelet_service that checks the ownership of /etc/kubernetes/kubelet.conf
  # 4.1.7 Ensure that the certificate authorities file permissions are set to 644 or more restrictive
    # - create a rule based on file_permissions_kubelet_service that checks the perms of /etc/kubernetes/kubelet-ca.crt
  # 4.1.8 Ensure that the client certificate authorities file ownership is set to root:root
    # - create a rule based on file_ownership_kubelet_service that checks the ownership of /etc/kubernetes/kubelet-ca.crt
  # 4.1.9 Ensure that the kubelet --config configuration file has permissions set to 644 or more restrictive
    # - create a rule based on file_permissions_kubelet_service that checks the perms of /var/lib/kubelet/kubeconfig
  # 4.1.10 Ensure that the kubelet configuration file ownership is set to root:root
    # - create a rule based on file_ownership_kubelet_service that checks the ownership of /var/lib/kubelet/kubeconfig
  ###
  #### 4.2 Kubelet
  # 4.2.1 Ensure that the --anonymous-auth argument is set to false
    - kubelet_anonymous_auth_disabled
  # 4.2.2 Ensure that the --authorization-mode argument is not set to AlwaysAllow
    # - this seems to be the default in the code, so the rule should verify that authorization mode is NOT set to AlwaysAllow
  # 4.2.3 Ensure that the --client-ca-file argument is set as appropriate
    # - like kubelet_anonymous_auth_disabled but check for authentication.x509.clientCAFile=/etc/kubernetes/kubelet-ca.crt
  # 4.2.4 Ensure that the --read-only-port argument is set to 0
    # - this is a platform rule (reads from a CM)
  # 4.2.5 Ensure that the --streaming-connection-idle-timeout argument is not set to 0
    # - like kubelet_anonymous_auth_disabled but check for streamingConnectionIdleTimeout NOT being 0
  # 4.2.6 Ensure that the --protect-kernel-defaults argument is set to true
    # - like kubelet_anonymous_auth_disabled but check that protectKernelDefaults is set to true
    # FIXME(jhrozek): This does not seem to be set in OCP explicitly and the code seems to suggest
    # that the default is false? Need to confirm
  # 4.2.7 Ensure that the --make-iptables-util-chains argument is set to true
    # - like kubelet_anonymous_auth_disabled but check for makeIPTablesUtilChains is NOT set to false (true is the default)
  # 4.2.8 Ensure that the --hostname-override argument is not set (Manual)
    # FIXME: systemd probe to check that the service.execStart does NOT contain --hostname-override. This is
    # runtime flag only, no config value
  # 4.2.9 Ensure that the --event-qps argument is set to 0 or a level which ensures appropriate event capture
    # - like kubelet_anonymous_auth_disabled but check for kubeAPIQPS set to 50
  # 4.2.10 Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate
    # - this is a platform rule (reads from a CM)
  # 4.2.11 Ensure that the --rotate-certificates argument is not set to false
    # - like kubelet_anonymous_auth_disabled but check for rotateCertificates=true
  # 4.2.12 Verify that the RotateKubeletServerCertificate argument is set to true
    # - like kubelet_anonymous_auth_disabled but check for featureGates.RotateKubeletServerCertificate=true
