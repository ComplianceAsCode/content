# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"
JAVA_DIR="/etc/.java/deployment"

# shellcheck disable=SC2174
mkdir -p -m 755 ${JAVA_DIR}

if [ ! -e ${JAVA_PROPERTIES} ]; then
  touch ${JAVA_PROPERTIES} && chmod 644 ${JAVA_PROPERTIES}
fi

JAVA_FILE="/etc/.java/deployment/exception.sites"

grep -q "^deployment.user.security.exception.sites=.*" ${JAVA_PROPERTIES} && \
sed -i "s;deployment.user.security.exception.sites=.*;deployment.user.security.exception.sites=${JAVA_FILE};g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.user.security.exception.sites=${JAVA_FILE}" >> ${JAVA_PROPERTIES}
fi
