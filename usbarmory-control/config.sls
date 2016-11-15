/home/user/.ssh/config:
  file.managed:
    - user: user
    - group: user
    - mode: 0644
    - makedirs: true
    - source: salt://usbarmory-control/config

/home/user/set-usbarmory-time.sh:
  file.managed:
    - user: user
    - group: user
    - mode: 0755
    - source: salt://usbarmory-control/set-usbarmory-time.sh
