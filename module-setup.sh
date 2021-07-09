#!/bin/bash

# called by dracut
check() {
    if ! dracut_module_included "systemd" || ! dracut_module_included "crypt"; then
        derror "pcscd module requires systemd in the initramfs and crypt"
        return 1
    fi
    require_binaries /usr/sbin/pcscd
    return 0
}

# called by dracut
install() {
    _install_pcscd
    _install_ccid
    _install_opensc
    _install_p11_kit
}

_install_pcscd() {
    inst_multiple /usr/sbin/pcscd
    inst_rules /lib/udev/rules.d/99-pcscd-hotplug.rules
    inst /lib/udev/pcscd.sh /etc/udev/pcscd.sh
    inst_multiple \
        "$systemdsystemunitdir"/pcscd.service \
        "$systemdsystemunitdir"/pcscd.socket

    # Allow the service and socket start when cryptsetup wants them to
    mkdir -p "${initdir}/$systemdsystemunitdir/pcscd.service.d"
    (
        echo "[Unit]"
        echo "DefaultDependencies=no"
        echo "[Install]"
        echo "WantedBy=cryptsetup-pre.target"
    ) > "${initdir}/$systemdsystemunitdir/pcscd.service.d/dracut.conf"
    mkdir -p "${initdir}/$systemdsystemunitdir/pcscd.socket.d"
    (
        echo "[Unit]"
        echo "DefaultDependencies=no"
        echo "[Install]"
        echo "WantedBy=cryptsetup-pre.target"
    ) > "${initdir}/$systemdsystemunitdir/pcscd.socket.d/dracut.conf"
    systemctl -q --root "$initdir" enable pcscd.socket

    inst_libdir_file libpcsclite.so
}

_install_ccid() {
    inst_multiple \
        /usr/lib64/readers/usb/ifd-ccid.bundle/Contents/Linux/libccid.so \
        /usr/lib64/readers/usb/ifd-ccid.bundle/Contents/Info.plist

    inst_rules /lib/udev/rules.d/92-pcsc-ccid.rules
}

_install_p11_kit() {
    inst_libdir_file p11-kit-proxy
    inst_multiple /usr/share/p11-kit/modules/p11-kit-trust.module \
        /etc/pkcs11/pkcs11.conf.example
}

_install_opensc() {
    inst_libdir_file \
        opensc-pkcs11.so \
        onepin-opensc-pkcs11.so \
        libopensc.so

    inst_multiple \
        /usr/lib64/pkcs11/*

    inst_multiple \
        /etc/opensc.conf \
        /etc/pkcs11/modules/opensc.module
}

_debug() {
    # systemd-cryptenroll may be used to debug the unlocking. It relies on the same mechanism as systemd-cryptsetup
    # To view which tokens the systemd can use, run:
    # systemd-cryptenroll --pkcs11-token=list
    # To view which tokens pcsc can generally see - run
    # opensc-tool -l
    inst_multiple -o systemd-cryptenroll
    inst_multiple -o opensc-tool
}
