/rw/config/90-usbarmory.rules:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - source: salt://usbarmory-control/sys-usb/90-usbarmory.rules

/rw/config/rc.local:
  file.managed:
    - user: root
    - group: root
    - mode: 0755
    - source: salt://usbarmory-control/sys-usb/rc.local
