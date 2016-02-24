#!/usr/bin/env bash

mkdir -p /vagrant/vendor
######### install collectd
sudo apt-get install -y collectd
sudo service collectd stop
ln -sf /vagrant/collectd/collectd.conf /etc/collectd/collectd.conf

######### install  nginx
sudo apt-get install -y nginx
sudo ln -sf /vagrant/nginx/default.conf /etc/nginx/conf.d/default.conf
sudo ln -sf /vagrant/nginx/log/ /var/log/nginx

########## install Java 8
if type -p java; then
    echo found java executable in PATH
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME
else
    echo "no java"
    cd /vagrant/vendor
    wget --no-check-certificate https://github.com/aglover/ubuntu-equip/raw/master/equip_java8.sh && bash equip_java8.sh
fi

######## install Logstash
cd /vagrant/vendor
if [ ! -f logstash_1.4.2-1-2c0f5a1_all.deb ]; then
    echo "Downloading logstash_1.4.2-1-2c0f5a1_all.deb"
    wget -q --no-check-certificate https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb
fi
###### install Logstash-Contrib
if [ ! -f logstash-contrib_1.4.2-1-efd53ef_all.deb ]; then
    echo "Downloading logstash-contrib_1.4.2-1"
    wget -q --no-check-certificate https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb
fi

sudo dpkg -i logstash_1.4.2-1-2c0f5a1_all.deb
sudo dpkg -i logstash-contrib_1.4.2-1-efd53ef_all.deb

sudo rm -rf /etc/logstash/conf.d
sudo ln -sf /vagrant/logstash/conf.d /etc/logstash/
sudo ln -sf /vagrant/logstash/log /var/log/logstash

####### install Elasticsearch
if [ ! -f elasticsearch-1.3.4.deb ]; then
    echo "Downloading Elasticsearch 1.3.4"
    wget -q --no-check-certificate https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.4.deb
fi
sudo dpkg -i elasticsearch-1.3.4.deb
sudo update-rc.d elasticsearch defaults 95 10
sudo rm /etc/elasticsearch/*.yml
sudo ln -sf /vagrant/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sudo ln -sf /vagrant/elasticsearch/logging.yml /etc/elasticsearch/logging.yml

###### install Elasticsearch Pugins
sudo /usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/latest
sudo /usr/share/elasticsearch/bin/plugin -i royrusso/elasticsearch-HQ
sudo /usr/share/elasticsearch/bin/plugin -i karmi/elasticsearch-paramedic
sudo /usr/share/elasticsearch/bin/plugin -i mobz/elasticsearch-head

###### Install Kibana
cd /vagrant/vendor
# Download if it does not exist
if [ ! -f kibana-3.1.1.tar.gz ]; then
    echo "Downloading Kibana 3.1.1"
    wget -q --no-check-certificate https://download.elasticsearch.org/kibana/kibana/kibana-3.1.1.tar.gz
fi
# Unzip and copy to webserver dir
tar zxf /vagrant/vendor/kibana-3.1.1.tar.gz
sudo rm -rf /usr/share/nginx/html/app/dashboards
sudo cp -Rf /vagrant/vendor/kibana-3.1.1/* /usr/share/nginx/html/
sudo ln -s /vagrant/kibana/dashboards /usr/share/nginx/html/app/dashboards

##### install Logstash
## Commented out since it is already installed earlier in the script
#cd /opt
#sudo tar zxf /vagrant/vendor/logstash-1.4.1.tar.gz
#sudo ln -sf logstash-1.4.1 logstash

# fix permissions
sudo chown -R vagrant.vagrant /opt/logstash*
sudo chown -R vagrant.vagrant /etc/elasticsearch*

#Clean-up
#cd /vagrant rm -rf /vendor/*

# startup
su - vagrant -c /vagrant/start.sh
