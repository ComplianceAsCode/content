# platform = Java Runtime Environment
JAVA_PROPERTIES="/etc/.java/deployment/deployment.properties"

grep -q "^deployment.security.askgrantdialog.notinca.locked$" ${JAVA_PROPERTIES}
if ! [ $? -eq 0 ] ; then
  echo "deployment.security.askgrantdialog.notinca.locked" >> ${JAVA_PROPERTIES}
fi
