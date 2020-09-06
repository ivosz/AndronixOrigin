#!/data/data/com.termux/files/usr/bin/bash
apk add wget
folder=debian-fs
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="debian-rootfs.tar.xz"
if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
		echo "Download Rootfs, this may take a while base on your internet speed."
		wget "https://github.com/Techriz/AndronixOrigin/blob/master/Rootfs/Debian/i386/debian-rootfs-i386.tar.xz?raw=true" -O $tarball
	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	tar -xJf ${cur}/${tarball}
	cd "$cur"
fi
mkdir -p debian-binds
bin=start-debian.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
if [ -n "\$(ls -A debian-binds)" ]; then
    for f in debian-binds/* ;do
      . \$f
    done
fi
export PATH=$bin:/usr/bin:/usr/sbin:/bin:$PATH
export HOME=/root
rm -rf debian-fs/dev
ln -s /dev debian-fs/dev
rm -rf debian-fs/sys
ln -s /sys debian-fs/sys
busybox chroot debian-fs /bin/bash
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball
echo "You can now launch Debian with the ./${bin} script next time"
bash $bin
