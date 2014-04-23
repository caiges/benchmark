
# Development Tool
sudo yum -y groupinstall "Development Tools"

# Utilities
sudo yum install -y git vim unzip make wget

#Add htop repo
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
rpm -Uhv rpmforge-release*.rf.x86_64.rpm

# Utilities
sudo yum install -y htop




# Server programs
# Mod Security
sudo yum install -y httpd mod_ssl mod_security mysql-server

# Add webtatic (PHP)
sudo rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm

# PHP
sudo yum install -y php55w php55w-common php55w-devel php55w-cli php55w-gd php55w-mcrypt php55w-mbstring php55w-mysql php55w-pecl-memcache php55w-opcache php55w-process php55w-xml

# YOU MUST HAVE THE boxname IN THE /etc/hosts FILE!!!!!

# Add Apache VHosts
sudo bash -c 'echo "Include /opt/bold/conf/development.conf" >> /etc/httpd/conf/httpd.conf'
sudo sed -i 's/ServerSignature On.*/ServerSignature Off/' /etc/httpd/conf/httpd.conf
sudo sed -i 's/ServerTokens OS.*/ServerTokens Off/' /etc/httpd/conf/httpd.conf

# PHP Configs
sudo bash -c 'echo "date.timezone = America/Phoenix" >> /etc/php.ini'
sudo sed -i 's/display_errors = Off.*/display_errors = On/' /etc/php.ini
sudo sed -i 's/E_ALL & ~E_DEPRECATED & ~E_STRICT.*/E_ALL/' /etc/php.ini
sudo sed -i 's/expose_php = on.*/expose_php = off/' /etc/php.ini

# Install composer
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Add PHP Unit
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit





# GEARMAN
# http://www.usamurai.com/2013/05/01/install-gearman-from-source-in-centos/
# http://www.syn-ack.org/centos-linux/installing-gearman-on-centos-6-2/
sudo yum -y install uuid-devel libuuid libuuid-devel uuid boost-devel libevent libevent-devel
sudo yum -y install gcc-c++ mysql-devel gperf

cd /tmp
wget https://launchpad.net/gearmand/1.2/1.1.12/+download/gearmand-1.1.12.tar.gz

tar -xvzf gearmand-1.1.12.tar.gz
cd gearmand-1.1.12

CFLAGS=-std=gnu99 ./configure && make && sudo make install

# Install PHP extension
sudo pecl install gearman
sudo bash -c 'echo "extension=gearman.so" >> /etc/php.ini'



# IPTables
sudo /sbin/iptables -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo /sbin/iptables -A INPUT -m state --state NEW -p tcp --dport 3306 -j ACCEPT

# Start everything
sudo service mysqld start
sudo service httpd start
sudo gearmand -d

sudo /etc/init.d/iptables stop

sudo chkconfig mysqld on
sudo chkconfig httpd on
sudo chkconfig iptables off



# Add hosts
sudo bash -c 'echo "127.0.0.1 transaction.bold" > /etc/hosts'
sudo bash -c 'echo "127.0.0.1 portal.bold" > /etc/hosts'
sudo bash -c 'echo "127.0.0.1 admin.bold" > /etc/hosts'
sudo bash -c 'echo "127.0.0.1 bold.mysql" > /etc/hosts'
sudo bash -c 'echo "127.0.0.1 gearmanui.bold" > /etc/hosts'
sudo bash -c 'echo "127.0.0.1 bold.gearman_transactions" > /etc/hosts'
sudo bash -c 'echo "127.0.0.1 bold.gearman_notifications" > /etc/hosts'


# Setup Root Password
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root';"

# Create Databases
mysql -uroot -proot -e "CREATE database accounts"
mysql -uroot -proot -e "CREATE database accounting"
mysql -uroot -proot -e "CREATE database bank"
mysql -uroot -proot -e "CREATE database logs"

mysql -uroot -proot -e "CREATE database gearman_transauth"
mysql -uroot -proot -e "CREATE database gearman_transauth_sl"
mysql -uroot -proot -e "CREATE database gearman_notifications"
mysql -uroot -proot -e "CREATE database gearman_notifications_sl"





# FOR TESTING, node is async for pushing alot of transactions

# Add node repo
cd /usr/share/
sudo curl -O http://download-i2.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
sudo rpm -ivh epel-release-6-8.noarch.rpm

sudo yum install -y npm
