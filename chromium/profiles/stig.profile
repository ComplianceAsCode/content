documentation_complete: true

title: 'Upstream STIG for Google Chromium'

description: |-
    This profile is developed under the DoD consensus model and DISA FSO Vendor STIG process,
    serving as the upstream development environment for the Google Chromium STIG.

    As a result of the upstream/downstream relationship between the SCAP Security Guide project
    and the official DISA FSO STIG baseline, users should expect variance between SSG and DISA FSO content.
    For official DISA FSO STIG content, refer to https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Cbrowser-guidance.

    While this profile is packaged by Red Hat as part of the SCAP Security Guide package, please note
    that commercial support of this SCAP content is NOT available. This profile is provided as example
    SCAP content with no endorsement for suitability or production readiness. Support for this
    profile is provided by the upstream SCAP Security Guide community on a best-effort basis. The
    upstream project homepage is https://www.open-scap.org/security-policies/scap-security-guide/.

selections:
    - var_default_search_provider_name=google
    - var_url_blacklist=javascript
    - var_enable_encrypted_searching=google
    - var_extension_whitelist=none
    - var_auth_schema=negotiate
    - var_trusted_home_page=blank
    - chromium_policy_file
    - chromium_disable_firewall_traversal
    - chromium_block_desktop_notifications
    - chromium_disable_popups
    - chromium_disallow_location_tracking
    - chromium_blacklist_extension_installation
    - chromium_extension_whitelist
    - chromium_default_search_provider_name
    - chromium_enable_encrypted_searching
    - chromium_default_search_provider
    - chromium_disable_cleartext_passwords
    - chromium_disable_password_manager
    - chromium_http_authentication
    - chromium_disable_outdated_plugins
    - chromium_plugins_require_authorization
    - chromium_disable_thirdparty_cookies
    - chromium_disable_background_processing
    - chromium_disable_3d_graphics_api
    - chromium_disable_google_sync
    - chromium_disable_protocol_schemas
    - chromium_disable_autocomplete
    - chromium_disable_cloud_print_sharing
    - chromium_disable_network_prediction
    - chromium_disable_metrics_reporting
    - chromium_disable_search_suggestions
    - chromium_disable_saved_passwords
    - chromium_disable_incognito_mode
    - chromium_disable_plugin_blacklist
    - chromium_enable_approved_plugins
    - chromium_disable_automatic_installation
    - chromium_check_cert_revocation
    - chromium_enable_safe_browsing
    - chromium_enable_browser_history
    - chromium_default_block_plugins
    - chromium_disable_session_cookies
    - chromium_trusted_home_page
    - chromium_whitelist_plugin_urls
