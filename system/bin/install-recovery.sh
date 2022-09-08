#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/bootdevice/by-name/recovery:67108864:4a210cc38fe78b08ad78a2cfd150b4d6ac4aa9d6; then
  applypatch  \
          --patch /system/recovery-from-boot.p \
          --source EMMC:/dev/block/bootdevice/by-name/boot:67108864:637baf8aa9bf0425e0b36317cdb8862d9fb4b16c \
          --target EMMC:/dev/block/bootdevice/by-name/recovery:67108864:4a210cc38fe78b08ad78a2cfd150b4d6ac4aa9d6 && \
      log -t recovery "Installing new recovery image: succeeded" || \
      log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
