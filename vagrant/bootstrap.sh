#! /bin/bash

source "/vagrant/vagrant/development.sh"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING BASE SECTION..."
sed -i "s|enabled=1|enabled=0|" /etc/yum/pluginconf.d/fastestmirror.conf

/etc/init.d/iptables stop
chkconfig iptables off
echo "FINISHED BASE SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING REMI SECTION..."
rpm -qa | grep -q epel-release || rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -qa | grep -q remi-release || rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
echo "FINISHED REMI SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING GIT SECTION..."
yum --enablerepo=remi install -y git-core
echo "FINISHED GIT SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING MYSQL SECTION..."
yum --enablerepo=remi install -y mysql-server mysql-devel
service mysqld stop

cp -f "$MYSQL_CONF_FILE" /etc/my.cnf

chkconfig mysqld on
service mysqld start

mysql -u root -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
mysql -e "CREATE DATABASE graphite;" -u root
mysql -u root -e "GRANT ALL ON graphite.* TO graphite@'localhost' IDENTIFIED BY 'graphite' WITH GRANT OPTION;"
echo "FINISHED MYSQL SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING HTTPD SECTION..."
yum --enablerepo=remi install -y httpd
chkconfig httpd on
service httpd restart
echo "FINISHED HTTPD SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING MEMCACHED SECTION..."
yum --enablerepo=remi install -y memcached
chkconfig memcached on
service memcached restart
echo "FINISHED MEMCACHED SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING GRAPHITE SECTION..."
yum --enablerepo=remi install -y python-devel mod_python mod_wsgi pycairo python-django15 python-django-tagging python-memcached python-twisted python-ldap python-txamqp bitmap bitmap-fonts MySQL-python pytz pyparsing

mkdir -p /opt/graphite
mkdir -p /opt/carbon
mkdir -p /opt/whisper

wget https://github.com/graphite-project/graphite-web/archive/0.9.12.zip -O /opt/graphite.zip
wget https://github.com/graphite-project/carbon/archive/0.9.12.zip -O /opt/carbon.zip
wget https://github.com/graphite-project/whisper/archive/0.9.12.zip -O /opt/whisper.zip

cd /opt
unzip graphite.zip
unzip carbon.zip
unzip whisper.zip

mkdir -p /opt/graphite
mkdir -p /opt/carbon
mkdir -p /opt/whisper

mv /opt/graphite-web-0.9.12/* /opt/graphite/
mv /opt/carbon-0.9.12/* /opt/carbon/
mv /opt/whisper-0.9.12/* /opt/whisper/

rm -rf /opt/graphite-web-0.9.12
rm -rf /opt/carbon-0.9.12
rm -rf /opt/whisper-0.9.12

cd /opt/whisper
python setup.py install
cd /opt/carbon
python setup.py install

cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf
cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf
cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi

chmod -R 777 /opt/graphite/storage
chmod 777 /opt/graphite/conf/graphite.wsgi

cd /opt/graphite
python setup.py install

cp /opt/graphite/examples/example-graphite-vhost.conf /etc/httpd/conf.d/graphite-web.conf
ln -s $GRAPHITE_SETTINGS /opt/graphite/webapp/graphite/local_settings.py

cd /opt/graphite/webapp/graphite
python manage.py syncdb --noinput

cd /opt/graphite/
python ./bin/carbon-cache.py start
service httpd restart
chmod -R 777 /opt/graphite/storage

echo "FINISHED GRAPHITE SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING NODEJS SECTION..."
yum --enablerepo=remi install -y nodejs npm
echo "FINISHED NODEJS SECTION!"

# ----------------------------------------------------------------------------------------------------------------------

echo "STARTING STATSD SECTION..."
npm install -g statsd forever
forever start -a -l /vagrant/log/forever.log -o /vagrant/log/forever-out.log -e /vagrant/log/forever-err.log /usr/bin/statsd /vagrant/vagrant/files/statsd-config.js
echo "FINISHED STATSD SECTION!"

# ----------------------------------------------------------------------------------------------------------------------