#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/bootdevice/by-name/recovery:67108864:c26cc91e923758d1aafdb1de59fb6eb6f6d1c5b1; then
  applypatch  \
          --patch /system/recovery-from-boot.p \
          --source EMMC:/dev/block/bootdevice/by-name/boot:67108864:ba1b7216a81696f85394611cedb161ee1f7ae574 \
          --target EMMC:/dev/block/bootdevice/by-name/recovery:67108864:c26cc91e923758d1aafdb1de59fb6eb6f6d1c5b1 && \
      log -t recovery "Installing new recovery image: succeeded" || \
      log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
