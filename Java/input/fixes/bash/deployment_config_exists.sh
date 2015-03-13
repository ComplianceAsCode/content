JAVA_DIRs="/usr/java/default/lib /etc/alternatives/jre_ibm/lib /etc/alternatives/jre_openjdk/lib /etc/alternatives/jre_sun/lib /etc/alternatives/jre_oracle/lib"
for JAVA_DIR in $(echo ${JAVA_DIRs}); do
	if [ -e ${JAVA_DIR} ]; then
		if [ ! -e ${JAVA_DIR}/deployment.config ]; then
			echo "# New file created for STIG compliance." > ${JAVA_DIR}/deployment.config
		fi
	fi
done