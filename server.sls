{% from 'logstash/map.jinja' import package with context %}
{% from 'logstash/map.jinja' import service with context %}
include:
  - logstash.indexer

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
    - watch:
      - file: logstash-redis-config

logstash-elasticsearch:
  pkg.installed:
    - sources:
      - elasticsearch {{package.elasticsearch}}

# logstash-elasticsearch-service:
#   service.running:
#