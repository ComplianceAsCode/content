# platform = Java Runtime Environment
JAVA_FILE="/etc/.java/deployment/exception.sites"
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.user.security.exception.sites=.*" ${JAVA_PROPERTIES} && \
sed -i "s;deployment.user.security.exception.sites=.*;deployment.user.security.exception.sites=${JAVA_FILE};g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.user.security.exception.sites=${JAVA_FILE}" >> ${JAVA_PROPERTIES}
fi
