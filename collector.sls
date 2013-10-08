{% set role = "collector" %}
{% set jar_role = "agent" %}
{% set source = 'default' %}

{% include 'logstash/service.jinja' %}