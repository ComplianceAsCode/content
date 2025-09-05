# platform = Google Chromium Browser
CHROME_POL_FILE="chrome_stig_policy.json"
CHROME_POL_DIR="/etc/chromium/policies/managed/"

if [ ! -d ${CHROME_POL_DIR} ] ; then
   mkdir -p -m 755 ${CHROME_POL_DIR}
fi

if [ ! -f ${CHROME_POL_DIR}/${CHROME_POL_FILE} ] ; then
   touch ${CHROME_POL_DIR}/${CHROME_POL_FILE}
   chmod 644 ${CHROME_POL_DIR}/${CHROME_POL_FILE}
fi

grep -q -E '^\{' ${CHROME_POL_DIR}/${CHROME_POL_FILE}
if ! [ $? -eq 0 ] ; then
   if [ -s ${CHROME_POL_DIR}/${CHROME_POL_FILE} ] ; then
      sed -i '1s/^/\{\n/' ${CHROME_POL_DIR}/${CHROME_POL_FILE}
   else
      echo -e "{" >> ${CHROME_POL_DIR}/${CHROME_POL_FILE}
   fi
fi

tail -1 ${CHROME_POL_DIR}/${CHROME_POL_FILE} | grep -q -E '^\}'
if ! [ $? -eq 0 ] ; then
   echo -e "}" >> ${CHROME_POL_DIR}/${CHROME_POL_FILE}
fi 

