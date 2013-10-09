# Overriding Example
{% set role = "collector" %}

{% include 'logstash/service.jinja' %}

extend:
  logstash-{{role}}-config:
    file.managed:
      - source: salt://logstash/conf/OVERRIDE.conf