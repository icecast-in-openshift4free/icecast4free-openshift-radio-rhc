#!/bin/bash 

PYTHON_VERSION="2.7.4"
PCRE_VERSION="8.35"
#NGINX_VERSION="1.6.0"
#NGINX_VERSION="1.10.1"
NGINX_VERSION="1.9.2"
MEMCACHED_VERSION="1.4.15"
ZLIB_VERSION="1.2.8"
#PHP_VERSION="5.5.9"
PHP_VERSION="5.4.27"

APC_VERSION="3.1.13"
libyaml_package="yaml-0.1.4"

if [[ "$HOME" = "" ]];then
	Current_DIR="$PWD"
	echo 'Current_DIR is:'
	echo $Current_DIR
else
	echo 'Current_DIR is home:'
	export  Current_DIR="$HOME"
	echo $Current_DIR
    
fi

if [[ "$OPENSHIFT_LOG_DIR" = "" ]];then
	#echo "$OPENSHIFT_LOG_DIR" > "$OPENSHIFT_HOMEDIR/.env/OPENSHIFT_DIY_LOG_DIR"
    if [ ! -d ${Current_DIR}/openshifts ]; then	        
	    mkdir  ${Current_DIR}/openshifts
    fi
	
    if [ ! -d ${Current_DIR}/openshifts/logs ]; then	
        mkdir ${Current_DIR}/openshifts/logs
    fi
	
	export OPENSHIFT_LOG_DIR="$Current_DIR/openshifts/logs/"
	echo 'OPENSHIFT_LOG_DIR is:'
	echo $OPENSHIFT_LOG_DIR
else
   echo "$OPENSHIFT_LOG_DIR Exists"
fi

if [[ "$OPENSHIFT_TMP_DIR" = "" ]]; then	
	#mkdir  ${Current_DIR}/openshifts
    if [ ! -d ${Current_DIR}/openshifts/tmp ]; then	
        mkdir ${Current_DIR}/openshifts/tmp
    fi
	export OPENSHIFT_TMP_DIR="$Current_DIR/openshifts/tmp/"
	echo 'OPENSHIFT_TMP_DIR2 is:'
	echo $OPENSHIFT_TMP_DIR
fi


if [ "$OPENSHIFT_HOMEDIR" = "" ]; then	
	if [ ! -d ${Current_DIR}/openshifts/app-root ]; then	
        mkdir ${Current_DIR}/openshifts/app-root
	fi
	
	if [ ! -d ${Current_DIR}/openshifts/app-root/runtime ]; then	
        mkdir ${Current_DIR}/openshifts/app-root/runtime
	fi
	
	
	export OPENSHIFT_HOMEDIR="$Current_DIR/openshifts/"
	echo 'OPENSHIFT_HOMEDIR is:'
	echo $OPENSHIFT_HOMEDIR
else
	echo 'OPENSHIFT_HOMEDIR exist:'
	echo $OPENSHIFT_HOMEDIR
fi

if [ "$OPENSHIFT_REPO_DIR" = "" ]; then	
	export  OPENSHIFT_REPO_DIR=$OPENSHIFT_HOMEDIR
	echo 'OPENSHIFT_REPO_DIR is:'
	echo $OPENSHIFT_REPO_DIR
fi
if [ "OPENSHIFT_REPO_DIR" = "" ]; then	
	export  OPENSHIFT_REPO_DIR="$PWD"
	echo 'OPENSHIFT_REPO_DIR is:'
	echo $OPENSHIFT_REPO_DIR
fi
echo 'Current_DIR is:'
echo ${Current_DIR}

if [  -d ${Current_DIR}/.openshift/action_hooks/common ]; then	
    source ${Current_DIR}/.openshift/action_hooks/common
fi


if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv ]; then	
    mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv
	echo 'mkdir is:'
	echo ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv
fi


#cd
#git clone 
#gem build rhc.gemspec

rm -rf $OPENSHIFT_TMP_DIR/*

mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast
mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast/download
mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast/server
cd $OPENSHIFT_TMP_DIR/

wget http://download.nullsoft.com/shoutcast/tools/sc_serv2_linux_x64_09_09_2014.tar.gz

tar xfz sc_serv2_linux_x64_09_09_2014.tar.gz
ls
cp  sc_serv  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast/server/
cd  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast/server
ls

mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast/server/control
mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast/server/
mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/shoutcast/log
ls

rm -rf $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf
cat << 'EOT' > $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf

adminpassword=password
password=password1
requirestreamconfigs=1
streamadminpassword_1=password2
streamid_1=1
streampassword_1=password3
streampath_1=http://$OPENSHIFT_GEAR_DNS:80
logfile=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/shoutcast/log/sc_serv.log
w3clog=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/shoutcast/log/sc_w3c.log
banfile=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/shoutcast/server/control/sc_serv.ban
ripfile=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/shoutcast/server/control/sc_serv.rip
EOT
sed -i 's/OPENSHIFT_INTERNAL_PORT/'${OPENSHIFT_DIY_PORT}'/g' $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf	
sed -i 's@$OPENSHIFT_HOMEDIR@'${OPENSHIFT_HOMEDIR}'@g'  $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf
sed -i 's@$OPENSHIFT_DIY_LOG_DIR@'${OPENSHIFT_DIY_LOG_DIR}'@g'  $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf		
sed -i 's/OPENSHIFT_INTERNAL_IP/'${OPENSHIFT_DIY_IP}'/g' $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf	
sed -i 's@$OPENSHIFT_GEAR_DNS@'${OPENSHIFT_GEAR_DNS}'@g'  $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf

cat $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/sc_serv.conf

cd $OPENSHIFT_TMP_DIR/

./builder.sh

sudo apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1
sudo apt-get install -y 	 gcc-multilib
apt-get install -y  ia32-libs

/etc/hostname

./sc_serv /root/server/sc_serv.conf

ps aux | grep sc_serv
# If you want to automatically start the server after reboot,
whoami 
echo 'cd /home/radio/server' >> ~/.bashrc
echo './sc_serv    /root/server/sc_serv.conf' >> ~/.bashrc
curl http://5.152.181.113:8000



apt install at

cat << 'EOF' > /usr/local/bin/radio
#!/bin/bash
case $1 in
                start)
cd /home/radio/server/
./sc_serv &
              ;;
                stop)
killall sc_serv
                ;;
               start_daemon)
cd /home/radio/server/
./sc_serv daemon
               ;;
                *)
echo "Usage radio start|stop"
                ;;
esac
EOF
chmod +x /usr/local/bin/radio

nano /usr/local/bin/radio


#on centos
#https://www.howtoforge.com/how-to-install-a-streaming-audio-server-with-icecast-2.3.3-on-centos-6.3-x86_64-linux
apt-get groupinstall “Development Tools”
apt-get install  curl-devel libtheora-devel libvorbis-devel libxslt-devel speex-devel libxslt
#apt-get  install autoconf automake cmake freetype-devel gcc gcc-c++ git libtool make mercurial nasm pkgconfig zlib-devel

rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt

apt-get  groupinstall "Development tools"
apt-get  install gcc
apt-get  install wget mail htop
apt-get  install lsof sox 
apt-get –y update

mkdir -p /usr/src/icecast
cd /usr/src/icecast
apt-get install wget
wget http://downloads.xiph.org/releases/icecast/icecast-2.4.1.tar.gz
tar xf icecast-2.4.1.tar.gz
cd icecast-2.4.1/
apt-get  install libxslt-devel
apt-get  install libogg-devel libvorbis libvorbis-devel
./configure --prefix=/opt/icecast/2.4.1
make
make install 

ls /opt/icecast/2.4.1/bin/

cd /opt/icecast
 ln -s 2.4.1 latest
#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml –b
cd /opt/icecast/latest/etc
mv icecast.xml icecast.xml.orig
apt-get  install nano
rm -rf icecast.xml 
nano  icecast.xml 
:'
<icecast>
   
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
     </limits>
   
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
 cd /usr/src/icecast
 wget http://downloads.us.xiph.org/releases/libshout/libshout-2.4.1.tar.gz
 tar xf libshout-2.4.1.tar.gz
 cd libshout-2.4.1
 ./configure --prefix=/opt/icecast/latest
 make 
 make  install 
 #To compile icegenerator download the source package from http://sourceforge.net/projects/icegenerator/ and store it in your src directory. Then go into the src directory and extract the source:
cd /usr/src/icecast
wget http://netcologne.dl.sourceforge.net/project/icegenerator/icegenerator/0.5.5-pre2/icegenerator-0.5.5-pre2.tar.gz
tar xfz icegenerator-0.5.5-pre2.tar.gz
cd icegenerator-0.5.5-pre2
./configure # --prefix=/opt/icecast/latest
make 
make install
ls -lah /usr/local/bin/ice*
 cd /usr/local/etc
 nano icegen1.cfg
 
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
URL=http://5.152.181.82:8000/
LOG=2
LOGPATH=/var/log/icecast/icegen1.log
BITRATE=48000
SOURCE=source
'
mkdir /music/
mkdir /music/artist
mkdir /music/artist/album/
 cd /music/artist/album/
wget http://www.mediafire.com/download/m79b6et2k26v82z/14.06.2016_razhavaniazha_morning_18kbps.mp3

cd /music/artist/album/
mv 14.06.2016_razhavaniazha_morning_18kbps.mp3 razhavaniazha_morning_18kbps.mp3
#sox razhavaniazha_morning_18kbps.mp3 razhavaniazha_morning_18kbps.ogg
ls
rm -rf /usr/local/etc/playlist2.m3u
find /music/artist/album/ -name "*.mp3" > /usr/local/etc/playlist2.m3u
rm -rf /var/log/icecast/icegen1.log
apt-get  install wget mail htop
kill -9 `lsof -t -i :8000`
/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b 
#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b -f /usr/local/etc/icegen1.cfg
#/opt/icecast/latest/bin/icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
su - icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
cat /var/log/icecast/icegen1.log
lsof -t -i  :8000
 rebooting the system