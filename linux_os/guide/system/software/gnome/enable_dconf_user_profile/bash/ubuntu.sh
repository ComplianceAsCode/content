# platform = multi_platform_ubuntu

# configure two dconf profiles:
# - gdm: required for banner/user_list settings
# - user: required for screenlock,automount,ctrlaltdel,... settings
{{{ bash_enable_dconf_user_profile(profile="user", database="local") }}}
{{{ bash_enable_dconf_user_profile(profile="gdm", database="gdm") }}}
