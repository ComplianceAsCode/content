# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.insecure.jres=PROMPT$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.insecure.jres=.*/deployment.insecure.jres=PROMPT/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.insecure.jres=PROMPT" >> ${JAVA_PROPERTIES}
fi

grep -q "^deployment.insecure.jres.locked$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.insecure.jres\..*/deployment.insecure.jres.locked/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.insecure.jres.locked" >> ${JAVA_PROPERTIES}
fi
