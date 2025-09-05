# platform = Java Runtime Environment
JAVA_CONFIG="/etc/.java/deployment/deployment.config"
JAVA_DIR="/etc/.java/deployment"

# shellcheck disable=SC2174
mkdir -p -m 755 ${JAVA_DIR}

if [ ! -e ${JAVA_CONFIG} ]; then
  touch ${JAVA_CONFIG} && chmod 644 ${JAVA_CONFIG}
fi

grep -q "^deployment.system.config.mandatory=.*" ${JAVA_CONFIG} && \
sed -i "s/deployment.system.config.mandatory=.*/deployment.system.config.mandatory=true/g" ${JAVA_CONFIG}
if ! [ $? -eq 0 ] ; then
  echo "deployment.system.config.mandatory=true" >> ${JAVA_CONFIG}
fi
