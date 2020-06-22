# platform = Java Runtime Environment
JAVA_CONFIG="/etc/.java/deployment/deployment.config"
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

sed -i "/deployment.system.config=.*/d" ${JAVA_CONFIG}
echo "deployment.system.config=${JAVA_PROPERTIES}" >> ${JAVA_CONFIG}

sed -i "/deployment.system.config.mandatory=.*/d" ${JAVA_CONFIG}
echo "deployment.system.config.mandatory=true" >> ${JAVA_CONFIG}
