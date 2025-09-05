# platform = Java Runtime Environment
JAVA_FILE="/etc/.java/deployment/exception.sites"
JAVA_DIR="/etc/.java/deployment"

# shellcheck disable=SC2174
mkdir -p -m 755 ${JAVA_DIR}

if [ ! -e ${JAVA_FILE} ]; then
  touch ${JAVA_FILE} && chmod 644 ${JAVA_FILE}
fi

chmod 644 ${JAVA_FILE}
