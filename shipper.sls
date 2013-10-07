include:
  - logstash

logstash-config:
  file.managed:
    - name: /etc/logstash/logstash.conf
    - source: salt://logstash/conf/shipper.conf
    - replace: False
    - user: logstash
    - require:
      - sls: logstash