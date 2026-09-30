# macOS Device Notes

## Prevent a UGREEN USB Switcher From Mounting a Drive

Find the mounted drive's volume UUID:

```bash
diskutil info /Volumes/NO\ NAME
```

Open `/etc/fstab` and add an entry with that UUID:

```bash
sudo vifs
```

```fstab
UUID=YOUR-VOLUME-UUID-HERE none auto rw,noauto
```

Unplug and reconnect the switcher. If the drive still mounts, flush the mount cache before reconnecting it:

```bash
sudo automount -vc
```
