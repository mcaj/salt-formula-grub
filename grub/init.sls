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

{% if 'superuser' in grub_settings and grub_settings.superuser != '' and 'superuser_pbkdf2' in grub_settings and grub_settings.superuser_pbkdf2 != '' %}
/etc/grub.d/99_salt:
  file.managed:
    - source: salt://grub/files/99_salt
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - context:
      superuser: {{ grub_settings.superuser }}
      superuser_pbkdf2: {{ grub_settings.superuser_pbkdf2 }}
    - require:
      - pkg: grub
    - watch_in:
      - cmd: grub-mkconfig
{% endif %}

grub-mkconfig:
  cmd.run:
    - name: {{ grub_settings.lookup.update_grub_cmd }}
    - watch:
      - augeas: update-grub-config
