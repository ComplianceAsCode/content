# platform = Java Runtime Environment
JAVA_CONFIG="/etc/.java/deployment/deployment.config"
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.system.config=file://${JAVA_CONFIG}$" ${JAVA_CONFIG} && \
sed -i "s;deployment.system.config=.*;deployment.system.config=file:\/\/${JAVA_PROPERTIES};g" ${JAVA_CONFIG}
if ! [ $? -eq 0 ] ; then
  echo "deployment.system.config=file://${JAVA_PROPERTIES}" >> ${JAVA_CONFIG}
fi
