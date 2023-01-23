#!/bin/sh
#info: Show packages that have most CVE's, Debian 10,11 (not Ubuntu)

if [ -z "$(command -v debsecan)" ]; then
	echo "debsecan is not installed. Install to make this script work."
	exit 1
fi

#todo: add debcvescan support

# fist scan
PACKAGES_COUNT=$(debsecan | awk '{print $2}')
PACKAGES=$(echo "$PACKAGES_COUNT" | sort | uniq)

# sort by CVE count
PACKAGES_SCANNED=$(
	for i in $PACKAGES; do
		CVE=$(echo "$PACKAGES_COUNT" | grep -cx "$i")
		echo "$CVE $i"
	done
)

# show only top 10 insecure programs
#todo: echo "To improve security, consider removing some of these packages:"
echo "$PACKAGES_SCANNED" | sed -e "/^.\s/d" | sort -rV
