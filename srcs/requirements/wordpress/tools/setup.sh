#!/bin/bash

# changes the ownership of the /var/www/inception/ folder to www-data user
# makes sure that the wp-config.php file is in the /var/www/inception/ folder
# downloads the wordpress core files if they are not already there
# installs wordpress if it is not already installed
# sets the admin user and password if they are not already set
# variables are set in the .env file
# penultimate line download and activate the raft theme
# exec $@ runs the next CMD in the Dockerfile.
# In this case: starts the php-fpm7.4 server in the foreground

chown -R www-data:www-data /var/www/inception/

if [ ! -f "/var/www/inception/wp-config.php" ]; then
   mv /tmp/wp-config.php /var/www/inception/
fi

sleep 10

wp --allow-root --path="/var/www/inception/" core download || true

if ! wp --allow-root --path="/var/www/inception/" core is-installed;
then
    wp  --allow-root --path="/var/www/inception/" core install \
        --url=$WP_URL \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL
fi;

if ! wp --allow-root --path="/var/www/inception/" user get $WP_USER;
then
    wp  --allow-root --path="/var/www/inception/" user create \
        $WP_USER \
        $WP_EMAIL \
        --user_pass=$WP_PASSWORD \
        --role=$WP_ROLE
fi;

wp --allow-root --path="/var/www/inception/" theme install inspiro --activate 

exec $@