#!/bin/bash
apk add wget
folder=ubuntu-fs
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="ubuntu-rootfs.tar.xz"
if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
		echo "Download Rootfs, this may take a while base on your internet speed."
		wget "https://github.com/Techriz/AndronixOrigin/blob/master/Rootfs/Ubuntu/i386/ubuntu-rootfs-i386.tar.xz?raw=true" -O $tarball
fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	tar -xJf ${cur}/${tarball}
	cd "$cur"
fi
mkdir -p ubuntu-binds
bin=start-ubuntu.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
export PATH=$bin:/usr/bin:/usr/sbin:/bin:$PATH
export HOME=/root
busybox mount -o bind /proc ${folder}/proc
busybox chroot ${folder} /bin/bash
if [ -n "\$(ls -A ubuntu-binds)" ]; then
    for f in ubuntu-binds/* ;do
      . \$f
    done
fi
EOM

echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball
echo "You can now launch Ubuntu with the ./${bin} script"
