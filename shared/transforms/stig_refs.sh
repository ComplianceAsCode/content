# For this to work, you need to:
# 1) Download the latest STIG, 
# 2) Extract the xccdf file into the root project folder (i.e. RHEL\5), 
# 3) Run this script from that same project folder.
if [ -e input/auxiliary/stig_overlay.xml ]; then
	XCCDF_FILE=`find references -name \*xccdf.xml 2>/dev/null`
	if [ -e "$XCCDF_FILE" ]; then
		grep "<Group " $XCCDF_FILE | sed -e 's/.*<Group id="//' -e 's/">.*//' | sort -u > xccdfchecks.out
		RULES="$(grep -c ^ xccdfchecks.out)"
		LINE=1
		cat xccdfchecks.out | while read VKEY; do
			echo "Processing rule ${LINE} of ${RULES}"
			STIG_ID=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE | grep "<version>" | sed -e "s/.*<version>//" -e "s/<\/version>.*//")
			CCI=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE | grep -i '<ident.*cci' | cut -d'>' -f2 | cut -d'<' -f1 | sed ':a;N;$!ba;s/\n/,/g' | sed 's/[cC][cC][iI]-[0]*//g')
			CCE=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE | grep -i '<ident.*cce' | cut -d'>' -f2 | cut -d'<' -f1 | sed ':a;N;$!ba;s/\n/,/g' | sed 's/[cC][cC][eE]-//g')
			SEVERITY=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE |  grep 'severity=' | sed -e 's/.*severity="//' -e 's/".*//')
			SVKEY=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE | grep -i 'Rule id=' | sed -e 's/.*Rule id="SV-//' -e 's/r[0-9].*//')
			VRELEASE=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE | grep -i 'Rule id=' | sed -e 's/.*Rule id="SV-[0-9]*//' -e 's/r\([0-9]\).*/\1/')
			IACONTROLS=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE | grep "&lt;IAControls&gt;" | sed -e 's/.*&lt;IAControls&gt;//' -e 's/&.*//' -e 's/,[ ]*/,/g')
			TITLE=$(awk "/<Group id=\"${VKEY}\"/,/<\/Group/" $XCCDF_FILE | awk "/<Rule /,/<\/Rule>/" | grep '<title>' | sed -e "s/.*<title>//" -e "s/<\/title>.*//")
			RULE_ID=$(grep "<overlay.*ownerid=\"${STIG_ID}\"" auxiliary/stig_overlay.xml | sed -e 's/.*ruleid="//' -e 's/".*//')
			echo "${VKEY}|${STIG_ID}|${CCI}|${CCE}|${SEVERITY}|${SVKEY}|${VRELEASE}|${IACONTROLS}|${TITLE}|${RULE_ID}"
			sed -i -e "/<overlay.*ownerid=\"${STIG_ID}\"/,/<\/overlay>/s/disa=\"[0-9]*\"/disa=\"$(echo ${CCI} | cut -d"," -f1)\"/" -e "/<overlay.*ownerid=\"${STIG_ID}\"/,/<\/overlay>/s/severity=\"[a-z]*\"/severity=\"${SEVERITY}\"/" -e "/<overlay.*ownerid=\"${STIG_ID}\"/,/<\/overlay>/s/VKey=\"[0-9]*\"/VKey=\"$(echo ${VKEY}|sed 's/[vV]-//')\"/" -e "/<overlay.*ownerid=\"${STIG_ID}\"/,/<\/overlay>/s/SVKey=\"[0-9]*\"/SVKey=\"${SVKEY}\"/" -e "/<overlay.*ownerid=\"${STIG_ID}\"/,/<\/overlay>/s/VRelease=\"[0-9]*\"/VRelease=\"${VRELEASE}\"/" -e "\|<overlay.*ownerid=\"${STIG_ID}\"|,\|</overlay>|s|<title>.*</title>|<title>${TITLE}</title>|" auxiliary/stig_overlay.xml
			if [ "$(grep -R "<Rule id=\"${RULE_ID}\"" input/services input/system 2>/dev/null| grep -c ^)" != 0 ]; then
				grep -R "<Rule id=\"${RULE_ID}\"" input/services input/system 2>/dev/null | cut -d: -f1 | uniq | while read FILE; do
					# SEVERITY
					sed -i -e "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/severity=\"[a-z]*\"/severity=\"${SEVERITY}\"/" ${FILE}
					# CCE
					if [ ! -z "${CCE}" ]; then
						if [ "$(awk "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/" ${FILE} | grep -c "<ident ")" = "0" ]; then
							sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/\(<\/Rule>\)/<ident cce=\"${CCE}\" \/>\n\1/" ${FILE}
						elif [ "$(awk "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/" ${FILE} | grep "<ident " | grep -c "cce=")" = "0" ]; then
							sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/\(<ident .*\)\/>/\1 cce=\"${CCE}\" \/>/" ${FILE}
						else
							sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/\(<ident .*\)cce=\"[a-zA-Z0-9-_.]*\"/\1cce=\"${CCE}\"/" ${FILE}
						fi
					fi
					# STIG ID
					if [ ! -z "${STIG_ID}" ]; then
						if [ "$(awk "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/" ${FILE} | grep -c "<ident ")" = "0" ]; then
							sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/\(<\/Rule>\)/<ident stig=\"${STIG_ID}\" \/>\n\1/" ${FILE}
						elif [ "$(awk "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/" ${FILE} | grep "<ident " | grep -c "stig=")" = "0" ]; then
							sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/\(<ident .*\)\/>/\1 stig=\"${STIG_ID}\" \/>/" ${FILE}
						else
							sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/\(<ident .*\)stig=\"[a-zA-Z0-9-_.]*\"/\1cce=\"${STIG_ID}\"/" ${FILE}
						fi
					fi
					# CCI
					# IA CONTROL
					if [ "$(awk "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/" ${FILE} | grep -c "<ref ")" != "0" ]; then
						sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/<ref .*/<ref nist=\"${IACONTROLS}\" disa=\"${CCI}\" \/>/" ${FILE}
					else
						sed -i "/<Rule id=\"${RULE_ID}\"/,/<\/Rule>/s/\(<\/Rule>\)/<ref nist=\"${IACONTROLS}\" disa=\"${CCI}\" \/>\n\1/" ${FILE}
					fi
				done
			fi
			LINE="$(expr ${LINE} + 1)"
		done
	fi
	rm -f *.out
fi
