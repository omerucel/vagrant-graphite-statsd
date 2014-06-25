#! /bin/bash

source "/vagrant/vagrant/development.sh"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING BASE SECTION..."
sleep 2
sed -i "s|enabled=1|enabled=0|" /etc/yum/pluginconf.d/fastestmirror.conf

/etc/init.d/iptables stop
chkconfig iptables off
echo "FINISHED BASE SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING REMI SECTION..."
sleep 2
rpm -qa | grep -q epel-release || rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -qa | grep -q remi-release || rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum --enablerepo=remi update -y
echo "FINISHED REMI SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING GIT SECTION..."
sleep 2
yum --enablerepo=remi install -y git-core
echo "FINISHED GIT SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING MYSQL SECTION..."
sleep 2
yum --enablerepo=remi install -y mysql-server mysql-devel
service mysqld stop

cp -f "$MYSQL_CONF_FILE" /etc/my.cnf

chkconfig mysqld on
service mysqld start

mysql -u root -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
echo "FINISHED MYSQL SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING HTTPD SECTION..."
sleep 2
yum --enablerepo=remi install -y httpd
chkconfig httpd on
service httpd restart
echo "FINISHED HTTPD SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING NODEJS SECTION..."
sleep 2
yum --enablerepo=remi install -y nodejs npm
echo "FINISHED NODEJS SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING STATSD SECTION..."
sleep 2
npm install -g statsd
echo "FINISHED STATSD SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING MEMCACHED SECTION..."
sleep 2
yum --enablerepo=remi install -y memcached
chkconfig memcached on
service memcached restart
echo "FINISHED MEMCACHED SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING GRAPHITE SECTION..."
sleep 2
yum --enablerepo=remi install -y mod_python mod_wsgi pycairo python-django15 python-django-tagging python-memcached python-twisted python-ldap python-txamqp bitmap bitmap-fonts MySQL-python pytz pyparsing
mysql -e "CREATE DATABASE graphite;" -u root

mkdir -p /opt/graphite
mkdir -p /opt/carbon
mkdir -p /opt/whisper

git clone https://github.com/graphite-project/graphite-web.git /opt/graphite
git clone https://github.com/graphite-project/carbon.git /opt/carbon
git clone https://github.com/graphite-project/whisper.git /opt/whisper

cd /opt/whisper
python setup.py install
cd /opt/carbon
python setup.py install

cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf
cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf
cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi

cd /opt/graphite
chmod -R 777 storage
chmod 777 /opt/graphite/conf/graphite.wsgi
python setup.py install

cp examples/example-graphite-vhost.conf /etc/httpd/conf.d/graphite-web.conf

cd webapp/graphite
ln -s "${GRAPHITE_SETTINGS}" /opt/graphite/webapp/graphite/local_settings.py
cd /opt/graphite/webapp
python manage.py syncdb --noinput

cd /opt/graphite
./bin/carbon-cache.py start
service httpd restart

echo "FINISHED GRAPHITE SECTION!"
sleep 1

# ----------------------------------------------------------------------------------------------------------------------