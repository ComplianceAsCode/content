# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.webjava.enabled=.*$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.webjava.enabled=.*/deployment.webjava.enabled=true/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.webjava.enabled=true" >> ${JAVA_PROPERTIES}
fi
