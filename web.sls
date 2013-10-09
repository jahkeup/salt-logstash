{% set role = "web" %}

{% include 'logstash/service.jinja' %}
extend:
  logstash-{{role}}-init-script:
    file.managed:
      - context:
          config: False
          jar_role: web