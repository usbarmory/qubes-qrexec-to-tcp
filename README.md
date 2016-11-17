# Qubes Split GPG configuration for qubes-gpg-server over TCP

This repository contains [Qubes OS](https://www.qubes-os.org) customizations to
support its [Split GPG](https://www.qubes-os.org/doc/split-gpg/) setup using a
TCP connected qubes-gpg-server.

The scenario is originally created to support Split GPG with the
[USB armory](https://inversepath.com/usbarmory) device acting as GPG server,
however any networked device can be used for this setup.


# Qubes Split GPG architecture

The following diagram illustrates the traditional Split GPG architecture,
implemented with two VMs:
![Qubes Split GPG](https://cdn.rawgit.com/inversepath/qubes-qrexec-to-tcp/master/images/split-gpg.svg)

The qubes-gpg-server over TCP setup replaces the traditional one with the
following architecture which uses two additional VMs, one for controlling the
remote device (e.g. `usbarmory-control`) and one responsible for the TCP bridge
(`qrexec-to-tcp`):

![Qubes Split GPG with USB armory](https://cdn.rawgit.com/inversepath/qubes-qrexec-to-tcp/master/images/qrexec-to-tcp.svg)

# GPG server on the USB armory

## Qubes OS setup

The `qrexec-to-tcp` and `usbarmory-control` directories from this repository
should be copied to `/srv/salt` on dom0, then they should be enabled as
follows:

```
[root@dom0 salt]# qubesctl top.enable qrexec-to-tcp
[root@dom0 salt]# qubesctl top.enable usbarmory-control
[root@dom0 salt]# qubesctl --all state.highstate
```

Three different SSH keys are required for login, GPG client, GPG import and can
be generated as follows:

```
[user@usbarmory-control ~]$ ssh-keygen -f /home/user/.ssh/id_rsa_qubes_ssh
[user@qrexec-to-tcp ~]$ ssh-keygen -f /home/user/.ssh/id_rsa_qubes_gpg
[user@qrexec-to-tcp ~]$ ssh-keygen -f /home/user/.ssh/id_rsa_qubes_import
```

These keys should match the ones passed in the USB armory image build process
(see next section).

## USB armory setup

The public keys can be copied to the VM used to build the USB armory image
(e.g. `build`) as follows:

```
[root@dom0 ~]# qvm-run --pass-io usbarmory-control 'cat /home/user/.ssh/id_rsa_qubes_ssh.pub' > id_rsa_qubes_ssh.pub
[root@dom0 ~]# qvm-run --pass-io qrexec-to-tcp 'cat /home/user/.ssh/id_rsa_qubes_gpg.pub' > id_rsa_qubes_gpg.pub
[root@dom0 ~]# qvm-run --pass-io qrexec-to-tcp 'cat /home/user/.ssh/id_rsa_qubes_import.pub' > id_rsa_qubes_import.pub
[root@dom0 ~]# qvm-copy-to-vm build id_rsa_qubes_*.pub
```

The USB armory image configuration and building should be performed as
illustrated in its specific
[setup guide](https://github.com/inversepath/usbarmory/blob/master/software/buildroot/README-Qubes_Split_GPG.md).

## Operation

Only the very first time the USB armory is plugged in after imaging, from the
`usbarmory-control` VM connect to verify its host key and change default
`usbarmory` password with your own:

```
[user@usbarmory-control ~]$ ssh usbarmory
[gpg@usbarmory]$ change_passphrase
```

For normal use, after plugging in the USB armory, from the `usbarmory-control`
VM set its time and connect to the device to unlock the encrypted partition
holding the GPG keystore:

```
[user@usbarmory-control ~]$ ./set-usbarmory-time.sh
[user@usbarmory-control ~]$ ssh usbarmory
[gpg@usbarmory]$ unlock
```

Configure your GPG client VM (e.g. `work-email`) to use the Split GPG backend,
by setting the `QUBES_GPG_DOMAIN` variable to `qrexec-to-tcp`:

```
[user@work-email ~]$ export QUBES_GPG_DOMAIN="qrexec-to-tcp"
```

It can be tested as follows:

```
[user@work-email ~]$ wget https://keys.qubes-os.org/keys/qubes-master-signing-key.asc
[user@work-email ~]$ qubes-gpg-import qubes-master-signing-key.asc
[user@work-email ~]$ qubes-gpg-client -k
```

All `qubes-gpg-client` operations should now be performed on the USB armory and
its LED notify the user of an upcoming operation, with a delay depending on the
`LED_TIMEOUT` value passed in the USB armory build process.

# Resources

* [Qubes OS Split GPG](https://www.qubes-os.org/doc/split-gpg/)
* [USB armory buildroot environment](https://github.com/inversepath/usbarmory/tree/master/software/buildroot)
