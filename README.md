This dracut module installs the services that allow systemd-cryptsetup to unlock disks encrypted with PKCS11 token.

# Installation

This module has been tested on Gentoo, but should in work on other Linux flavors.

## Gentoo
Install from [nitratesky](https://github.com/VTimofeenko/nitratesky) overlay:

    eselect repository enable nitratesky && emerge -a sys-kernel/dracut-pcscd-cryptsetup

## Other

1. Install dependencies:

    * ccid
    * p11-kit
    * opensc
    * pcsc-lite

2. Create a dracut module directory (`/usr/lib/dracut/modules.d/99pcscd-cryptsetup`)
3. Place `module-setup.sh` file in that directory

# Configuration
In order to use this module, add the following to your dracut configuration (located in `/etc/dracut.conf` or in `/etc/dracut.conf.d/`:

    add_dracutmodules+=" pcscd-cryptsetup "

Make sure that the dracut configuration also contains

    add_dracutmodules+=" crypt "

And `/etc/crypttab` is installed into initramfs:

    install_items+=" /etc/crypttab "

# Troubleshooting

This module contains `_debug` function that adds `systemd-cryptenroll` and `opensc-tool` to initramfs.

If `systemd-cryptsetup@.service` does not prompt for token password during boot, you can add call to `_debug` function into `install` function in `module-setup.sh`. On Gentoo, enable `debug` useflag and `emerge --changed-use dracut-pcscd-module`.

Then, once booted into dracut emergency shell, check if `pcscd.service` is running (run `systemctl status`).

Check if the reader is generally visible (run `opensc-tool -l`).

Check if systemd can see the token (run `systemd-cryptenroll --pkcs11-token=list`).

if no obvious error is returned – feel free to open an issue on Github.
