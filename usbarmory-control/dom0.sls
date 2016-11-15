include:
  - qvm.sys-usb

usbarmory-control:
  qvm.vm:
    - present:
      - template: fedora-23
      - label: green
    - prefs:
      - netvm: sys-usb
    - require:
      - qvm: sys-usb
