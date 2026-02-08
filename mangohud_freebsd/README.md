sudo pkg install libsysinfo
I forgot what that's for, though.

For building manually, PLEASE run ninja -C build install. That install part is IMPORTANT! otherwise, only very simple programs will work! You have been warned!
meson build -Dwith_nvml=enabled -Dwith_xnvctrl=disabled -Dwith_x11=enabled -Dwith_wayland=enabled -Dwith_dbus=enabled

NOTE!
I don't have XNVCtrl enabled, so the #ifdef guards checking HAVE_XNVCTRL won't be compiled. I did NOT modify the functions in HAVE_XNVCTRL! Do not be surprised if they lead to broken behaviour!

My patches for GPU are inadequate, they only work for Nvidia.

building instruction in my case :
```
sudo pkg install glslang
sudo pkg install libxkbcommon
sudo pkg install libglvnd mesa-libs

pkg install nvidia-settings for NVCtrl.h

https://forums.freebsd.org/threads/mounting-proc-in-freebsd-14-3.98822/


FOR NEW PATCH :
sudo pkg install libsysinfo


For building manually, PLEASE run ninja -C build install. That install part is IMPORTANT! otherwise, only very simple programs will work! You have been warned!
meson build -Dwith_nvml=enabled -Dwith_xnvctrl=disabled -Dwith_x11=enabled -Dwith_wayland=enabled -Dwith_dbus=enabled


my branch :
now requires turbostat.
pkg install turbostat
sudo kldload cpuctl
NOTE!
I don't have XNVCtrl enabled, so the #ifdef guards checking HAVE_XNVCTRL won't be compiled. I did NOT modify the functions in HAVE_XNVCTRL! Do not be surprised if they lead to broken behaviour!
```
