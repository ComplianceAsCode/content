JAVA_DIRs="/usr/java/default/lib /etc/alternatives/jre_ibm/lib /etc/alternatives/jre_openjdk/lib /etc/alternatives/jre_sun/lib /etc/alternatives/jre_oracle/lib"
for JAVA_DIR in $(echo ${JAVA_DIRs}); do
	if [ -e ${JAVA_DIR} ]; then
		if [ "$(grep -c "^deployment.security.validation.ocsp.locked$" ${JAVA_DIR}/deployment.properties)" = "0" ]; then
			echo "deployment.security.validation.ocsp.locked" >> ${JAVA_DIR}/deployment.properties
		fi
	fi
done