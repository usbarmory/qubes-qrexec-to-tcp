/usr/local/etc/qubes-rpc/qubes.Gpg:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - makedirs: true
    - source: salt://qrexec-to-tcp/qubes.Gpg

/usr/local/etc/qubes-rpc/qubes.GpgImportKey:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - makedirs: true
    - source: salt://qrexec-to-tcp/qubes.GpgImportKey
