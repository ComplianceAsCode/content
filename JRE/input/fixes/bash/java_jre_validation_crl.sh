# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.security.validation.crl=true$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.security.validation.crl=.*/deployment.security.validation.crl=true/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.validation.crl=true" >> ${JAVA_PROPERTIES}
fi