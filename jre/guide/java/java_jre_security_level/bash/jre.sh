# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.security.level=VERY_HIGH$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.security.level=.*/deployment.security.level=VERY_HIGH/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.level=VERY_HIGH" >> ${JAVA_PROPERTIES}
fi

grep -q "^deployment.security.level.locked$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.security.level\..*/deployment.security.level.locked/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.level.locked" >> ${JAVA_PROPERTIES}
fi
