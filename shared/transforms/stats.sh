if [ -e input/auxiliary/stig_overlay.xml ]; then
	XCCDF_FILE=`find references -name \*xccdf.xml 2>/dev/null`
	if [ -e "$XCCDF_FILE" ]; then
		grep "<version>" $XCCDF_FILE | sed -e 's/.*<version>//' -e 's/<\/version>.*//' -e 's/ .*//g' | grep -v ^[0-9] | sort -u > xccdfchecks.out
		cat xccdfchecks.out | while read CHECK; do
			if [ "`grep -c $CHECK input/auxiliary/stig_overlay.xml`" = "0" ]; then
				echo "$CHECK" >> stigtochecksnotfound.out
			fi
		done
	fi
	grep "ruleid" input/auxiliary/stig_overlay.xml | grep -v 'ownerid="SRG' | sed 's/.*<overlay //g' | awk '{ print $3"|"$2 }' | cut -d'"' -f2,4 | sed 's/\"/\|/' | while read ENTRY; do
		STIG_ID=`echo $ENTRY | cut -d"|" -f1`
		CHECK_ID=`echo $ENTRY | cut -d"|" -f2`
		if [ "$(echo $CHECK_ID | egrep -c '^(XXXX|unmet_)')" != "0" ]; then
			echo "$STIG_ID" >> nochecks.out
		elif [ "$(echo $CHECK_ID | egrep -c '^(met_)')" != "0" ]; then
			echo "$STIG_ID|$CHECK_ID" >> inherentchecks.out
		else
			echo "$STIG_ID|$CHECK_ID" >> checks.out
		fi
		if [ -e "$XCCDF_FILE" ]; then
			if [ "`grep -c ${STIG_ID} xccdfchecks.out`" != "0" ]; then
				echo "$STIG_ID|$CHECK_ID" >> checkstostigfound.out
			else
				echo "$STIG_ID|$CHECK_ID" >> checkstostignotfound.out
			fi
		fi
	done
	if [ -e checks.out ]; then
		cat checks.out | cut -d "|" -f2 | sort -u | while read ENTRY; do
			if [ ! -e "input/checks/${ENTRY}.xml" ] && [ ! -e "${SHARED}/oval/${ENTRY}.xml" ]; then
				echo "${ENTRY}" >> missingchecks.out
			else
				echo "${ENTRY}" >> foundchecks.out
			fi
			if [ ! -e "input/fixes/bash/${ENTRY}.sh" ] && [ ! -e "${SHARED}/fixes/bash/${ENTRY}.xml" ]; then
				echo "${ENTRY}" >> missingfixes.out
			else
				echo "${ENTRY}" >> foundfixes.out
			fi
		done
	fi

	echo -e "\nSTIG INTEGRATION SUMMARY:\n\n"
	if [ -e "$XCCDF_FILE" ]; then
		echo -e "TOTAL XCCDF STIG REQUIREMENTS: `grep -c ^ xccdfchecks.out`\n"
	fi
	echo -e "TOTAL SSG STIG REQUIREMENTS: `grep "ruleid" input/auxiliary/stig_overlay.xml | grep -v 'ownerid="SRG' | grep -c ^`\n"
	if [ -e "foundchecks.out" ]; then
		echo -e "TOTAL SSG STIG CHECKS: `grep -c ^ foundchecks.out`\n"
	else
		echo -e "TOTAL SSG STIG CHECKS: 0\n"
	fi
	if [ -e "foundfixes.out" ]; then
		echo -e "TOTAL SSG STIG FIXES: `grep -c ^ foundfixes.out`\n"
	else
		echo -e "TOTAL SSG STIG FIXES: 0\n"
	fi
	if [ -e checkstostignotfound.out ] && [ ! -z checkstostignotfound.out ]; then
		echo -e "\nSSG STIG REQUIREMENTS NOT FOUND IN XCCDF STIG: `grep -c ^ checkstostignotfound.out`\n"
		cat checkstostignotfound.out
	fi
	if [ -e stigtochecksnotfound.out ] && [ ! -z stigtochecksnotfound.out ]; then
		echo -e "\nXCCDF STIG REQUIREMENTS NOT FOUND IN SSG STIG: `grep -c ^ stigtochecksnotfound.out`\n"
		cat stigtochecksnotfound.out
	fi
	rm -f *.out
fi
