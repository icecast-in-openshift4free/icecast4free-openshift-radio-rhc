#!/bin/bash 
#on centos
#https://www.howtoforge.com/how-to-install-a-streaming-audio-server-with-icecast-2.3.3-on-centos-6.3-x86_64-linux
yum -y groupinstall “Development Tools”
yum install -y curl-devel libtheora-devel libvorbis-devel libxslt-devel speex-devel libxslt
#yum -y install autoconf automake cmake freetype-devel gcc gcc-c++ git libtool make mercurial nasm pkgconfig zlib-devel

rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt

yum -y groupinstall "Development tools"
yum -y install gcc
yum -y install wget mail htop
yum -y install lsof sox 
yum -y install firewalld  nmap
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
rpm -Uvh rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
yum -y install rar unrar
yum –y update

firewall-cmd --add-port=8000/tcp --permanent
firewall-cmd --add-port=843/tcp --permanent
firewall-cmd --add-port=7999/tcp --permanent
firewall-cmd --reload
#systemctl unmask firewalld
#systemctl enable firewalld
#systemctl start firewalld

mkdir -p /usr/src/icecast
cd /usr/src/icecast
yum install wget
wget http://downloads.xiph.org/releases/icecast/icecast-2.4.1.tar.gz
tar xf icecast-2.4.1.tar.gz
cd icecast-2.4.1/
yum -y install libxslt-devel
yum -y install libogg-devel libvorbis libvorbis-devel
./configure --prefix=/opt/icecast/2.4.1
make
make install 

ls /opt/icecast/2.4.1/bin/

cd /opt/icecast
 ln -s 2.4.1 latest
#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml –b
cd /opt/icecast/latest/etc
mv icecast.xml icecast.xml.orig
yum -y install nano
rm -rf /opt/icecast/latest/etc/icecast.xml 
nano  /opt/icecast/latest/etc/icecast.xml 
:'
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
				<Samplerate>22050</Samplerate>22050
				<Channels>-1</Channels>
	</Stream>
	
	
<mount>
<mount-name>/live.mp3</mount-name>
<password>pasword</password>
<max-listeners>500</max-listeners>
<max-listener-duration>3600</max-listener-duration>
<dump-file>cd /music/artist/album/razhavaniazha_morning_18kbps.mp3</dump-file>
<intro></intro>
<fallback-mount>/music/artist/album/razhavaniazha_morning_18kbps.mp3</fallback-mount>
<fallback-override>1</fallback-override>
<fallback-when-full>1</fallback-when-full>
<charset>ISO8859-1</charset>
<public>1</public>
<stream-name>Talkin Games</stream-name>
<stream-description>Gamers Radio</stream-description>
<stream-url>http://5.152.181.82:8000/live.mp3.m3u</stream-url>
<genre>Top40</genre>
<bitrate>8</bitrate>
<type>application/mp3</type>
<subtype>mp3</subtype>
<burst-size>65536</burst-size>
<mp3-metadata-interval>4096</mp3-metadata-interval>
</mount>
	
	
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
     <hostname>5.152.181.82</hostname>
     <listen-socket>
       <port>8000</port>
     </listen-socket>
     <fileserve>1</fileserve>
   
    
	
     <!-- PATHES -->
     <paths>
       <basedir>/opt/icecast/latest/share/icecast</basedir>
       <webroot>/opt/icecast/latest/share/icecast/web</webroot>
       <adminroot>/opt/icecast/latest/share/icecast/admin</adminroot>
       <logdir>/var/log/icecast</logdir>
       <pidfile>/var/run/icecast/icecast.pid</pidfile>
       <alias source="/" dest="/status.xsl"/>
     </paths>
   
     <!-- LOG -->
     <logging>
       <accesslog>access.log</accesslog>
       <errorlog>error.log</errorlog>
       <playlistlog>playlist.log</playlistlog>
       <loglevel>1</loglevel>
       <logsize>10000</logsize>
       <logarchive>1</logarchive>
     </logging>
   
     <!-- SECURITY -->
     <security>
       <chroot>0</chroot>
       <changeowner>
         <user>icecast</user>
         <group>icecast</group>
       </changeowner>
     </security>
   
   </icecast> 
'

#nano 2.4.1/etc/icecast.xml

#Create user to run Icecast with, we are using the username ‘icecast’; 
groupadd -g 200 icecast
useradd -d /var/log/icecast -m -g icecast -s /bin/bash -u 200 icecast

mkdir -p /var/run/icecast
chown -R icecast:icecast /var/run/icecast
#Now give it a try and start the icecast server:
/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b
#open port 8000 in vps by tcp/8000
sudo nano /etc/sysconfig/network
#HOSTNAME=myserver.domain.com
/etc/init.d/network restart


#Setting up the OGG/Vorbis streaming client: ices

cd /usr/src/icecast
wget http://downloads.us.xiph.org/releases/libshout/libshout-2.4.1.tar.gz
tar xf libshout-2.4.1.tar.gz
cd libshout-2.4.1
./configure --prefix=/opt/icecast/latest
make 
make install

#Now download the ices client:
cd /usr/src/icecast
wget http://downloads.us.xiph.org/releases/ices/ices-2.0.2.tar.bz2
 tar xf ices-2.0.2.tar.bz2
 cd ices-2.0.2/
 export PKG_CONFIG_PATH=/opt/icecast/latest/lib/pkgconfig:$PKG_CONFIG_PATH
 ./configure --prefix=/opt/icecast/latest
 make 
 make  install
ls /opt/icecast/latest/bin/
cd /opt/icecast/latest/etc/
nano ices1.xml
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
nano  playlist1.txt
:'/music/artist/album/song1.ogg
/music/artist/album/song2.ogg
'

#Setting up the MP3 streaming client: icegenerator
 
 #To compile icegenerator download the source package from http://sourceforge.net/projects/icegenerator/ and store it in your src directory. Then go into the src directory and extract the source:
cd /usr/src/icecast
wget http://netcologne.dl.sourceforge.net/project/icegenerator/icegenerator/0.5.5-pre2/icegenerator-0.5.5-pre2.tar.gz
tar xfz icegenerator-0.5.5-pre2.tar.gz
cd icegenerator-0.5.5-pre2
export PKG_CONFIG_PATH=/opt/icecast/latest/lib/pkgconfig:$PKG_CONFIG_PATH
./configure # --prefix=/opt/icecast/latest
make 
make install
ls -lah /usr/local/bin/ice*
 cd /usr/local/etc
 rm -rf /usr/local/etc/icegen1.cfg
 nano /usr/local/etc/icegen1.cfg
 #IP=192.168.1.100
 :'
IP=127.0.0.2
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
URL=http://5.152.181.82:8000/
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
#unrar x filename.rar
rm -rf /usr/local/etc/playlist2.m3u
find /music/artist/album/best_2015/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
find /music/artist/album/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
#find /music/artist/album/Shadtarin_Taranehaye_Dahe_60/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
#find /music/artist/album/hel/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
rm -rf /var/log/icecast/icegen1.log
yum -y install  htop

nmap -v -sn 192.168.1.100
su -
firewall-cmd --add-port=8000/tcp --permanent
firewall-cmd --reload
iptables -A INPUT -i eth0 -p tcp --dport 8000 -j ACCEPT

kill -9 `lsof -t -i :8000`
/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b 
#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b -f /usr/local/etc/icegen1.cfg
#/opt/icecast/latest/bin/icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
su - icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
cat /var/log/icecast/icegen1.log
pgrep -fl icecast
pgrep -fl icegen
lsof -t -i  :8000
#rebooting the system