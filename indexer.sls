{% set role = "indexer" %}

{% include 'logstash/service.jinja' %}
extend:
  logstash-{{role}}-config:
    file.managed:
      - replace: True