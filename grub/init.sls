#!jinja|yaml

{% from "grub/map.jinja" import grub_settings with context %}

grub:
  pkg.installed:
    - pkgs: {{ grub_settings.pkgs }}

# TODO: Manage /etc/default/grub

{% if grub_settings.superuser != '' and grub_settings.superuser_pbkdf2 != '' %}
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

# TODO: grub2-mkconfig

{% endif %}
