#!jinja|yaml

{% from "grub/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('grub:lookup')) %}

grub:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}

{% if 'default_config' in datamap.config.manage|default([]) %}
  {% set f_gdc = datamap.config.default_config|default({}) %}
default_config:
  file:
    - managed
    - name: {{ f_gdc.path }}
    - mode: {{ f_gdc.mode|default('444') }}
    - user: {{ f_gdc.user|default('root') }}
    - group: {{ f_gdc.group|default('root') }}
    - contents_pillar: grub:default_config:content
  cmd:
    - wait
    - name: {{ datamap.update_grub_cmd }}
    - watch:
      - file: default_config
{% endif %}
