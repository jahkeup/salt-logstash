{% set role = "indexer" %}
{% set jar_role = "agent" %}

{% include 'logstash/service.jinja' %}

extend:
  logstash-{{role}}-config:
    file.managed:
      - context:
          redis_host: {{ salt['config.get']('logstash:redis_host', '127.0.0.1') }}