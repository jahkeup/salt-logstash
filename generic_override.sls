# Overriding
{% set role = "collector" %}
{% set jar_role = "agent" %}

{% include 'logstash/service.jinja' %}

extend:
  logstash-{{role}}-config:
    file.managed:
      - source: salt://logstash/conf/OVERRIDE.conf