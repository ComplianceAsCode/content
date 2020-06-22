# platform = Java Runtime Environment
JAVA_SITE="/etc/.java/deployment/exception.sites"
JAVA_DIR="/etc/.java/deployment"

if [ ! -d ${JAVA_DIR} ] ; then
  mkdir -p -m 755 ${JAVA_DIR}
fi

if [ ! -e ${JAVA_SITE} ]; then
  touch ${JAVA_SITE} && chmod 644 ${JAVA_SITE}
fi

chmod 644 ${JAVA_SITE}
