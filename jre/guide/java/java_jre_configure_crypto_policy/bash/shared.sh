# platform =  Java Runtime Environment

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

JRE_CONFIG_FILE="/usr/lib/jvm/jre/lib/security/java.security"
replace_or_append "$JRE_CONFIG_FILE" '^security.useSystemPropertiesFile' 'true' '@CCENUM@' '%s=%s'
