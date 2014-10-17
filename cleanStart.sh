#  sudo service collectd stop
#  sudo service nginx stop
#  sudo /etc/init.d/elasticsearch stop

#  1- Stop Logstash
#  pid = 'cat /var/run/logstash.pid'
#  kill -KILL $pid

  sudo service logstash stop

#  2- Delete all existing Logstash Indexes in Elasticsearch
curl -XDELETE 'http://localhost:9200/logstash*'

# 3-  Restart logstash
sudo service logstash start
