include:
  - qvm.sys-usb

qrexec-to-tcp:
  qvm.vm:
    - present:
      - template: fedora-23
      - label: orange
    - prefs:
      - netvm: sys-usb
    - require:
      - qvm: sys-usb
