#!/usr/bin/env bash

# install collectd
apt-get install -y collectd
service collectd stop
rm -f /etc/collectd/collectd.conf
ln -sf /vagrant/collectd/collectd.conf /etc/collectd/collectd.conf

# install  nginx
apt-get install -y nginx
sudo ln -sf /vagrant/nginx/default.conf /etc/nginx/conf.d/default.conf

# install Java 8
if type -p java; then
    echo found java executable in PATH
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME
else
    echo "no java"
    cd /vagrant/vendor
    wget --no-check-certificate https://github.com/aglover/ubuntu-equip/raw/master/equip_java8.sh && bash equip_java8.sh
fi

# install Logstash
cd /vagrant/vendor
if [ ! -f logstash_1.4.2-1-2c0f5a1_all.deb ]; then
    echo "Downloading logstash_1.4.2-1-2c0f5a1_all.deb"
    wget -q --no-check-certificate https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb
fi
#  install Logstash-Contrib
if [ ! -f logstash-contrib_1.4.2-1-efd53ef_all.deb ]; then
    echo "Downloading logstash-contrib_1.4.2-1"
    wget -q --no-check-certificate https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb
fi

sudo dpkg -i logstash_1.4.2-1-2c0f5a1_all.deb
sudo dpkg -i logstash-contrib_1.4.2-1-efd53ef_all.deb
sudo rmdir /etc/logstash/conf.d
sudo ln -s /vagrant/logstash/conf.d /etc/logstash/
sudo ln -s /vagrant/logstash/log /var/log/lgostash

# install Elasticsearch
if [ ! -f elasticsearch-1.3.1.deb ]; then
    echo "Downloading Elasticsearch 1.3.1"
    wget -q --no-check-certificate https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.1.deb
fi
sudo dpkg -i elasticsearch-1.3.1.deb
sudo update-rc.d elasticsearch defaults 95 10

# install Elasticsearch Pugins
sudo /usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/latest
sudo /usr/share/elasticsearch/bin/plugin -i royrusso/elasticsearch-HQ
sudo /usr/share/elasticsearch/bin/plugin -i karmi/elasticsearch-paramedic
sudo /usr/share/elasticsearch/bin/plugin -i mobz/elasticsearch-head

# install Kibana
cd /vagrant/vendor
if [ ! -f kibana-3.1.0.tar.gz]; then
    echo "Downloading Kibana 3.1.0"
    wget -q --no-check-certificate https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz
fi
#
# tar -zxv kibana-3.1.0.tar.gz
sudo cp -Rf /vagrant/vendor/kibana-3.1.0/* /usr/share/nginx/html/
sudo rm /usr/share/nginx/html/config.js
sudo cp /vagrant/kibana/kibana_config.js /usr/share/nginx/html/config.js
cd /var/www
tar zxf /vagrant/kibana-3.0.1.tar.gz
mv kibana-3.0.1/* .
rmdir kibana-3.0.1
cd /var/www/app/dashboards
cp -pf logstash.json default.json

# install Logstash
cd /opt
tar zxf /vagrant/logstash-1.4.1.tar.gz
ln -sf logstash-1.4.1 logstash

# fix permissions
chown -R vagrant.vagrant /opt/logstash*
chown -R vagrant.vagrant /etc/elasticsearch*

#Clean-up
#cd /vagrant rm -rf /vendor/*

# startup
su - vagrant -c /vagrant/start.sh
