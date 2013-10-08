{% from "logstash/map.jinja" import logstash with context %}
{% set logstash_url  = "https://download.elasticsearch.org/logstash/logstash/logstash-" + logstash.version + "-flatjar.jar" %}

logstash-config-dir:
  file.directory:
    - name: /etc/logstash
    - user: logstash
    - mode: 755

logstash-bin-dir:
  file.directory:
    - name: /opt/logstash
    - user: logstash
    - mode: 755

logstash-jar:
  file.managed:
    - name: /opt/logstash/logstash-{{logstash.version}}.jar
    - source: {{logstash_url}}
    - source_hash: {{logstash.jar_hash}}
    - require:
      - file: logstash-bin-dir
      - pkg: logstash-java

logstash-linked-jar:
  file.symlink:
    - name: /opt/logstash/logstash.jar
    - target: /opt/logstash/logstash-{{logstash.version}}.jar
    - force: True
    - require:
      - file: logstash-jar

logstash-java:
  pkg.installed:
    - name: openjdk-7-jdk

logstash-bin:
  file.managed:
    - name: /usr/local/bin/logstash
    - mode: 555
    - user: logstash
    - contents: |
        #!/usr/bin/env sh
        java -jar {{logstash.jar}} $@
    - require:
      - pkg: logstash-java
      - file: logstash-jar