{% set role = "web" %}
{% set jar_role = "agent" %}

{% include 'logstash/service.jinja' %}
extend:
  logstash-{{role}}-init-script:
    file.managed:
      - context:
          config: False