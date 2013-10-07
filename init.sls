{% set logstash_ver = "1.2.1" %}
{% set logstash_url  = "https://download.elasticsearch.org/logstash/logstash/logstash-" + logstash_ver + "-flatjar.jar" %}
{% set logstash_hash = "md5=863272192b52bccf1fc2cf839a888eaf" %}
{% set logstash_jar = "/opt/logstash/logstash.jar" %}
include:
  - logstash.user

logstash-config-dir:
  file.directory:
    - name: /etc/logstash
    - user: logstash
    - mode: 755
    - require:
      - sls: logstash.user

logstash-bin-dir:
  file.directory:
    - name: /opt/logstash
    - user: logstash
    - mode: 755
    - require:
      - sls: logstash.user

logstash-jar:
  file.managed:
    - name: /opt/logstash/logstash-{{logstash_ver}}.jar
    - source: {{logstash_url}}
    - source_hash: {{logstash_hash}}
    - require:
      - file: logstash-bin-dir
      - pkg: logstash-java
logstash-linked-jar:
  file.symlink:
    - name: /opt/logstash/logstash.jar
    - target: /opt/logstash/logstash-{{logstash_ver}}.jar
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
        java -jar {{logstash_jar}} $@
    - require:
      - pkg: logstash-java
      - file: logstash-jar