#!/bin/bash 
#on centos
#https://www.howtoforge.com/how-to-install-a-streaming-audio-server-with-icecast-2.3.3-on-centos-6.3-x86_64-linux

cd /tmp
mkdir $OPENSHIFT_REPO_DIR/ogg
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
 tar -xf libogg-1.3.2.tar.gz

cd libogg-1.3.2 

./configure --prefix=$OPENSHIFT_REPO_DIR/ogg

make && make install


mkdir $OPENSHIFT_REPO_DIR/libvorbis
cd /tmp
wget downloads.xiph.org/releases/vorbis/libvorbis-1.1.2.tar.gz
tar xf libvorbis-1.1.2.tar.gz
cd libvorbis-1.1.2/
#yum -y install libxslt-devel
#yum -y install libogg-devel libvorbis libvorbis-devel
./configure  --prefix=$OPENSHIFT_REPO_DIR/libvorbis --with-ogg=$OPENSHIFT_REPO_DIR/ogg
make
make install 


mkdir $OPENSHIFT_REPO_DIR/icecast

cd /tmp

wget http://downloads.xiph.org/releases/icecast/icecast-2.4.1.tar.gz
tar xf icecast-2.4.1.tar.gz
cd icecast-2.4.1/
#yum -y install libxslt-devel
#yum -y install libogg-devel libvorbis libvorbis-devel
./configure \
--prefix=$OPENSHIFT_REPO_DIR/icecast --with-ogg=$OPENSHIFT_REPO_DIR/ogg \
--with-vorbis=$OPENSHIFT_REPO_DIR/libvorbis
make
make install 

ls $OPENSHIFT_REPO_DIR/icecast/bin/

cd $OPENSHIFT_REPO_DIR/icecast
 
#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml –b
cd $OPENSHIFT_REPO_DIR/icecast/etc
cp  icecast.xml icecast.xml.orig

rm -rf $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml 
#cp icecast.xml.orig icecast.xml
cat <<EOT >> $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml
<icecast>
 <Stream>
   <Name>Cool ices default name from XML</Name>
   <Genre>Cool ices genre from XML</Genre>
   <Description>Cool ices description from XML</Description>
   <URL>Cool ices URL from XML</URL>
   <Bitrate>8</Bitrate>
   <Public>1</Public>
   <Reencode>0</Reencode>
   <!-- LIMITS <Samplerate>-1</Samplerate> -->
   <Samplerate>22050</Samplerate>
   <Channels>-1</Channels>
</Stream>	
   <!-- LIMITS -->
   <limits>
     <clients>100</clients>
     <sources>10</sources>
     <threadpool>5</threadpool>
     <queue-size>524288</queue-size>
     <client-timeout>30</client-timeout>
     <header-timeout>15</header-timeout>
     <source-timeout>10</source-timeout>
     <burst-on-connect>1</burst-on-connect>
     <burst-size>65535</burst-size>
     <!-- <burst-size>65535</burst-size> -->
   </limits>
   
   <encode>  
   <!-- <quality>-1</quality> -->
   <quality>-1</quality>
   <nominal-bitrate>8</nominal-bitrate>
   <maximum-bitrate>32</maximum-bitrate>
   <minimum-bitrate>4</minimum-bitrate>
   <managed>1</managed>
   <samplerate>22050</samplerate>
   <channels>2</channels>
   <flush-samples>11000</flush-samples>
    </encode>	
 
     <!-- GENRIC -->
     <authentication>
       <source-password>password</source-password>
       <admin-user>admin</admin-user>
       <admin-password>password</admin-password>
     </authentication>
     <hostname>hostname_localhost</hostname>
     <listen-socket>
     <port>8000</port>
     <bind-address>localhost</bind-address>
     <shoutcast-mount>/stream.mp3</shoutcast-mount>
     </listen-socket>
     <fileserve>1</fileserve>
   
   
    
     <!-- PATHES -->
     <paths>
       <basedir>$OPENSHIFT_REPO_DIR/icecast/share/icecast</basedir>
       <webroot>$OPENSHIFT_REPO_DIR/icecast/share/icecast/web</webroot>
       <adminroot>$OPENSHIFT_REPO_DIR/icecast/share/icecast/admin</adminroot>
       <logdir>$OPENSHIFT_REPO_DIR/icecast/var/log/icecast</logdir>
       <pidfile>$OPENSHIFT_REPO_DIR/icecast/share/icecast/icecast.pid</pidfile>
       <alias source="/" dest="/status.xsl"/>
     </paths>
   
     <!-- LOG -->
     <logging>
       <accesslog>access.log</accesslog>
       <errorlog>error.log</errorlog>
       <playlistlog>playlist.log</playlistlog>
       <loglevel>1</loglevel>
       <logsize>10000</logsize>
       <logarchive>4</logarchive>
     </logging>
   
     <!-- SECURITY -->
    <security>
    <chroot>0</chroot>
    <!--
         <changeowner>
         <user>icecast</user>
         <group>icecast</group>
       </changeowner>
       -->
    </security>
   
   </icecast> 
EOT

#rm -rf $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml 
#cp icecast.xml.orig icecast.xml

#cat $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml
sed -i 's/hostname_localhost/'${OPENSHIFT_GEAR_DNS}'/g'  $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml
sed -i 's/localhost/'${OPENSHIFT_DIY_IP}'/g'  $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml
sed -i 's/$OPENSHIFT_REPO_DIR/'${OPENSHIFT_REPO_DIR}'/g'  $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml
sed -i 's/8000/8080/g'  $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml

mkdir $OPENSHIFT_REPO_DIR/icecast/var
mkdir $OPENSHIFT_REPO_DIR/icecast/var/log
mkdir $OPENSHIFT_REPO_DIR/icecast/var/log/icecast
#kill -9 `lsof -t -i :8080`
#Now give it a try and start the icecast server:
#$OPENSHIFT_REPO_DIR/icecast/bin/icecast -c $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml -b


#lsof -t -i :8080
#lsof -t -i :8000
#npm
#ps aux

#Setting up the OGG/Vorbis streaming client: ices
mkdir $OPENSHIFT_REPO_DIR/libshout

cd /tmp
wget http://downloads.us.xiph.org/releases/libshout/libshout-2.4.1.tar.gz
tar xf libshout-2.4.1.tar.gz
cd libshout-2.4.1
./configure \
--prefix=$OPENSHIFT_REPO_DIR/libshout --with-ogg=$OPENSHIFT_REPO_DIR/ogg \
--with-vorbis=$OPENSHIFT_REPO_DIR/libvorbis
make 
make install

#Now download the ices client:
mkdir $OPENSHIFT_REPO_DIR/ices
cd /tmp
wget http://downloads.us.xiph.org/releases/ices/ices-2.0.2.tar.bz2
 tar xf ices-2.0.2.tar.bz2
 cd ices-2.0.2/
 export PKG_CONFIG_PATH=$OPENSHIFT_REPO_DIR/ogg/lib/pkgconfig:$OPENSHIFT_REPO_DIR/libvorbis/lib/pkgconfig:$OPENSHIFT_REPO_DIR/libshout/lib/pkgconfig:$PKG_CONFIG_PATH
 ./configure --prefix=$OPENSHIFT_REPO_DIR/ices --with-ogg=$OPENSHIFT_REPO_DIR/ogg  --with-vorbis=$OPENSHIFT_REPO_DIR/libvorbis

 make 
 make  install
 
 
ls $OPENSHIFT_REPO_DIR/ices/

#nano ices1.xml
:'
<ices>
   
     <!-- GENERIC -->
     <background>1</background>
     <pidfile>/var/run/icecast/ices1.pid</pidfile>
   
     <!-- LOGGING -->
     <logpath>/var/log/icecast</logpath>
     <logfile>ices1.log</logfile>
     <logsize>2048</logsize>
     <loglevel>3</loglevel>
     <consolelog>0</consolelog>
   
     <!-- STREAM -->
     <stream>
       <metadata>
         <name>RadioStation 1: OGG</name>
         <genre>Varios</genre>
         <description>Test Radio 1</description>
         <url>http://5.152.181.82:8000/</url>
       </metadata>
       <input>
         <param name="type">basic</param>
         <param name="file">/opt/icecast/latest/etc/playlist1.txt</param>
         <param name="random">1</param>
         <param name="once">0</param>
         <param name="restart-after-reread">1</param>
       </input>
       <instance>
         <hostname>5.152.181.82</hostname>
         <port>8000</port>
         <password>password</password>
         <mount>/radiostation1</mount>
       </instance>
     </stream>
   
   </ices>
 '
#cd /opt/icecast/latest/etc/
#nano  playlist1.txt
:'/music/artist/album/song1.ogg
/music/artist/album/song2.ogg
'

#Setting up the MP3 streaming client: icegenerator
 
 #To compile icegenerator download the source package from http://sourceforge.net/projects/icegenerator/ and store it in your src directory. Then go into the src directory and extract the source:
cd /tmp
mkdir $OPENSHIFT_REPO_DIR/icegenerator
mkdir $OPENSHIFT_REPO_DIR/icegenerator/bin
wget http://netcologne.dl.sourceforge.net/project/icegenerator/icegenerator/0.5.5-pre2/icegenerator-0.5.5-pre2.tar.gz
tar xfz icegenerator-0.5.5-pre2.tar.gz
cd icegenerator-0.5.5-pre2
export PKG_CONFIG_PATH=$OPENSHIFT_REPO_DIR/ogg/lib/pkgconfig:$OPENSHIFT_REPO_DIR/libvorbis/lib/pkgconfig:$OPENSHIFT_REPO_DIR/libshout/lib/pkgconfig:$PKG_CONFIG_PATH
#nohup sh -c "./configure  --prefix=$OPENSHIFT_REPO_DIR/icegenerator --bindir=$OPENSHIFT_REPO_DIR/icegenerator/bin --with-shout=$OPENSHIFT_REPO_DIR/libshout/ "   >  $OPENSHIFT_LOG_DIR/icegenerator_install.log 2>&1 &
#tail -f  $OPENSHIFT_LOG_DIR/icegenerator_install.log 
./configure  --prefix=$OPENSHIFT_REPO_DIR/icegenerator --bindir=$OPENSHIFT_REPO_DIR/icegenerator/bin #--with-shout=$OPENSHIFT_REPO_DIR/libshout
make 
make install

ls -lah $OPENSHIFT_REPO_DIR/icegenerator/bin/ice*
 cd $OPENSHIFT_REPO_DIR/icegenerator
 rm -rf $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg
 #nano $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg
 #IP=192.168.1.100 SHUFFLE=0 for linear writing SHUFFLE=1 for random 
 cat <<EOT >> $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg
IP=OPENSHIFT_DIY_IP
PORT=8080
SERVER=2
MOUNT=/radiostation2
PASSWORD=password
FORMAT=1
MP3PATH=m3u:$OPENSHIFT_REPO_DIR/icecast/playlist2.m3u
LOOP=1
SHUFFLE=0
NAME=RadioStation 2: MP3
DESCRIPTION=Test Radio
GENRE=Varios
URL=http://OPENSHIFT_DIY_IP:8080/
LOG=2
LOGPATH=$OPENSHIFT_REPO_DIR/icecast/var/log/icecast/icegen1.log
BITRATE=8
SOURCE=source
EOT

sed -i 's/OPENSHIFT_REPO_DIR/'${OPENSHIFT_REPO_DIR}'/g'  $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg
sed -i 's/OPENSHIFT_DIY_IP/'${OPENSHIFT_DIY_IP}'/g'  $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg
cat $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg


mkdir $OPENSHIFT_REPO_DIR/lame
cd /tmp
wget http://heanet.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xvfz lame-3.99.5.tar.gz
cd lame-3.99.5
./configure  --prefix=$OPENSHIFT_REPO_DIR/lame
make
make install 
export PATH=$OPENSHIFT_REPO_DIR/lame/bin:$PATH
#Usage:
#$OPENSHIFT_REPO_DIR/lame/bin/lame --mp3input -b <bitrate> <file.mp3> <destination.mp3> 
cd $OPENSHIFT_REPO_DIR/icecast/music
for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/lame/bin/lame --mp3input -b 18 "$f" $OPENSHIFT_REPO_DIR/icecast/music/"$f" ; done


mkdir $OPENSHIFT_REPO_DIR/SoX
cd /tmp
# git clone git://git.code.sf.net/p/sox/code sox
wget http://tenet.dl.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2.tar.gz
tar xvfz sox-14.4.2.tar.gz
cd sox-14.4.2
./configure  --prefix=$OPENSHIFT_REPO_DIR/SoX #--with-lame=$OPENSHIFT_REPO_DIR/lame
make -s
make install 


export PATH=$OPENSHIFT_REPO_DIR/SoX/bin:$PATH
#$OPENSHIFT_REPO_DIR/icecast/playlist2.m3u
mkdir $OPENSHIFT_REPO_DIR/icecast/music
mkdir $OPENSHIFT_REPO_DIR/icecast/music/album

 cd $OPENSHIFT_REPO_DIR/icecast/music/album
#wget http://www.mediafire.com/download/m79b6et2k26v82z/14.06.2016_razhavaniazha_morning_18kbps.mp3
#wget http://dl2.musicor.ir/gemmusic/Archive2/100%20Ahange%20bartar/320%20-%20MUSICOR.IR.zip
wget http://cdn.tabtaraneh.ir/94/fullalbum/60/Various%20Artists%20-%20Shadtarin%20Taranehaye%20Dahe%2060.zip
#wget http://dl.musicjavani.com/radiojavan%201394/bahman%2094/04/Mohsen%20Chavoshi%20-%20Kalaf%20version%202.mp3

unzip *
rm -rf *.zip
mv V*/* .
rm -rf V*
#for f in *.mp3 ; do rename 's/ /_/g' $f  ; done
#find -name "* *"  | rename 's/ /_/g'
for f in $OPENSHIFT_REPO_DIR/icecast/music/album *; do mv "$f" "${f// /_}"; done
cd $OPENSHIFT_REPO_DIR/icecast/music/album

mkdir $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k3
cd $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k3
wget -r -l1 -H -t1 -nd -N -np -A.mp3 -erobots=off  https://24music.org/%D9%85%D8%AC%D9%85%D9%88%D8%B9%D9%87-%DB%B1%DB%B0%DB%B0-%D8%A2%D9%87%D9%86%DA%AF-%D8%AE%D8%A7%D8%B1%D8%AC%DB%8C-%D9%82%D8%AF%DB%8C%D9%85%DB%8C-%D8%A8%D8%B1%D8%AA%D8%B1-%D8%AF%D9%87%D9%87-%DB%B7%DB%B0/
for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input --abr 18 -b 18 -F -V 9.999  "$f" $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k3/"$f" && rm -rf "$f" ; done

mkdir $OPENSHIFT_REPO_DIR/icecast/music/new_18k
#$OPENSHIFT_REPO_DIR/lame/bin/lame --mp3input -b 18 *.mp3 m.mp3
for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/lame/bin/lame --mp3input --abr 18 -b 18 -F -V 9.999  "$f" $OPENSHIFT_REPO_DIR/icecast/music/new_18k/"$f" && rm -rf "$f" ; done
#for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/SoX/bin/sox  -C 16.01 "$f" $OPENSHIFT_REPO_DIR/icecast/music/"$f" ; done
#rm -rf $OPENSHIFT_REPO_DIR/icecast/music/album/*
du -h $OPENSHIFT_REPO_DIR/icecast/music/new_18k
#$OPENSHIFT_REPO_DIR/SoX/bin/sox m.mp3  -C 16.01 m_18kbps.mp3
#sox razhavaniazha_morning_18kbps.mp3  -C 16.01 razhavaniazha_morning_18kbps.mp3
ls
#unrar x filename.rar
rm -rf $OPENSHIFT_REPO_DIR/icecast/playlist2.m3u
find $OPENSHIFT_REPO_DIR/icecast/music/new_18k/ -name "*.mp3" > $OPENSHIFT_REPO_DIR/icecast/playlist2.m3u
find $OPENSHIFT_REPO_DIR/icecast/music/new_18k3/ -name "*.mp3" >> $OPENSHIFT_REPO_DIR/icecast/playlist2.m3u

#find /music/artist/album/Shadtarin_Taranehaye_Dahe_60/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
#find /music/artist/album/hel/ -name "*.mp3" > /usr/local/etc/playlist2.m3u


#nmap -v -sn 192.168.1.100

#iptables -A INPUT -i eth0 -p tcp --dport 8000 -j ACCEPT

kill -9 `lsof -t -i :8080`
nohup sh -c "$OPENSHIFT_REPO_DIR/icecast/bin/icecast -c $OPENSHIFT_REPO_DIR/icecast/etc/icecast.xml -b  "    >  $OPENSHIFT_LOG_DIR/iccast_run.log 2>&1 &

#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b -f /usr/local/etc/icegen1.cfg
#/opt/icecast/latest/bin/icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
#$OPENSHIFT_REPO_DIR/icecast/bin/icecast -c "export LD_LIBRARY_PATH=$OPENSHIFT_REPO_DIR/libshout/lib/:$LD_LIBRARY_PATH; $OPENSHIFT_REPO_DIR/icegenerator/bin/icegenerator -f $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg"
export LD_LIBRARY_PATH=$OPENSHIFT_REPO_DIR/libshout/lib/:$LD_LIBRARY_PATH;

rm -rf  $OPENSHIFT_REPO_DIR/icecast/var/log/icecast/icegen1.log
nohup sh -c "$OPENSHIFT_REPO_DIR/icegenerator/bin/icegenerator -f $OPENSHIFT_REPO_DIR/icecast/etc/icegen1.cfg "    >  $OPENSHIFT_LOG_DIR/icegenerator_run1.log 2>&1 &
cat $OPENSHIFT_REPO_DIR/icecast/var/log/icecast/icegen1.log
#pgrep -fl icecast
#pgrep -fl icegen
#lsof -t -i  :8080
#rebooting the system

# cd /tmp
 # chmod 755 install.sh
 # nano install.sh
 #nohup sh -c "./install.sh "    >  $OPENSHIFT_LOG_DIR/install.log 2>&1 &
#tail -f  $OPENSHIFT_LOG_DIR/install.log