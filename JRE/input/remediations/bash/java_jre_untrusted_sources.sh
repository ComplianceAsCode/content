# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.security.askgrantdialog.notinca=false$" ${JAVA_PROPERTIES} && \
sed -i "s/deployment.security.askgrantdialog.notinca=.*/deployment.security.askgrantdialog.notinca=false/g" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.askgrantdialog.notinca=false" >> ${JAVA_PROPERTIES}
fi