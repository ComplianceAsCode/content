documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - tjbutt58

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
    This is a draft profile for experimental purposes.

    This draft profile contains configuration checks for Red Hat Enterprise Linux 10
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - e8:all
    # nosha1 crypto policy does not exist in RHEL 10
    - var_system_crypto_policy=default_policy
    # More tests are needed to identify which rule is conflicting with rpm_verify_permissions.
    # https://github.com/ComplianceAsCode/content/issues/11285
    - '!rpm_verify_permissions'
    - '!rpm_verify_ownership'
    # these packages do not exist in RHEL 10
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!security_patches_up_to_date'
    # this rule fails after being remediated through Ansible
    - '!audit_rules_usergroup_modification'
