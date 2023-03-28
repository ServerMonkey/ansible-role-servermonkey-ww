#!/bin/sh
#info: Configure the Debian sources list, for KALI .
#arg: back,prop,exp,local,cdrom,offline
#arginfo: Additionally enable custom repos, like proposed and/or experimental
#autoroot

# must run as root
# skip on windows
if [ -n "$(command -v systeminfo)" ]; then
	echo "Skipping cfg_apt: Windows is not supported"
	exit 0
# posix
else
	if [ "$(id -u)" -ne 0 ]; then
		echo 'This script must be run as root!' >&2
		exit 1
	fi
fi

OS=$(grep "^NAME=" </etc/os-release | sed 's/"//g' | cut -d'=' -f 2 |
	awk '{print $1}')
CODENAME=$(grep "^VERSION_CODENAME=" </etc/os-release | cut -d'=' -f 2 |
	sed 's|\x27||g' | sed 's|\x22||g')
SRC="/etc/apt/sources.list"
REPOS="main contrib non-free"
EXTRA_REPOS="$1"

# don't allow more than one argument/parameter
if [ -n "${2}" ]; then
	echo "Only enter one continues parameter, like: pro,exp,local"
	exit 1
fi

info_na_os() {
	echo "Skipping cfg_apt: unsupported OS '$OS'"
	exit 0
}

info_na_rel() {
	echo "Skipping cfg_apt: unsupported OS '$OS' with release '$CODENAME'"
	exit 0
}

#todo: add a ping src host test function

# set variables to the most stable release
case $OS in
Debian)
	case $CODENAME in
	buster)
		REPO="deb http://deb.debian.org/debian"
		REPO_SEC="deb http://security.debian.org/debian-security/"
		REPO_SEC_SUFFIX="/updates"
		;;
	bullseye)
		REPO="deb http://deb.debian.org/debian"
		REPO_SEC="$REPO-security/"
		REPO_SEC_SUFFIX="-security"
		;;
	*)
		info_na_rel
		;;
	esac
	;;
Kali)
	case $CODENAME in
	kali-rolling)
		REPO="deb http://http.kali.org/kali"
		REPO_SEC="kali"
		# use the proposed arg for rolling
		if echo "$EXTRA_REPOS" | grep -q "prop"; then
			REPO_SEC_SUFFIX="-rolling"
		# more stable
		else
			REPO_SEC_SUFFIX="last-snapshot"
		fi
		;;
	*)
		info_na_rel
		;;
	esac
	;;
Raspbian)
	case $CODENAME in
	buster)
		info_na_rel
		;;
	bullseye)
		info_na_rel
		;;
	*)
		info_na_rel
		;;
	esac
	;;
*)
	info_na_os
	;;
esac

# add repos
case $OS in
Raspbian)
	info_na_os
	;;
Debian)
	case $CODENAME in
	buster | bullseye)
		# remove old configuration and add ansible header
		echo "# BEGIN - cfg_apt" >$SRC
		#
		# offline
		if echo "$EXTRA_REPOS" | grep -q "offline"; then
			# skip adding any repos in offline mode
			:
		# online/default
		else
			# mainline
			# shellcheck disable=SC2129
			echo "$REPO $CODENAME $REPOS" >>$SRC
			# security upgrades
			echo "$REPO_SEC $CODENAME$REPO_SEC_SUFFIX $REPOS" >>$SRC
			# upgrades
			echo "$REPO $CODENAME-updates $REPOS" >>$SRC
			# backports
			if echo "$EXTRA_REPOS" | grep -q "back"; then
				echo "$REPO $CODENAME-backports $REPOS" >>$SRC
			fi
			# proposed
			if echo "$EXTRA_REPOS" | grep -q "prop"; then
				echo "$REPO $CODENAME-proposed-updates $REPOS" >>$SRC
			fi
			# experimental
			if echo "$EXTRA_REPOS" | grep -q "exp"; then
				echo "$REPO experimental $REPOS" >>$SRC
			fi
		fi
		#
		# local
		if echo "$EXTRA_REPOS" | grep -q "local"; then
			#todo: make this compatible with local-apt-repository
			REPO_OFF="/opt/packages/"
			mkdir -p $REPO_OFF || exit 1
			touch "$REPO_OFF"Packages
			echo "deb [trusted=yes] file://$REPO_OFF ./" >>$SRC
		fi
		#
		# cdrom
		if echo "$EXTRA_REPOS" | grep -q "cdrom"; then
			# verify cdrom device
			blkid "/dev/cdrom" >/dev/null
			# shellcheck disable=SC2181
			if [ "$?" != 0 ]; then
				echo "Skipping cfg_apt for 'cdrom': No hardware device found"
			else
				REPO_CDROM="/media/cdrom-apt-repo-$CODENAME/"

				# add repo
				mkdir -p "$REPO_CDROM" || exit 1
				echo "deb [trusted=yes] file://$REPO_CDROM $CODENAME $REPOS" >>$SRC || exit 1

				# automount on boot
				if ! grep -q "/dev/cdrom" </etc/fstab; then
					# shellcheck disable=SC2129
					echo "# BEGIN - CDROM" >>/etc/fstab
					echo "/dev/cdrom $REPO_CDROM iso9660 ro,user,auto 0 0" >>/etc/fstab
					echo "# END - CDROM" >>/etc/fstab
				fi

				# manual mount now
				findmnt "$REPO_CDROM" 1>/dev/null
				# shellcheck disable=SC2181
				if [ "$?" != 0 ]; then
					mount -o ro /dev/cdrom "$REPO_CDROM"
				fi

				# verify
				findmnt "$REPO_CDROM" 1>/dev/null
				# shellcheck disable=SC2181
				if [ "$?" != 0 ]; then
					echo "failed to mount $REPO_CDROM"
					exit 1
				fi
			fi
		fi
		#
		# close ansible header
		echo "# END - cfg_apt" >>$SRC
		;;
	esac
	;;
Kali)
	case $CODENAME in
	kali-rolling)
		# remove old configuration and add ansible header
		echo "# BEGIN - cfg_apt" >$SRC
		#
		# offline
		if echo "$EXTRA_REPOS" | grep -q "offline"; then
			# don't update kali in offline mode
			echo "# Kali repos are not avaliable in offline mode" >>$SRC
		#
		# online/default
		else
			# mainline
			# shellcheck disable=SC2129
			echo "$REPO $CODENAME $REPOS" >>$SRC
		fi
		#
		# close ansible header
		echo "# END - cfg_apt" >>$SRC
		;;
	esac
	;;
esac

# force update, fixes bugs
apt-get update -qqy
