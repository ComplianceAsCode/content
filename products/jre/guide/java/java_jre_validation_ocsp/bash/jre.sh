# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"
JAVA_DIR="/etc/.java/deployment"

# shellcheck disable=SC2174
mkdir -p -m 755 ${JAVA_DIR}

if [ ! -e ${JAVA_PROPERTIES} ]; then
  touch ${JAVA_PROPERTIES} && chmod 644 ${JAVA_PROPERTIES}
fi

grep -q "^deployment.security.validation.ocsp=.*" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.security.validation.ocsp=.*/deployment.security.validation.ocsp=true/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.validation.ocsp=true" >> ${JAVA_PROPERTIES}
fi
