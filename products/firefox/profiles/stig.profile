documentation_complete: true

metadata:
   version: V6R3
   SMEs:
       - lenox-joseph

title: 'Mozilla Firefox STIG'

description: |-
    This profile is developed under the DoD consensus model and DISA FSO Vendor STIG process,
    serving as the upstream development environment for the Firefox STIG.

    As a result of the upstream/downstream relationship between the SCAP Security Guide project
    and the official DISA FSO STIG baseline, users should expect variance between SSG and DISA FSO content.
    For official DISA FSO STIG content, refer to https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Cbrowser-guidance.

    While this profile is packaged by Red Hat as part of the SCAP Security Guide package, please note
    that commercial support of this SCAP content is NOT available. This profile is provided as example
    SCAP content with no endorsement for suitability or production readiness. Support for this
    profile is provided by the upstream SCAP Security Guide community on a best-effort basis. The
    upstream project homepage is https://www.open-scap.org/security-policies/scap-security-guide/.

selections:
    - var_default_home_page=about_blank
    - installed_firefox_version_supported
    - firefox_policy-addons_permission
    - firefox_policy-autoplay_video
    - firefox_policy-cryptomining
    - firefox_policy-development_tools
    - firefox_policy-disable_deprecated_ciphers
    - firefox_policy-disable_form_history
    - firefox_policy-disable_pocket
    - firefox_policy-disable_studies
    - firefox_policy-dns_over_https
    - firefox_policy-encrypted_media_extensions
    - firefox_policy-enhanced_tracking
    - firefox_policy-extension_recommendation
    - firefox_policy-extension_update
    - firefox_policy-feedback_reporting
    - firefox_policy-fingerprinting_protection
    - firefox_policy-forget_button
    - firefox_policy-javascript_window_changes
    - firefox_policy-javascript_window_resizing
    - firefox_policy-network_prediction
    - firefox_policy-no_sanitize_on_shutdown
    - firefox_policy-nonessential_capabilities
    - firefox_policy-password_manager
    - firefox_policy-pop-up_windows
    - firefox_policy-private_browsing
    - firefox_policy-search_suggestion
    - firefox_policy-search_update
    - firefox_policy-ssl_minimum_version
    - firefox_policy-sync
    - firefox_policy-telemetry
    - firefox_policy-user_messaging
    - firefox_policy-verification
    - firefox_preferences-auto-download_actions
    - firefox_preferences-dod_root_certificate
