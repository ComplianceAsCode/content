documentation_complete: true

title: 'Server Baseline'

description: |-
    This profile is for Red Hat Enterprise Linux 6
    acting as a server.

extends: standard

selections:
    - wireless_disable_interfaces
    - xwindows_runlevel_setting
    - package_xorg-x11-server-common_removed
    - sysconfig_networking_bootproto_ifcfg
