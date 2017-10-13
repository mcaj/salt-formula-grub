#!jinja|yaml

{% from "grub/map.jinja" import grub_settings with context %}

grub:
  pkg.installed:
    - pkgs: {{ grub_settings.lookup.pkgs }}

{% if 'default_grub' in grub_settings.lookup and 'changes' in grub_settings.config %}
update-grub-config:
  augeas.change:
    - context: /files{{ grub_settings.lookup.default_grub }}
    - lens: shellvars.lns
    - changes:
{% for name, value in grub_settings.config.changes.items() %}
      - set {{ name }} "{{ value }}"
{% endfor %}
    - require:
      - pkg: grub
{% endif %}

grub-mkconfig:
  cmd.run:
    - name: test -f {{ grub_settings.lookup.grub_config }}  && grub2-mkconfig -o {{ grub_settings.lookup.grub_config }}
    - watch:
      - augeas: update-grub-config

serial-getty:
  file.append:
    - name: /etc/securetty
    - text:
       - ttyS0

serial-getty@ttyS0:
  service.running:
    - enable: True
