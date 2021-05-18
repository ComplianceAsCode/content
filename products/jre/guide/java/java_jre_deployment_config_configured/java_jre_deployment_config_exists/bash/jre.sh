# platform = Java Runtime Environment
JAVA_CONFIG="/etc/.java/deployment/deployment.config"
JAVA_DIR="/etc/.java/deployment"

if [ ! -d ${JAVA_DIR} ] ; then
  mkdir -p -m 755 ${JAVA_DIR}
fi

if [ ! -e ${JAVA_CONFIG} ]; then
  touch ${JAVA_CONFIG} && chmod 644 ${JAVA_CONFIG}
fi

chmod 644 ${JAVA_CONFIG}