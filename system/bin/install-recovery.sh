#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/bootdevice/by-name/recovery:67108864:ae02275014283effadf4ecab759d62a600510e40; then
  applypatch  \
          --patch /system/recovery-from-boot.p \
          --source EMMC:/dev/block/bootdevice/by-name/boot:67108864:fafc9704c1587307ecba46ca1ade837e5604e3a9 \
          --target EMMC:/dev/block/bootdevice/by-name/recovery:67108864:ae02275014283effadf4ecab759d62a600510e40 && \
      log -t recovery "Installing new recovery image: succeeded" || \
      log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
