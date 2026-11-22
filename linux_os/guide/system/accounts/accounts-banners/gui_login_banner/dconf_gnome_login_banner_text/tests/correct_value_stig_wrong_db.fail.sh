#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_fedora
# profiles = xccdf_org.ssgproject.content_profile_stig
# packages = dconf,gdm

source $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

login_banner_contents=$(cat <<'EOF'
You are accessing a U.S. Government (USG) Information System (IS) that is
provided for USG-authorized use only. By using this IS (which includes any
device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for
purposes including, but not limited to, penetration testing, COMSEC monitoring,
network operations and defense, personnel misconduct (PM), law enforcement
(LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject
to routine monitoring, interception, and search, and may be disclosed or used
for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls)
to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE
or CI investigative searching or monitoring of the content of privileged
communications, or work product, related to personal representation or services
by attorneys, psychotherapists, or clergy, and their assistants. Such
communications and work product are private and confidential. See User
Agreement for details.
EOF
)

# replace two subsequent newlines with a \n\n and single newlines with a space
login_banner_text_escaped=$(printf '%s' "$login_banner_contents" | sed ':a;N;$!ba;s/\n\n/\\n\\n/g;s/\n/ /g')

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "banner-message-text" "'${login_banner_text_escaped}'" "dummy.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-text" "dummy.d" "00-security-settings-lock"

dconf update
