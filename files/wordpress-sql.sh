#!/bin/sh
#info: SQL setup for Wordpress installation

WP_DB="$1"
WP_USER="$2"
WP_PASS="$3"
PASS_FILE="/root/wordpress_sql_login.txt"

# check if script already ran successfully
if [ -f "$PASS_FILE" ]; then
    exit 0
fi

mysql -uroot -e "CREATE DATABASE $WP_DB" || exit 1
mysql -uroot -e "CREATE USER '$WP_USER'@'localhost' identified by '$WP_PASS'" || exit 1
mysql -uroot -e "GRANT ALL PRIVILEGES ON $WP_DB.* TO '$WP_USER'@'localhost'" || exit 1
mysql -uroot -e "FLUSH PRIVILEGES" || exit 1

# save password to root
touch "$PASS_FILE"
chmod 600 "$PASS_FILE"
echo "User: $WP_USER Pass: $WP_PASS" >>"$PASS_FILE"
