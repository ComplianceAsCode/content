# platform = Java Runtime Environment
. /usr/share/scap-security-guide/remediation_functions
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

replace_or_append "${JAVA_PROPERTIES}" 'deployment.security.validation.crl=' "true" '@CCENUM@' '%s=%s'
