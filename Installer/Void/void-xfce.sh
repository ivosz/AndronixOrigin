#!/data/data/com.termux/files/usr/bin/bash
pkg install wget -y 
folder=void-fs
dlink="https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/XBPS"
if [ -d "$folder" ]; then
  first=1
  echo "skipping downloading"
fi
tarball="void.tar.xz"



if [ "$first" != 1 ];then
  if [ ! -f $tarball ]; then
    echo "Download Rootfs, this may take a while base on your internet speed."
    wget "https://github.com/AndronixApp/AndronixOrigin/blob/master/Rootfs/Void/i386/void_i386.tar.xz?raw=true" -O $tarball
  fi
  mkdir -p "$folder"
  echo "Decompressing Rootfs, please be patient."
  tar -xJf ${tarball} -C $folder
fi

mkdir -p void-binds
bin=start-void.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
if [ -n "\$(ls -A void-binds)" ]; then
    for f in void-binds/* ;do
      . \$f
    done
fi
export PATH=$bin:/usr/bin:/usr/sbin:/bin:$PATH
export HOME=/root
rm -rf void-fs/dev
ln -s /dev void-fs/dev
rm -rf void-fs/sys
ln -s /sys void-fs/sys
busybox chroot void-fs /bin/bash
EOM

echo "Fixing DNS for internet connection"
rm -rf void-fs/etc/resolv.conf
echo "nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 192.168.1.1
nameserver 127.0.0.1" > void-fs/etc/resolv.conf

echo "making $bin executable"
chmod +x $bin
rm $tarball

#DE installation addition

wget --tries=20 $dlink/XFCE4/xfce4_de.sh -O $folder/root/xfce4_de.sh > /dev/null
clear
echo "Setting up the installation of XFCE VNC"

echo "#!/bin/bash
xbps-install -Su -y && xbps-install -S xfce4 tigervnc wget sudo -y 
if [ ! -f /root/xfce4_de.sh ]; then
    wget --tries=20 $dlink/XFCE4/xfce4_de.sh -O /root/xfce4_de.sh > /dev/null
    bash ~/xfce4_de.sh 
else
    bash ~/xfce4_de.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/XFCE4/vncserver-start -O /usr/local/bin/vncserver-start > /dev/null
    wget --tries=20 $dlink/XFCE4/vncserver-stop -O /usr/local/bin/vncserver-stop > /dev/null
    chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    xbps-install -S xfce4 tigervnc wget -y  > /dev/null
fi
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 

bash $bin
