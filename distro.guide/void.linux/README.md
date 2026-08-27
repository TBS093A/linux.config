# Void Linux

```bash
                __.;=====;.__                   @void.node.00
            _.=+==++=++=+=+===;.                --------------------
             -=+++=+===+=+=+++++=_              OS: Void Linux x86_64
        .     -=:``     `--==+=++==.            Host: VirtualBox 1.2
       _vi,    `            --+=++++:           Kernel: 5.19.10_1
      .uvnvi.       _._       -==+==+.          Uptime: 13 mins
     .vvnvnI`    .;==|==;.     :|=||=|.         Packages: 181 (xbps-query)
+QmQQmpvvnv; _yYsyQQWUUQQQm #QmQ#:QQQWUV$QQm.   Shell: zsh 5.9
 -QQWQWpvvowZ?.wQQQE==<QWWQ/QWQW.QQWW(: jQWQE   Resolution: 640x480
  -$QQQQmmU'  jQQQ@+=<QWQQ)mQQQ.mQQQC+;jWQQ@'   Terminal: /dev/pts/10
   -$WQ8YnI:   QWQQwgQQWV`mWQQ.jQWQQgyyWW@!
     -1vvnvv.     `~+++`        ++|+++
      +vnvnnv,                 `-|===
       +vnvnvns.           .      :=-
        -Invnvvnsi..___..=sv=.     `
          +Invnvnvnnnnnnnnvvnn;.
            ~|Invnvnvvnvvvnnv}+`
               -~|{*l}*|~
```

## Installation

### Partition Reloc

#### DOS (BIOS)

- [ ] 2g mounted on /boot/efi as vfat (fat32) (linux extended boot)
- [ ] 1g mounted on swap as swap (linux swap / solaris)
- [ ] 47g moounted on / as ext4 (linux)

***boot must be first in disk table definition***

#### GPT (UEFI)

- [ ] 2g mounted on /boot/efi as vfat (fat32)
- [ ] 1g mounted on swap as swap
- [ ] 47g moounted on / as ext4

***boot must be first in disk table definition***

### XBPS Package Manager

https://docs.voidlinux.org/xbps/index.html

it looks like ```arch``` linux:

```bash
xbps-install -S <package>
```

update / upgrade:

```bash
xbps-install -Syu
```

delete package:

```bash
xbps-remove -of <package>
```

#### Creating A Mirror

https://docs.voidlinux.org/xbps/repositories/mirrors/index.html

If you'd like to set up a mirror, and are confident you can keep it reasonably up-to-date, follow one of the many guides available for mirroring with rsync(1) (https://man.voidlinux.org/rsync.1), then submit a pull request to the void-docs (https://github.com/void-linux/void-docs) repository to add your mirror to the appropriate mirror table on this page.

A full mirror requires around 1TB of storage. It is also possible to mirror only part of the repositories. Excluding debug packages is one way of decreasing the load on the Tier 1 mirrors, with low impact on users.

Please keep in mind that we pay bandwidth for all data sent out from the Tier 1 mirrors. You can respect this by only mirroring if your use case for your mirror will offset the network throughput consumed by your mirror syncing.

### Managing Services

(https://docs.voidlinux.org/config/services/index.html#managing-services)

basic usage of ```sv``` services manager:

```bash
sv up <services>
sv down <services>
sv restart <services>
sv status <services>
```

The <services> placeholder can be:
  - Service names (service directory names) inside the /var/service/ directory.
  - The full paths to the services.


for instance:

```bash
sv status dhcpcd
sv status /var/service/*
```

#### Enabling Services

Void Linux provides service directories for most daemons in /etc/sv/.

To enable a service on a booted system, create a symlink to the service directory in /var/service/:

```bash
ln -s /etc/sv/<service> /var/service/
```

If the system is not currently running, the service can be linked directly into the default runsvdir:

```bash
ln -s /etc/sv/<service> /etc/runit/runsvdir/default/
```

This will automatically start the service. Once a service is linked it will always start on boot and restart if it stops, unless administratively downed.

To prevent a service from starting at boot while allowing runit to manage it, create a file named down in its service directory:

```bash
touch /etc/sv/<service>/down
```

The down file mechanism also makes it possible to disable services that are enabled by default, such as the agetty(8) (https://man.voidlinux.org/agetty.8) services for ttys 1 to 6. This way, package updates which affect these services (in this case, the runit-void package) won't re-enable them.

#### Disabling Services

To disable a service, remove the symlink from the running runsvdir:

```bash
rm /var/service/<service>
```

Or, for example, from the default runsvdir, if either the specific runsvdir, or the system, is not currently running:

```bash
rm /etc/runit/runsvdir/default/<service>
```

#### Testing Services

To check if a service is working correctly when started by the service supervisor, run it once before fully enabling it:

```bash
touch /etc/sv/<service>/down
ln -s /etc/sv/<service> /var/service/
sv once <service>
```

If everything works, remove the down file to enable the service.
