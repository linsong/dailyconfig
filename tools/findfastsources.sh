#!/bin/bash
if [ $# != 1 ] | \
   [ "$1" != "hoary" -a "$1" != "breezy" ]; then
   echo "Use: sudo $0 (hoary|breezy)";
   echo "Example: sudo $0 hoary";
   exit 1;
fi

if [ !$USER = "root" ]; then
   echo "$0 must run by sudo";
   exit 1;
fi

echo "Seting $1...";
MIRRORS="http://mirror.isp.net.au/ftp/pub/ubuntu/ \
ftp://linux.xjtu.edu.cn/mirror/ubuntu/ubuntu/ \
http://mirror.lupaworld.com/ubuntu/archive/ \
http://ubuntu.cn99.com/ubuntu/ \
ftp://mirror.isp.net.au/pub/ubuntu/ \
ftp://ftp.filearena.net/pub/ubuntu/ \
http://mirror.optus.net/ubuntu/ \
http://ubuntu.inode.at/ubuntu/ \
ftp://ubuntu.inode.at/ubuntu/ \
http://ubuntu.uni-klu.ac.at/ubuntu/ \
ftp://ftp.uni-klu.ac.at/linux/ubuntu/ \
ftp://gd.tuwien.ac.at/opsys/linux/ubuntu/archive/ \
http://gd.tuwien.ac.at/opsys/linux/ubuntu/archive/ \
http://ftp.belnet.be/pub/mirror/ubuntu.com/ \
ftp://ftp.belnet.be/pub/mirror/ubuntu.com/ \
http://ubuntu.mirrors.skynet.be/pub/ubuntu.com/ \
ftp://ubuntu.mirrors.skynet.be/pub/ubuntu.com/ \
http://mirror.freax.be/ubuntu/archive.ubuntu.com/ \
http://ftp.interlegis.gov.br/pub/ubuntu/archive/ \
http://ubuntu.c3sl.ufpr.br/ubuntu/ \
ftp://ftp.cs.mun.ca/pub/mirror/ubuntu/ \
http://archive.ubuntu.org.cn/ubuntu/ \
http://archive.ubuntu.cz/ubuntu/ \
ftp://archive.ubuntu.cz/ubuntu/ \
http://mirrors.dk.telia.net/ubuntu/ \
ftp://mirrors.dk.telia.net/ubuntu/ \
http://mirrors.dotsrc.org/ubuntu/ \
ftp://mirrors.dotsrc.org/ubuntu/ \
http://klid.dk/homeftp/ubuntu/ \
ftp://klid.dk/ubuntu/ \
http://ubuntu.mirror.mmd.net/ubuntu/ \
ftp://ubuntu.mirror.mmd.net/ubuntu/ \
http://mir1.ovh.net/ubuntu/ubuntu/ \
ftp://mir1.ovh.net/ubuntu/ubuntu/ \
ftp://debian.charite.de/ubuntu/ \
http://debian.charite.de/ubuntu/ \
http://ftp.inf.tu-dresden.de/os/linux/dists/ubuntu/ \
http://www.artfiles.org/ubuntu.com/ \
http://ftp.rz.tu-bs.de/pub/mirror/ubuntu-packages/ \
ftp://ftp.rz.tu-bs.de/pub/mirror/ubuntu-packages/ \
ftp://ftp.join.uni-muenster.de/pub/mirrors/ftp.ubuntu.com/ubuntu/ \
http://ftp.join.uni-muenster.de/pub/mirrors/ftp.ubuntu.com/ubuntu/ \
http://ftp.kfki.hu/linux/ubuntu/ \
ftp://ftp.kfki.hu/pub/linux/ubuntu/ \
ftp://ftp.fsn.hu/pub/linux/distributions/ubuntu/ \
http://komo.vlsm.org/ubuntu/ \
http://kambing.vlsm.org/ubuntu/ \
http://ubuntu.odg.cc/ \
http://ftp.esat.net/mirrors/archive.ubuntu.com/ \
ftp://ftp.esat.net/mirrors/archive.ubuntu.com/ \
http://ftp.heanet.ie/pub/ubuntu/ \
ftp://ftp.heanet.ie/pub/ubuntu/ \
http://ftp.linux.it/ubuntu/ \
ftp://ftp.linux.it/ubuntu/ \
http://na.mirror.garr.it/mirrors/ubuntu-archive/ \
ftp://na.mirror.garr.it/mirrors/ubuntu-archive/ \
http://ubuntu.mithril-linux.org/archives/ \
http://ftp.litnet.lt/pub/ubuntu/ \
ftp://ftp.litnet.lt/pub/ubuntu/ \
ftp://ftp.polytechnic.edu.na/pub/ubuntulinux/ \
ftp://ftp.bit.nl/ubuntu/ \
http://ftp.bit.nl/ubuntu/ \
http://ubuntu.synssans.nl/ \
ftp://ftp.uninett.no/linux/ubuntu/ \
http://ubuntulinux.mainseek.com/ubuntu/ \
ftp://ftp.rnl.ist.utl.pt/ubuntu/ \
http://darkstar.ist.utl.pt/ubuntu/archive/ \
http://ftp.lug.ro/ubuntu/ \
ftp://ftp.lug.ro/ubuntu/ \
http://ftp.roedu.net/mirrors/ubuntu/ \
http://ftp.iasi.roedu.net/mirrors/ubuntu/ \
ftp://ftp.um.es/mirror/ubuntu/ \
ftp://ftp.ubuntu-es.org/ubuntu/ \
http://ftp.acc.umu.se/mirror/ubuntu/ \
ftp://ftp.se.linux.org/pub/Linux/distributions/ubuntu/ \
http://mirror.switch.ch/ftp/mirror/ubuntu/ \
ftp://mirror.switch.ch/mirror/ubuntu/ \
http://apt.nc.hcc.edu.tw/pub/ubuntu/ \
ftp://apt.nc.hcc.edu.tw/pub/ubuntu/ \
ftp://os.nchc.org.tw/ubuntu/ \
ftp://ftp.ee.ncku.edu.tw/pub/ubuntu/ \
http://ubuntu.csie.ntu.edu.tw/ubuntu/ \
http://www.mirrorservice.org/sites/archive.ubuntu.com/ubuntu/ \
ftp://ftp.mirrorservice.org/sites/archive.ubuntu.com/ubuntu/ \
http://ftp.cs.umn.edu/pub/ubuntu/ \
http://mirror.clarkson.edu/pub/distributions/ubuntu/ \
ftp://mirror.clarkson.edu/pub/distributions/ubuntu/ \
http://ubuntu.mirrors.tds.net/ubuntu/ \
ftp://ubuntu.mirrors.tds.net/ubuntu/ \
http://itanix.rutgers.edu/ubuntu/ \
http://www.opensourcemirrors.org/ubuntu/ \
http://ftp.ale.org/pub/mirrors/ubuntu/ \
http://ubuntu.secs.oakland.edu/ \
http://mirror.mcs.anl.gov/pub/ubuntu/ \
ftp://mirror.mcs.anl.gov/pub/ubuntu/ \
http://debian.okey.net/ubuntu/ \
ftp://ftp.sjtu.edu.cn/sites/archive.ubuntu.com/"

TIME="/usr/bin/time -o timer.txt -f %e";
URL="dists/$1/main/binary-i386/Packages.gz";
WGET="wget --cache=off -T 20 -t 1 -w 0 -O /dev/null"
PAYTIME=1000;
TEMPTIME=1000;
SITE="http://cn.archive.ubuntu.com/ubuntu/";
for mirror in $MIRRORS ; do
   echo "Testing $mirror..."
   TEMPTIME=`$TIME $WGET $mirror$URL`;
   if [ "$?" = 0 ] ; then
      TEMPTIME=`cat timer.txt`;
      echo "wget $1 : $TEMPTIME   CurrMinTime : $PAYTIME";
      TEMPTIME2=`echo "$PAYTIME > $TEMPTIME"|bc`;
      if [ $TEMPTIME2 = 1 ] ; then
         PAYTIME="$TEMPTIME";
         SITE="$mirror";
         echo -e "\033[37;41;1mSet best site ($PAYTIME): $SITE\033[0m"   
      fi
   fi
   rm timer.txt;
done
echo "Best site ($PAYTIME): $SITE";
echo "Backup your sources.list."
declare -i num;
num=0;
while [ -e /etc/apt/sources.list.$num ];do
   num=$num+1;      
done
mv /etc/apt/sources.list /etc/apt/sources.list.$num
COMP="main restricted universe multiverse";
MAINSITE="http://archive.ubuntu.org.cn"
echo "deb $SITE $1 $COMP" > /etc/apt/sources.list

echo "deb $SITE $1-security $COMP" >> /etc/apt/sources.list
echo "deb $SITE $1-updates $COMP" >> /etc/apt/sources.list
if [ $1 = "hoary" ]; then
   echo "deb $MAINSITE/ubuntu-cn ubuntu.org.cn $COMP" >> /etc/apt/sources.list
   echo "deb $MAINSITE/ubuntu hoary-backports $COMP" >> /etc/apt/sources.list
   echo "deb $MAINSITE/backports hoary-extras $COMP" >> /etc/apt/sources.list
fi
echo "Finlish setting sources.list,Run apt-get update now!";
exit 0
