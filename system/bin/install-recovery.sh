#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/bootdevice/by-name/recovery:67108864:463a0afe804a295ab63cdb1cde5f4f2036456c3d; then
  applypatch  \
          --patch /system/recovery-from-boot.p \
          --source EMMC:/dev/block/bootdevice/by-name/boot:67108864:cbe5bfd4f5e3594513f692798c66be78639f253e \
          --target EMMC:/dev/block/bootdevice/by-name/recovery:67108864:463a0afe804a295ab63cdb1cde5f4f2036456c3d && \
      log -t recovery "Installing new recovery image: succeeded" || \
      log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
