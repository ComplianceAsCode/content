# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.security.revocation.check=ALL_CERTIFICATES$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.security.revocation.check=.*/deployment.security.revocation.check=ALL_CERTIFICATES/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.revocation.check=ALL_CERTIFICATES" >> ${JAVA_PROPERTIES}
fi

grep -q "^deployment.security.revocation.check.locked$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.security.revocation.check\..*/deployment.security.revocation.check.locked/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.revocation.check.locked" >> ${JAVA_PROPERTIES}
fi
