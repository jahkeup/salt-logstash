{% from 'logstash/map.jinja' import package with context %}
{% from 'logstash/map.jinja' import service with context %}

include:
  - logstash.indexer

curl:
  pkg:
    - installed
logstash-redis-server:
  pkg.installed:
    - name: {{package.redis}}

logstash-redis-config:
  file.comment:
    - name: /etc/redis/redis.conf
    - regex: ^bind 127\.0\.0\.1$

logstash-redis-service:
  service.running:
    - name: redis-server
    - enable: True
    - require:
      - pkg: logstash-redis-server
      - file: logstash-bin
    - require_in:
      - file: logstash-indexer-config
    - watch:
      - file: logstash-redis-config

logstash-elasticsearch:
  pkg.installed:
    - sources:
      - elasticsearch: {{package.elasticsearch}}

logstash-elasticsearch-service:
  service.running:
    - name: elasticsearch
    - require:
      - pkg: logstash-elasticsearch
      - file: logstash-bin
    - require_in:
      - file: logstash-indexer-config

logstash-elasticsearch-indexing:
  cmd.wait:
    - require:
      - service: logstash-elasticsearch-service
      - pkg: curl
    - watch:
      - pkg: logstash-elasticsearch
    - name: |
          curl -XPUT http://localhost:9200/_template/logstash_per_index -d '{
              "template" : "logstash*",
              "settings" : {
                  "number_of_shards" : 4,
                  "index.cache.field.type" : "soft",
                  "index.refresh_interval" : "5s",
                  "index.store.compress.stored" : true,
                  "index.query.default_field" : "@message",
                  "index.routing.allocation.total_shards_per_node" : 2
              },
              "mappings" : {
                  "_default_" : {
                     "_all" : {"enabled" : false},
                     "properties" : {
                        "@fields" : {
                             "type" : "object",
                             "dynamic": true,
                             "path": "full",
                             "properties" : {
                                 "clientip" : { "type": "ip"}
                             }
                        },
                        "@message": { "type": "string", "index": "analyzed" },
                        "@source": { "type": "string", "index": "not_analyzed" },
                        "@source_host": { "type": "string", "index": "not_analyzed" },
                        "@source_path": { "type": "string", "index": "not_analyzed" },
                        "@tags": { "type": "string", "index": "not_analyzed" },
                        "@timestamp": { "type": "date", "index": "not_analyzed" },
                         "@type": { "type": "string", "index": "not_analyzed" }
                     }
                  }
             }
          }'

logstash-elasticsearch-cluster-config:
  file.sed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - before: '^# cluster.name: elasticsearch$'
    - after: 'cluster.name: logstash'
    - require_in:
      - file: logstash-elasticsearch-node-config
    - watch_in:
      - file: logstash-elasticsearch-service

logstash-elasticsearch-node-config:
  file.sed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - before: '^# node.name: "Franz Kafka"$'
    - after: 'node.name: {{grains.get('host')}}'
    - watch_in:
      - service: logstash-elasticsearch-service