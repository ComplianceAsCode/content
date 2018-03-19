# platform = Java Runtime Environment
JAVA_CONFIG="/etc/.java/deployment/deployment.config"
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

# couldn't use replace_or_append, probably because of delimiters
grep -q "^deployment.system.config=" ${JAVA_CONFIG} && \
sed -i "s;^deployment.system.config=.*;deployment.system.config=file://${JAVA_PROPERTIES};g" ${JAVA_CONFIG}
if [ $? -ne 0 ] ; then
  echo >> ${JAVA_CONFIG}
  echo "# Per @CCENUM@: Set deployment.system.config" >> ${JAVA_CONFIG}
  echo "deployment.system.config=file://${JAVA_PROPERTIES}" >> ${JAVA_CONFIG}
fi
