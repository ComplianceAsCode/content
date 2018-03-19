# platform = Java Runtime Environment
. /usr/share/scap-security-guide/remediation_functions
JAVA_CONFIG="/etc/.java/deployment/deployment.config"

replace_or_append "${JAVA_CONFIG}" 'deployment.system.config.mandatory' "true" '@CCENUM@' '%s=%s'
