# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.insecure.jres.locked$" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.insecure.jres.locked" >> ${JAVA_PROPERTIES}
fi
