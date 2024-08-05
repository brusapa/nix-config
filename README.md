# NixOS configuration files

## Post-installation steps

### Cooler control

``` bash
sudo sensors-detect --auto
```

### Flatpak

``` bash
$ flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
$ flatpak update
```
