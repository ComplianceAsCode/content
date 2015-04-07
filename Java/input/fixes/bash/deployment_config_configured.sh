JAVA_DIRs="/usr/java/default/lib /etc/alternatives/jre_ibm/lib /etc/alternatives/jre_openjdk/lib /etc/alternatives/jre_sun/lib /etc/alternatives/jre_oracle/lib"
for JAVA_DIR in $(echo ${JAVA_DIRs}); do
	if [ -e ${JAVA_DIR} ]; then
		if [ "$(grep -c "^deployment.system.config=file:${JAVA_DIR}/deployment.properties$" ${JAVA_DIR}/deployment.config)" = "0" ]; then
			echo "deployment.system.config=file:${JAVA_DIR}/deployment.properties" >> ${JAVA_DIR}/deployment.config
		fi
		if [ "$(grep -c "^deployment.system.config.mandatory=false$" ${JAVA_DIR}/deployment.config)" = "0" ]; then
			echo "deployment.system.config.mandatory=false" >> ${JAVA_DIR}/deployment.config
		fi
	fi
done