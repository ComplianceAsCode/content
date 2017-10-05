# platform = Java Runtime Environment
JAVA_CONFIG="/etc/.java/deployment/deployment.config"

grep -q "^deployment.system.config.mandatory=false$" ${JAVA_CONFIG} && \
sed -i "s/deployment.system.config.mandatory=.*/deployment.system.config.mandatory=false/g" ${JAVA_CONFIG}
if ! [ $? -eq 0 ] ; then
  echo "deployment.system.config.mandatory=false" >> ${JAVA_CONFIG}
fi
