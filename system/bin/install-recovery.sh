#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/bootdevice/by-name/recovery:67108864:e849ad38ae7e29c9188c49c7711ab3ac8f93f939; then
  applypatch  \
          --patch /system/recovery-from-boot.p \
          --source EMMC:/dev/block/bootdevice/by-name/boot:67108864:8ce4396b3ffdcd167e253826a818ca1c757009de \
          --target EMMC:/dev/block/bootdevice/by-name/recovery:67108864:e849ad38ae7e29c9188c49c7711ab3ac8f93f939 && \
      log -t recovery "Installing new recovery image: succeeded" || \
      log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
