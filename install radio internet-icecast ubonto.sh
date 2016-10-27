#!/bin/bash 
#on Ubonto
#
#apt-get install -y gcc
#apt-get install -y wget 
#apt-get install -y lsof sox 
#apt-get install -y firewalld  nmap
#apt-get update
#https://www.howtoforge.com/linux_webradio_with_icecast2_ices2
apt-get install icecast2

firewall-cmd --add-port=8000/tcp --permanent
#firewall-cmd --add-port=843/tcp --permanent
#firewall-cmd --add-port=7999/tcp --permanent
firewall-cmd --reload


apt-get install -y nano
#vi /etc/icecast2/icecast.xml
mv /etc/icecast2/icecast.xml /etc/icecast2/icecast.xml.main
rm -rf /etc/icecast2/icecast.xml 
nano  /etc/icecast2/icecast.xml 
#change hostname to vps ip and passwords <bind-address>vps ip</bind-address>

nano /etc/default/icecast2
ENABLE=true
#That's it already, we can now start the Icecast2 server:That's it already, we can now start the Icecast2 server:
/etc/init.d/icecast2 start



#Setting up the OGG/Vorbis streaming client: ices
apt-get install -y ices2

ls /opt/icecast/latest/bin/


mkdir /var/log/ices
mkdir /etc/ices2
mkdir /etc/ices2/music
cp /usr/share/doc/ices2/examples/ices-playlist.xml /etc/ices2
cd /etc/ices2
nano /etc/ices2/ices-playlist.xml
#/etc/ices2/playlist.txt
m -rf "best music Year In Music 2015.zip"
#sox razhavaniazha_morning_18kbps.mp3  -C 16.01 razhavaniazha_morning_18kbps.mp3
ls
rm -rf /usr/local/etc/playlist2.m3u
find /etc/ices2/music/ -name "*.mp3" > /etc/ices2/playlist.txt

ices2 /etc/ices2/ices-playlist.xml 
kill -9 `pidof ices2`
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
cd /opt/icecast/latest/etc/
:'/music/artist/album/song1.ogg
/music/artist/album/song2.ogg
'



#Setting up the OGG/Vorbis streaming client: ices
apt-get install -y g++
apt-get install -y libshout3-dev
cp /etc/apt/sources.list /etc/apt/sources.list2
echo "deb ftp://ftp.nerim.net/debian-marillat/ etch main" >>  /etc/apt/sources.list 
apt-get install -y liblame-dev
apt-get install -y  libxml-dev
mkdir /usr/src/icecast
cd /usr/src/icecast
wget http://downloads.us.xiph.org/releases/libshout/libshout-2.4.1.tar.gz
tar xf libshout-2.4.1.tar.gz
cd libshout-2.4.1
./configure 
make 
make install

#Setting up the MP3 streaming client: icegenerator
apt-get install -y lame lame-dbg libmp3lame-dev libmp3lame0

apt-get install -y soundconverter
 cd /usr/src/icecast
wget http://downloads.us.xiph.org/releases/ices/ices-0.4.tar.gz
 tar xf ices-0.4.tar.gz
 cd ices-0.4/
 ./configure --with-lame  # --prefix=/opt/icecast/latest
make 
make install

 rm -rf /usr/local/etc/icegen1.cfg
 nano /usr/local/etc/icegen1.cfg
 #IP=192.168.1.100
 :'
IP=192.168.1.100
PORT=8000
SERVER=2
MOUNT=/radiostation2
PASSWORD=password
FORMAT=1
MP3PATH=m3u:/usr/local/etc/playlist2.m3u
LOOP=1
SHUFFLE=1
NAME=RadioStation 2: MP3
DESCRIPTION=Test Radio
GENRE=Varios
URL=http://5.152.181.113:8000/
LOG=2
LOGPATH=/var/log/icecast/icegen1.log
BITRATE=8
SOURCE=source
'
mkdir /music/
mkdir /music/artist
mkdir /music/artist/album/
 cd /music/artist/album/
wget http://www.mediafire.com/download/m79b6et2k26v82z/14.06.2016_razhavaniazha_morning_18kbps.mp3
wget http://dl2.musicor.ir/gemmusic/Archive2/100%20Ahange%20bartar/320%20-%20MUSICOR.IR.zip
#wget http://cdn.tabtaraneh.ir/94/fullalbum/60/Various%20Artists%20-%20Shadtarin%20Taranehaye%20Dahe%2060.zip
cd /music/artist/album/
mv 14.06.2016_razhavaniazha_morning_18kbps.mp3 razhavaniazha_morning_18kbps.mp3

unzip "best music Year In Music 2015.zip"
mv "best music Year In Music 2015" best_2015
rm -rf "best music Year In Music 2015.zip"
#sox razhavaniazha_morning_18kbps.mp3  -C 16.01 razhavaniazha_morning_18kbps.mp3
ls
rm -rf /usr/local/etc/playlist2.m3u
find /music/artist/album/best_2015/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
find /music/artist/album/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
#find /music/artist/album/Shadtarin_Taranehaye_Dahe_60/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
#find /music/artist/album/hel/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
rm -rf /var/log/icecast/icegen1.log
apt-get install -y  htop

nmap -v -sn 192.168.1.100
su -
firewall-cmd --add-port=8000/tcp --permanent
firewall-cmd --reload
iptables -A INPUT -i eth0 -p tcp --dport 8000 -j ACCEPT

kill -9 `lsof -t -i :8000`
/etc/init.d/icecast2 start
#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b -f /usr/local/etc/icegen1.cfg
#/opt/icecast/latest/bin/icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
#su - icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
ices -f /usr/local/etc/icegen1.cfg -F /usr/local/etc/playlist2.m3u -h 192.168.1.1 -p 8000
cat /var/log/icecast/icegen1.log
pgrep -fl icecast
pgrep -fl ices
lsof -t -i  :8000
#rebooting the system