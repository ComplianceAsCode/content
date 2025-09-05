documentation_complete: true

title: 'Java Runtime Environment (JRE) STIG'

description: |-
    The Java Runtime Environment (JRE) is a bundle developed
    and offered by Oracle Corporation which includes the Java Virtual Machine
    (JVM), class libraries, and other components necessary to run Java
    applications and applets. Certain default settings within the JRE pose
    a security risk so it is necessary to deploy system wide properties to
    ensure a higher degree of security when utilizing the JRE.

    The IBM Corporation also develops and bundles the Java Runtime Environment
    (JRE) as well as Red Hat with OpenJDK.

selections:
    - java_jre_deployment_config_exists
    - java_jre_deployment_config_properties
    - java_jre_deployment_config_mandatory
    - java_jre_deployment_properties_exists
    - java_jre_untrusted_sources
    - java_jre_untrusted_sources_locked
    - java_jre_validation_crl
    - java_jre_validation_crl_locked
    - java_jre_validation_ocsp
    - java_jre_validation_ocsp_locked
    - java_jre_updated
