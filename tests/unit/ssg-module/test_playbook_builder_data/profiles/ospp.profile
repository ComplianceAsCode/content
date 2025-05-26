{
  "description": "This profile is part of Red Hat Enterprise Linux 9 Common Criteria Guidance\ndocumentation for Target of Evaluation based on Protection Profile for\nGeneral Purpose Operating Systems (OSPP) version 4.3 and Functional\nPackage for SSH version 1.0.\n\nWhere appropriate, CNSSI 1253 or DoD-specific values are used for\nconfiguration, based on Configuration Annex to the OSPP.",
  "extends": null,
  "hidden": "",
  "status": "",
  "metadata": {
    "version": 4.3,
    "SMEs": [
      "ggbecker",
      "matusmarhefka"
    ]
  },
  "reference": "https://www.niap-ccevs.org/Profile/Info.cfm?PPID=469&id=469",
  "selections": [
    "package_abrt_removed",
    "configure_crypto_policy",
    "selinux_state",
    "var_selinux_state=enforcing",
    "var_selinux_policy_name=targeted"
  ],
  "unselected_groups": [],
  "platforms": [],
  "cpe_names": [],
  "platform": null,
  "filter_rules": "",
  "policies": [],
  "single_rule_profile": false,
  "title": "Protection Profile for General Purpose Operating Systems",
  "definition_location": "products/rhel9/profiles/ospp.profile"
}
