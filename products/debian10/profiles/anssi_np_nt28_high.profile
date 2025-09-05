documentation_complete: true

title: 'Profile for ANSSI DAT-NT28 High (Enforced) Level'

description: 'This profile contains items for GNU/Linux installations storing sensitive informations that can be accessible
    from unauthenticated or uncontroled networks.'

extends: anssi_np_nt28_restrictive

selections:
    - grub2_enable_iommu_force
