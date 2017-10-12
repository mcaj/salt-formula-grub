#!jinja|yaml

{% from "grub/map.jinja" import grub_settings with context %}

grub:
  pkg.installed:
    - pkgs: {{ grub_settings.lookup.pkgs }}

{% if 'config_file' in grub_settings.lookup and 'changes' in grub_settings.config %}
update-grub-config:
  augeas.change:
    - context: /files{{ grub_settings.lookup.config_file }}
    - lens: shellvars
    - changes:
{% for name, value in grub_settings.config.changes.items() %}
      - set {{ name }} {{ value }}
{% endfor %}
    - require:
      - pkg: grub
{% endif %}

grub-mkconfig:
  cmd.run:
    - name: {{ grub_settings.lookup.update_grub_cmd }}
    - watch:
      - augeas: update-grub-config
