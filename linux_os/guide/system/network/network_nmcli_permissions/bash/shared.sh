# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

printf "[Disable General User Access to NetworkManager]\nIdentity=default\nAction=org.freedesktop.NetworkManager.*\nResultAny=no\nResultInactive=no\nResultActive=auth_admin\n" > /etc/polkit-1/localauthority/20-org.d/10-nm-harden-access.pkla
