# platform =  Java Runtime Environment


JRE_CONFIG_FILE="/usr/lib/jvm/jre/lib/security/java.security"
{{{ bash_replace_or_append("$JRE_CONFIG_FILE", '^security.useSystemPropertiesFile', 'true', '@CCENUM@', '%s=%s') }}}
