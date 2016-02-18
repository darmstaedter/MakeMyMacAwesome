#!/bin/sh

## XCode Commandline Tools
xcode-select --install

## Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Install ruby 2.3.0
brew install rbenv ruby-build

echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile

rbenv install 2.3.0
rbenv global 2.3.0

## Install rails 4.2.5.1
gem install rails -v 4.2.5.1
rbenv rehash

## Install Homebrew Cask
brew install caskroom/cask/brew-cask

## Install Software
brew install git

brew install node --without-npm
echo prefix=~/.npm-packages >> ~/.npmrc
curl -L https://www.npmjs.com/install.sh | sh
echo 'export PATH="$HOME/.npm-packages/bin:$PATH"' >> ~/.bash_profile

brew install youtube-dl
brew cask install google-chrome
brew cask install postgres
brew cask install skype
brew cask install slack
brew cask install sketch sketch-tool sketch-toolbox
brew cask install tower
brew cask install transmit
brew cask install sequel-pro
brew cask install iterm2
brew cask install firefox
brew cask install vlc
brew cask install coda
brew cask install keka
brew cask install adobe-creative-cloud
brew cask install sqlitebrowser

## Install Atom
brew cask install atom
apm install `curl -fsSL https://raw.githubusercontent.com/Darmstaedter/MakeMyMacAwesome/master/atom_packages.list`

## Install Private Scripts
brew tap sewolt/sewolt git@bitbucket.org:darmstaedter/sewolt-homebrew.git
brew install sewolt


source ~/.bash_profile



gem install jekyll
npm install --global gulp-cli

# Install Webserver
# From https://echo.co/blog/os-x-1010-yosemite-local-development-environment-apache-php-and-mysql-homebrew

# MySQL
brew install -v mysql
cp -v $(brew --prefix mysql)/support-files/my-default.cnf $(brew --prefix)/etc/my.cnf
cat >> $(brew --prefix)/etc/my.cnf <<'EOF'

# Echo & Co. changes
max_allowed_packet = 1073741824
innodb_file_per_table = 1
EOF

sed -i '' 's/^#[[:space:]]*\(innodb_buffer_pool_size\)/\1/' $(brew --prefix)/etc/my.cnf

brew tap homebrew/services
brew services start mysql

# Apache
sudo launchctl unload /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
brew tap homebrew/dupes
brew install -v homebrew/apache/httpd22 --with-brewed-openssl --with-mpm-event
brew install -v homebrew/apache/mod_fastcgi --with-brewed-httpd22
sed -i '' '/fastcgi_module/d' $(brew --prefix)/etc/apache2/2.2/httpd.conf

(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; export MODFASTCGIPREFIX=$(brew --prefix mod_fastcgi) ; cat >> $(brew --prefix)/etc/apache2/2.2/httpd.conf <<EOF

# Echo & Co. changes

# Load PHP-FPM via mod_fastcgi
LoadModule fastcgi_module    ${MODFASTCGIPREFIX}/libexec/mod_fastcgi.so

<IfModule fastcgi_module>
  FastCgiConfig -maxClassProcesses 1 -idle-timeout 1500

  # Prevent accessing FastCGI alias paths directly
  <LocationMatch "^/fastcgi">
    <IfModule mod_authz_core.c>
      Require env REDIRECT_STATUS
    </IfModule>
    <IfModule !mod_authz_core.c>
      Order Deny,Allow
      Deny from All
      Allow from env=REDIRECT_STATUS
    </IfModule>
  </LocationMatch>

  FastCgiExternalServer /php-fpm -host 127.0.0.1:9000 -pass-header Authorization -idle-timeout 1500
  ScriptAlias /fastcgiphp /php-fpm
  Action php-fastcgi /fastcgiphp

  # Send PHP extensions to PHP-FPM
  AddHandler php-fastcgi .php

  # PHP options
  AddType text/html .php
  AddType application/x-httpd-php .php
  DirectoryIndex index.php index.html
</IfModule>

# Include our VirtualHosts
Include ${USERHOME}/Repositories/httpd-vhosts.conf
EOF
)

mkdir -pv ~/Repositories/{logs,ssl}
touch ~/Repositories/httpd-vhosts.conf

(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; cat > ~/Repositories/httpd-vhosts.conf <<EOF
#
# Listening ports.
#
#Listen 8080  # defined in main httpd.conf
Listen 8443

#
# Use name-based virtual hosting.
#
NameVirtualHost *:8080
NameVirtualHost *:8443

#
# Set up permissions for VirtualHosts in ~/Repositories
#
<Directory "${USERHOME}/Repositories">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <IfModule mod_authz_core.c>
        Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </IfModule>
</Directory>

# For http://localhost in the users' Repositories folder
<VirtualHost _default_:8080>
    ServerName localhost
    DocumentRoot "${USERHOME}/Repositories"
</VirtualHost>
<VirtualHost _default_:8443>
    ServerName localhost
    Include "${USERHOME}/Repositories/ssl/ssl-shared-cert.inc"
    DocumentRoot "${USERHOME}/Repositories"
</VirtualHost>

#
# VirtualHosts
#

## Manual VirtualHost template for HTTP and HTTPS
#<VirtualHost *:8080>
#  ServerName project.dev
#  CustomLog "${USERHOME}/Repositories/logs/project.dev-access_log" combined
#  ErrorLog "${USERHOME}/Repositories/logs/project.dev-error_log"
#  DocumentRoot "${USERHOME}/Repositories/project.dev"
#</VirtualHost>
#<VirtualHost *:8443>
#  ServerName project.dev
#  Include "${USERHOME}/Repositories/ssl/ssl-shared-cert.inc"
#  CustomLog "${USERHOME}/Repositories/logs/project.dev-access_log" combined
#  ErrorLog "${USERHOME}/Repositories/logs/project.dev-error_log"
#  DocumentRoot "${USERHOME}/Repositories/project.dev"
#</VirtualHost>

#
# Automatic VirtualHosts
#
# A directory at ${USERHOME}/Repositories/webroot can be accessed at http://webroot.dev
# In Drupal, uncomment the line with: RewriteBase /
#

# This log format will display the per-virtual-host as the first field followed by a typical log line
LogFormat "%V %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combinedmassvhost

# Auto-VirtualHosts with .dev
<VirtualHost *:8080>
  ServerName dev
  ServerAlias *.dev

  CustomLog "${USERHOME}/Repositories/logs/dev-access_log" combinedmassvhost
  ErrorLog "${USERHOME}/Repositories/logs/dev-error_log"

  VirtualDocumentRoot ${USERHOME}/Repositories/%-2+
</VirtualHost>
<VirtualHost *:8443>
  ServerName dev
  ServerAlias *.dev
  Include "${USERHOME}/Repositories/ssl/ssl-shared-cert.inc"

  CustomLog "${USERHOME}/Repositories/logs/dev-access_log" combinedmassvhost
  ErrorLog "${USERHOME}/Repositories/logs/dev-error_log"

  VirtualDocumentRoot ${USERHOME}/Repositories/%-2+
</VirtualHost>
EOF
)

(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; cat > ~/Repositories/ssl/ssl-shared-cert.inc <<EOF
SSLEngine On
SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW
SSLCertificateFile "${USERHOME}/Repositories/ssl/selfsigned.crt"
SSLCertificateKeyFile "${USERHOME}/Repositories/ssl/private.key"
EOF
)

openssl req \
  -new \
  -newkey rsa:2048 \
  -days 3650 \
  -nodes \
  -x509 \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=$(whoami)/CN=*.dev" \
  -keyout ~/Repositories/ssl/private.key \
  -out ~/Repositories/ssl/selfsigned.crt

brew services start httpd22

sudo bash -c 'export TAB=$'"'"'\t'"'"'
cat > /Library/LaunchDaemons/co.echo.httpdfwd.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
${TAB}<key>Label</key>
${TAB}<string>co.echo.httpdfwd</string>
${TAB}<key>ProgramArguments</key>
${TAB}<array>
${TAB}${TAB}<string>sh</string>
${TAB}${TAB}<string>-c</string>
${TAB}${TAB}<string>echo "rdr pass proto tcp from any to any port {80,8080} -> 127.0.0.1 port 8080" | pfctl -a "com.apple/260.HttpFwdFirewall" -Ef - &amp;&amp; echo "rdr pass proto tcp from any to any port {443,8443} -> 127.0.0.1 port 8443" | pfctl -a "com.apple/261.HttpFwdFirewall" -Ef - &amp;&amp; sysctl -w net.inet.ip.forwarding=1</string>
${TAB}</array>
${TAB}<key>RunAtLoad</key>
${TAB}<true/>
${TAB}<key>UserName</key>
${TAB}<string>root</string>
</dict>
</plist>
EOF'

sudo launchctl load -Fw /Library/LaunchDaemons/co.echo.httpdfwd.plist

brew install -v homebrew/php/php70

(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; sed -i '-default' -e 's|^;\(date\.timezone[[:space:]]*=\).*|\1 \"'$(sudo systemsetup -gettimezone|awk -F"\: " '{print $2}')'\"|; s|^\(memory_limit[[:space:]]*=\).*|\1 2G|; s|^\(post_max_size[[:space:]]*=\).*|\1 2G|; s|^\(upload_max_filesize[[:space:]]*=\).*|\1 2G|; s|^\(default_socket_timeout[[:space:]]*=\).*|\1 600|; s|^\(max_execution_time[[:space:]]*=\).*|\1 300|; s|^\(max_input_time[[:space:]]*=\).*|\1 600|; $a\'$'\n''\'$'\n''; PHP Error log\'$'\n''error_log = '$USERHOME'/Repositories/logs/php-error_log'$'\n' $(brew --prefix)/etc/php/7.0/php.ini)
chmod -R ug+w $(brew --prefix php70)/lib/php

brew install -v php70-opcache

/usr/bin/sed -i '' "s|^\(\;\)\{0,1\}[[:space:]]*\(opcache\.enable[[:space:]]*=[[:space:]]*\)0|\21|; s|^;\(opcache\.memory_consumption[[:space:]]*=[[:space:]]*\)[0-9]*|\1256|;" $(brew --prefix)/etc/php/7.0/php.ini

brew services start php70


# DNSMasq
brew install -v dnsmasq
echo 'address=/.dev/127.0.0.1' > $(brew --prefix)/etc/dnsmasq.conf
echo 'listen-address=127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
echo 'port=35353' >> $(brew --prefix)/etc/dnsmasq.conf
brew services start dnsmasq
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dev'
sudo bash -c 'echo "port 35353" >> /etc/resolver/dev'




# Secure MySQL
(brew --prefix mysql)/bin/mysql_secure_installation
