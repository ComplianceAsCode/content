# Generate a sgid file baseline
find / -perm -2000 -type f  2>/dev/null | sort > /var/log/sgid-file-list
chmod 640 /var/log/sgid-file-list
chown root:root /var/log/sgid-file-list

# Generate a weekly cron job to check the sgid file baseline and report differences
cat > /etc/cron.weekly/baseline_checker.sh <<'STOP_HERE'
#!/bin/sh
echo "Baseline check started on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")" | tee -a /var/log/baseline.log
echo -e \\n | tee -a /var/log/baseline.log
echo "Gathering current baseline." | tee -a /var/log/baseline.log
echo -e \\n | tee -a /var/log/baseline.log
rm -f /tmp/*BASELINE.tmp /tmp/*list.tmp
find / -perm -4000 2>/dev/null | sort > /tmp/suid-file-list.tmp
find / -perm -2000 2>/dev/null | sort > /tmp/sgid-file-list.tmp
find / -type b -o -type c 2>/dev/null | sort  > /tmp/device-file-list.tmp
echo "Comparing the current baseline with the last known good configuration." | tee -a /var/log/baseline.log
echo -e \\n | tee -a /var/log/baseline.log
diff /var/log/suid-file-list /tmp/suid-file-list.tmp > /tmp/SUID_BASELINE.tmp
diff /var/log/sgid-file-list /tmp/sgid-file-list.tmp > /tmp/SGID_BASELINE.tmp
diff /var/log/device-file-list /tmp/device-file-list.tmp > /tmp/DEVICE_BASELINE.tmp
if [ -s /tmp/SUID_BASELINE.tmp ]; then
   if [ $(grep -c "^>" /tmp/SUID_BASELINE.tmp) != 0 ]; then
		echo "The following files were detected to have the suid bit added:" | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
		grep "^>" /tmp/SUID_BASELINE.tmp | awk '{ print $2 }' | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
	fi
	if [ $(grep -c "^<" /tmp/SUID_BASELINE.tmp) != 0 ]; then
		echo "The following files were detected to have the suid bit removed:" | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
		grep "^<" /tmp/SUID_BASELINE.tmp | awk '{ print $2 }' | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
	fi
fi
if [ -s /tmp/SGID_BASELINE.tmp ]; then
   if [ $(grep -c "^>" /tmp/SGID_BASELINE.tmp) != 0 ]; then
		echo "The following files were detected to have the sgid bit added:" | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
		grep "^>" /tmp/SGID_BASELINE.tmp | awk '{ print $2 }' | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
	fi
	if [ $(grep -c "^<" /tmp/SGID_BASELINE.tmp) != 0 ]; then
		echo "The following files were detected to have the sgid bit removed:" | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
		grep "^<" /tmp/SGID_BASELINE.tmp | awk '{ print $2 }' | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
	fi
fi
if [ -s /tmp/DEVICE_BASELINE.tmp ]; then
   if [ $(grep -c "^>" /tmp/DEVICE_BASELINE.tmp) != 0 ]; then
		echo "The following device files were detected to have been added:" | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
		grep "^>" /tmp/DEVICE_BASELINE.tmp | awk '{ print $2 }' | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
	fi
	if [ $(grep -c "^<" /tmp/DEVICE_BASELINE.tmp) != 0 ]; then
		echo "The following device files were detected to have removed:" | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
		grep "^<" /tmp/DEVICE_BASELINE.tmp | awk '{ print $2 }' | tee -a /var/log/baseline.log
		echo -e \\n | tee -a /var/log/baseline.log
	fi
fi
rm -f /tmp/*BASELINE.tmp /tmp/*list.tmp
echo "Baseline check completed on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")" | tee -a /var/log/baseline.log
echo -e \\n | tee -a /var/log/baseline.log
echo "####################################################################" | tee -a /var/log/baseline.log
echo -e \\n | tee -a /var/log/baseline.log
chmod 640 /var/log/baseline.log
chown root:root /var/log/baseline.log
STOP_HERE
chmod 700 /etc/cron.weekly/baseline_checker.sh
chown root:root /etc/cron.weekly/baseline_checker.sh
