#!/bin/bash

# Enable error handling and logging
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting WordPress installation at $(date)"

# Update system
yum update -y

# Install required packages (added missing PHP extensions)
yum install -y httpd php php-mysql php-gd php-xml php-mbstring php-curl php-zip mysql

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download WordPress
cd /var/www/html
echo "Downloading WordPress..."
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
mv wordpress/* .
rmdir wordpress
rm latest.tar.gz

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Create wp-config.php
echo "Configuring WordPress..."
cp wp-config-sample.php wp-config.php

# Configure database connection
sed -i "s/database_name_here/${db_name}/g" wp-config.php
sed -i "s/username_here/${db_username}/g" wp-config.php
sed -i "s/password_here/${db_password}/g" wp-config.php
sed -i "s/localhost/${db_host}/g" wp-config.php

# Generate and replace salts properly
echo "Generating WordPress security keys..."
SALT_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
if [ ! -z "$SALT_KEYS" ]; then
    # Remove existing salt lines and add new ones
    sed -i '/AUTH_KEY/,/NONCE_SALT/d' wp-config.php
    # Insert new salts before the table prefix line
    sed -i "/table_prefix/i\\
$SALT_KEYS\\
" wp-config.php
else
    echo "Warning: Could not generate WordPress salts"
fi

# Wait for database to be available
echo "Waiting for database connection..."
DB_READY=0
ATTEMPTS=0
MAX_ATTEMPTS=30

while [ $DB_READY -eq 0 ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if mysql -h ${db_host} -u ${db_username} -p${db_password} -e "SELECT 1" >/dev/null 2>&1; then
        echo "Database connection successful!"
        DB_READY=1
    else
        echo "Database not ready, attempt $((ATTEMPTS + 1))/$MAX_ATTEMPTS..."
        sleep 10
        ATTEMPTS=$((ATTEMPTS + 1))
    fi
done

if [ $DB_READY -eq 0 ]; then
    echo "ERROR: Could not connect to database after $MAX_ATTEMPTS attempts"
    exit 1
fi

# Create database if it doesn't exist
mysql -h ${db_host} -u ${db_username} -p${db_password} -e "CREATE DATABASE IF NOT EXISTS ${db_name};"

# Create .htaccess for pretty permalinks (escaped for Terraform templating)
cat > /var/www/html/.htaccess << 'HTACCESS_END'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %%{REQUEST_FILENAME} !-f
RewriteCond %%{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
HTACCESS_END

# Configure Apache for WordPress
cat > /etc/httpd/conf.d/wordpress.conf << 'APACHE_CONF_END'
<Directory "/var/www/html">
    AllowOverride All
    Require all granted
</Directory>

# Enable mod_rewrite
LoadModule rewrite_module modules/mod_rewrite.so
APACHE_CONF_END

# Create health check endpoint for ALB
cat > /var/www/html/health.php << 'PHP_END'
<?php
// Health check endpoint for load balancer
$mysqli = new mysqli('${db_host}', '${db_username}', '${db_password}', '${db_name}');

if ($mysqli->connect_error) {
    http_response_code(503);
    echo "FAIL: Database connection error";
    exit();
}

// Check if WordPress tables exist
$result = $mysqli->query("SHOW TABLES LIKE 'wp_posts'");
if ($result && $result->num_rows > 0) {
    http_response_code(200);
    echo "OK: WordPress is healthy";
} else {
    http_response_code(503);
    echo "FAIL: WordPress not fully installed";
}

$mysqli->close();
?>
PHP_END

# Set final permissions
chown -R apache:apache /var/www/html/
find /var/www/html/ -type d -exec chmod 755 {} \;
find /var/www/html/ -type f -exec chmod 644 {} \;

# Restart Apache
systemctl restart httpd

# Install WordPress CLI for easier management (optional but recommended)
echo "Installing WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/master/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Verify installation
echo "WordPress installation completed successfully at $(date)"
echo "Site will be available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/"

# Create installation summary
cat > /var/log/wordpress-install-summary.log << SUMMARY_END
WordPress Installation Summary
==============================
Date: $(date)
Database Host: ${db_host}
Database Name: ${db_name}
Database User: ${db_username}
WordPress Title: ${wp_title}
Admin User: ${wp_admin}
Admin Email: ${wp_email}
Installation Status: Complete
==============================
SUMMARY_END

echo "Installation log saved to /var/log/wordpress-install-summary.log"