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

if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/telegram ]; then	
    mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/telegram
	echo 'mkdir is: telegram'
	echo ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/telegram
	
	## OR
	cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/telegram
	 git clone --recursive https://github.com/vysheng/tg.git && mv tg/* . && rm -rf tg
	 ./configure --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/telegram  --disable-libconfig  --disable-json
	 
	 #export CFLAGS="-I/usr/local/include -I/opt/local/include -I/opt/local/include/lua-5.1"
	 #export LDFLAGS="-L/usr/local/lib -L/opt/local/lib -L/opt/local/lib/lua-5.1"
	 #mkdir /app/telegram && ./configure --prefix=/app/telegram --disable-libconfig  --disable-json  --disable-liblua
	  make 
	 
	
fi

rm -rf $OPENSHIFT_TMP_DIR/*


#rm -rf $OPENSHIFT_HOMEDIR/app-root/runtime/repo/.openshift/action_hooks/start
cp ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/new-radiostation/.openshift/action_hooks/start    $OPENSHIFT_HOMEDIR/app-root/runtime/repo/.openshift/action_hooks/start 

cp -Rf ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/new-radiostation/.openshift/.    $OPENSHIFT_HOMEDIR/app-root/runtime/repo/.openshift/

#chmod -rwxr-xr-x $OPENSHIFT_HOMEDIR/app-root/runtime/repo/.openshift/action_hooks/start
chmod 755 $OPENSHIFT_HOMEDIR/app-root/runtime/repo/.openshift/action_hooks/start

if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin ]; then	
	cd $OPENSHIFT_TMP_DIR
	

	wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
	tar zxf nginx-${NGINX_VERSION}.tar.gz
	rm  nginx-${NGINX_VERSION}.tar.gz
	wget http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-${PCRE_VERSION}.tar.gz
	#wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
	tar zxf pcre-${PCRE_VERSION}.tar.gz
	rm pcre-${PCRE_VERSION}.tar.gz
	wget http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
	tar -zxf zlib-${ZLIB_VERSION}.tar.gz
	rm zlib-${ZLIB_VERSION}.tar.gz
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx ]; then
      mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx
    fi
	
	#git clone https://github.com/cep21/healthcheck_nginx_upstreams.git
	cd nginx-${NGINX_VERSION}
	#patch -p1 < $OPENSHIFT_TMP_DIR/healthcheck_nginx_upstreams/nginx.patch
	
	
	cd $OPENSHIFT_TMP_DIR
	#git clone https://github.com/yaoweibin/nginx_upstream_check_module.git #patched for newer version
	git clone https://github.com/power-electro/nginx_upstream_check_module.git
	cd nginx-${NGINX_VERSION}
	#patch -p1 < $OPENSHIFT_TMP_DIR/nginx_upstream_check_module/check_1.9.2+.patch
	
	cd $OPENSHIFT_TMP_DIR
	git clone https://github.com/gnosek/nginx-upstream-fair.git
	cd nginx-upstream-fair
	#patch -p2 < $OPENSHIFT_TMP_DIR/nginx_upstream_check_module/upstream_fair.patch
	
	cd $OPENSHIFT_TMP_DIR
	git clone https://github.com/arut/nginx-rtmp-module	
	
	cd nginx-${NGINX_VERSION}
	#
	
	./configure\
	   --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx\
	   --with-pcre=$OPENSHIFT_TMP_DIR/pcre-${PCRE_VERSION}\
	   --with-zlib=$OPENSHIFT_TMP_DIR/zlib-${ZLIB_VERSION}\
	   --with-http_ssl_module\
	   --with-http_realip_module \
	   --with-http_addition_module \
	   --with-http_sub_module\
	   --with-http_dav_module \
	   --with-http_flv_module \
	   --with-http_mp4_module \
	   --with-http_gunzip_module\
	   --with-http_gzip_static_module \
	   --with-http_random_index_module \
	   --with-http_secure_link_module\
	   --with-http_stub_status_module \
	   --with-mail \
	   --with-mail_ssl_module \
	   --with-file-aio\
	   --with-ipv6\
	   --add-module=$OPENSHIFT_TMP_DIR/nginx-upstream-fair\
	   --add-module=$OPENSHIFT_TMP_DIR/nginx-rtmp-module
	   #--add-module=$OPENSHIFT_TMP_DIR/nginx_upstream_check_module
	   make && make install && make clean   # " > $OPENSHIFT_LOG_DIR/Nginx_config.log 2>&1 & 
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/Nginx_config.log'
	
	#nohup sh -c "make && make install && make clean"  > $OPENSHIFT_LOG_DIR/nginx_install.log /dev/null 2>&1 &  
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/nginx_install.log
	#./configure --with-pcre=$OPENSHIFT_TMP_DIR/pcre-8.35 --prefix=$OPENSHIFT_DATA_DIR/nginx --with-http_realip_module
	#make &&	make install
#cp ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf.default ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf
rm -rf ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf
 cat << 'EOT' > $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/conf/nginx.conf
 #user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
    error_log $OPENSHIFT_HOMEDIR/app-root/logs/nginx_error.log debug;

    pid $OPENSHIFT_HOMEDIR/app-root/runtime/srv/nginx/logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;
    #access_log $OPENSHIFT_DIY_LOG_DIR/access.log main;
    port_in_redirect off;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  265;

    gzip  on;
	
	upstream frontends {
	
        #server pr4ss.tk;
        #server 222.66.115.233:80 weight=1;
		server OPENSHIFT_INTERNAL_IP:8081 ;
		
    }
	upstream onair {
	    ip_hash;
        server OPENSHIFT_INTERNAL_IP:15002 weight=1;
        
		
    }
	upstream main {
        ip_hash;
        fair;
		server OPENSHIFT_INTERNAL_IP:15001 weight=1;
		server OPENSHIFT_INTERNAL_IP:15002 weight=1;
		keepalive 3;
		
    }
	upstream github {
		
		server  github.com;
	}
	limit_req_zone $binary_remote_addr zone=one:10m rate=30r/m;
	limit_req_zone $binary_remote_addr zone=one2:10m rate=1r/m;
	limit_req_zone $http_x_forwarded_for zone=one3:10m rate=1r/m;
	proxy_cache_path  /tmp  levels=1:2    keys_zone=RUBYGEMS:10m  inactive=24h  max_size=100m;

    server {
        listen      OPENSHIFT_INTERNAL_IP:OPENSHIFT_INTERNAL_PORT;
        server_name  $OPENSHIFT_GEAR_DNS www.$OPENSHIFT_GEAR_DNS;
		root $OPENSHIFT_REPO_DIR;


		set_real_ip_from OPENSHIFT_INTERNAL_IP;
		real_ip_header X-Forwarded-For;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
		location  ~* ^/(.*) {
		 proxy_pass http://main;
		 #proxy_read_timeout 5s;
		 proxy_connect_timeout 1s;
		 access_log off;
		 proxy_cache RUBYGEMS;
		 proxy_cache_valid 200 302 365d;
		 proxy_cache_valid 404 1m;
		 #health_check match=welcome;
		 
		  proxy_buffering           off;
            proxy_ignore_client_abort off;
            proxy_intercept_errors    on;
            proxy_next_upstream       error timeout invalid_header;
            proxy_redirect            off;
            proxy_set_header          X-Host $http_host;
            proxy_set_header          X-Forwarded-For $remote_addr;
            proxy_send_timeout        21600;
            proxy_read_timeout        21600; 
		 
		}
		
        location  /onair {
		 proxy_pass http://onair;
		 #proxy_read_timeout 5s;
		 proxy_connect_timeout 1s;
		 access_log off;
		 proxy_cache RUBYGEMS;
		 proxy_cache_valid 200 302 365d;
		 proxy_cache_valid 404 1m;
		 #health_check match=welcome;
		 
		  proxy_buffering           off;
            proxy_ignore_client_abort off;
            proxy_intercept_errors    on;
            proxy_next_upstream       error timeout invalid_header;
            proxy_redirect            off;
            proxy_set_header          X-Host $http_host;
            proxy_set_header          X-Forwarded-For $remote_addr;
            proxy_send_timeout        21600;
            proxy_read_timeout        21600; 
		 
		}
		#location ~* ^/(.*) {
		location /main {
			proxy_set_header Host $OPENSHIFT_GEAR_DNS;
			#proxy_redirect  http://ff.rhcloud.com/ http://lasa2.rhcloud.com/;
			proxy_pass http://onair/$1$is_args$args;
		}
		
		location /github {
			proxy_set_header Host $OPENSHIFT_GEAR_DNS;
			#proxy_redirect  http://ff.rhcloud.com/ http://lasa2.rhcloud.com/;
			proxy_pass http://github/$1$is_args$args;
		}
		
		

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            root           html;
            fastcgi_pass   OPENSHIFT_INTERNAL_IP:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
            include        fastcgi_params;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443;
    #    server_name  localhost;

    #    ssl                  on;
    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_timeout  5m;

    #    ssl_protocols  SSLv2 SSLv3 TLSv1;
    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers   on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
}
EOT

sed -i 's/OPENSHIFT_INTERNAL_PORT/'${OPENSHIFT_DIY_PORT}'/g'  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf	
sed -i 's@$OPENSHIFT_HOMEDIR@'${OPENSHIFT_HOMEDIR}'@g'  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf	
sed -i 's/OPENSHIFT_INTERNAL_IP/'${OPENSHIFT_DIY_IP}'/g'  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf	
sed -i 's@$OPENSHIFT_GEAR_DNS@'${OPENSHIFT_GEAR_DNS}'@g'  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf
sed -i 's@$OPENSHIFT_DIY_LOG_DIR@'${OPENSHIFT_DIY_LOG_DIR}'@g'  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf		
sed -i 's@$OPENSHIFT_REPO_DIR@'${OPENSHIFT_REPO_DIR}'@g'  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf		

cat ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf
fi


echo "INSTALL PHP"
#if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin ]; then
if [ ! "1"="1" ]; then
	cd $OPENSHIFT_TMP_DIR
	wget http://us1.php.net/distributions/php-${PHP_VERSION}.tar.gz
	tar zxf php-${PHP_VERSION}.tar.gz
	#rm  zxf php-${PHP_VERSION}.tar.gz
	cd php-${PHP_VERSION}
	#wget -c http://us.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror
	#tar -zxf mirror	
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION} ]; then
       mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}
    fi
	#cd php-${PHP_VERSION}
	
	./configure --with-mysql=mysqlnd\
        --with-mysqli=mysqlnd --with-xmlrpc --with-pdo-mysql=mysqlnd\
        --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}\
        --enable-fpm --with-zlib --enable-xml --enable-bcmath --with-curl --with-gd \
        --enable-zip --enable-mbstring --enable-sockets --enable-ftp #"  > $OPENSHIFT_LOG_DIR/php_install_conf.log /dev/null 2>&1 &  
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_install_conf.log'
	make && make install && make clean #"  > $OPENSHIFT_LOG_DIR/php_install.log 2>&1 &  
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_install.log'
	#./configure --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-5.4.27 --enable-fpm --with-zlib --enable-xml --enable-bcmath --with-curl --with-gd --enable-zip --enable-mbstring --enable-sockets --enable-ftp
#	make && make install
	cp  $OPENSHIFT_TMP_DIR/php-${PHP_VERSION}/php.ini-production ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/lib/php.ini
fi	
echo "Cleanup"
cd $OPENSHIFT_TMP_DIR
rm -rf *
#PYTHON_CURRENT=`${OPENSHIFT_RUNTIME_DIR}/srv/python/bin/python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`

#checked
#if [ "$PYTHON_CURRENT" != "$PYTHON_VERSION" ]; then
if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin ]; then
	cd $OPENSHIFT_TMP_DIR
	
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv ]; then
	   mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv
    fi
	if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python ]; then
	   mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python
    fi
	rm Python-${PYTHON_VERSION}.tar.bz2
	wget http://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.bz2
	tar jxf Python-${PYTHON_VERSION}.tar.bz2
	#rm -rf Python-${PYTHON_VERSION}.tar.bz2
	cd Python-${PYTHON_VERSION}
	
	#./configure --prefix=$OPENSHIFT_DATA_DIR
	./configure --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python && make install && make clean #"   > $OPENSHIFT_LOG_DIR/pyhton_install.log 2>&1 &
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/pyhton_install.log'
	#nohup sh -c "make && make install && make clean"   >  $OPENSHIFT_LOG_DIR/pyhton_install.log 2>&1 &
	
	export "export path"
	export PATH=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin:$PATH
	nohup sh -c "export PATH=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/python/bin:$PATH " > $OPENSHIFT_LOG_DIR/path_export2.log 2>&1 &
	echo '--Install Setuptools--'

	cd $OPENSHIFT_TMP_DIR
	wget http://peak.telecommunity.com/dist/ez_setup.py
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ez_setup.py
	
	#installing easy_install
	wget https://pypi.python.org/packages/source/s/setuptools/setuptools-1.1.6.tar.gz #md5=ee82ea53def4480191061997409d2996
	tar xzvf setuptools-1.1.6.tar.gz
	rm setuptools-1.1.6.tar.gz
	cd setuptools-1.1.6	
	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python setup.py install
	
	OPENSHIFT_RUNTIME_DIR=${OPENSHIFT_HOMEDIR}/app-root/runtime
	OPENSHIFT_REPO_DIR=${OPENSHIFT_HOMEDIR}/app-root/runtime/repo
	echo '---Install pip---'
	cd $OPENSHIFT_TMP_DIR
	curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python get-pip.py
	mkdir trash
	cd trash
	wget http://entrian.com/goto/goto-1.0.zip
	unzip goto-1.0.zip
	cd goto-1.0
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python setup.py install
	
	#memcached for python
	wget ftp://ftp.tummy.com/pub/python-memcached/python-memcached-latest.tar.gz
	tar -zxvf python-memcached-latest.tar.gz
	cd python-memcached-*	
	$OPENSHIFT_HOMEDIR/app-root/runtime/srv/python/bin/python setup.py install
	cd ../..
	rm -rf trash
	
	cd
	echo '---instlling tornado -----'
	#nohup sh -c "\
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pyPdf && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pypdftk && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install robobrowser 
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install httplib2 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install hurry.filesize && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install tornado==4.2.1 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install reportlab && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install BeautifulSoup==3.2.1 && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install mechanize==0.2.5 && \	
fi

#on centos
#https://www.howtoforge.com/how-to-install-a-streaming-audio-server-with-icecast-2.3.3-on-centos-6.3-x86_64-linux

cd /tmp
mkdir $OPENSHIFT_REPO_DIR/srv/ogg
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
 tar -xf libogg-1.3.2.tar.gz

cd libogg-1.3.2 

./configure --prefix=$OPENSHIFT_REPO_DIR/srv/ogg

make && make install


mkdir $OPENSHIFT_REPO_DIR/srv/libvorbis
cd /tmp
wget downloads.xiph.org/releases/vorbis/libvorbis-1.1.2.tar.gz
tar xf libvorbis-1.1.2.tar.gz
cd libvorbis-1.1.2/
#yum -y install libxslt-devel
#yum -y install libogg-devel libvorbis libvorbis-devel
./configure  --prefix=$OPENSHIFT_REPO_DIR/srv/libvorbis --with-ogg=$OPENSHIFT_REPO_DIR/srv/ogg
make
make install 
export PATH=$OPENSHIFT_REPO_DIR/srv/libvorbis/:$PATH

mkdir $OPENSHIFT_REPO_DIR/srv/icecast

cd /tmp

wget http://downloads.xiph.org/releases/icecast/icecast-2.4.1.tar.gz
tar xf icecast-2.4.1.tar.gz
cd icecast-2.4.1/
#yum -y install libxslt-devel
#yum -y install libogg-devel libvorbis libvorbis-devel
./configure \
--prefix=$OPENSHIFT_REPO_DIR/srv/icecast --with-ogg=$OPENSHIFT_REPO_DIR/srv/ogg \
--with-vorbis=$OPENSHIFT_REPO_DIR/srv/libvorbis
make
make install 

ls $OPENSHIFT_REPO_DIR/srv/icecast/bin/

cd $OPENSHIFT_REPO_DIR/srv/icecast
 
#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml –b
cd $OPENSHIFT_REPO_DIR/srv/icecast/etc
cp  icecast.xml icecast.xml.orig

rm -rf $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml 
#cp icecast.xml.orig icecast.xml
cat <<EOT >> $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml
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
      <shoutcast-mount>/onair</shoutcast-mount>
	  <fallback-mount>/boplive2</fallback-mount>
     </listen-socket>
     <fileserve>1</fileserve>
   
   
   <mount>
        <mount-name>/stream</mount-name>
        <fallback-mount>/onair</fallback-mount>
        <fallback-override>1</fallback-override>
        <hidden>0</hidden>
        <public>1</public>
    </mount>

    <mount>
        <mount-name>/onair</mount-name>
        <password>password</password>
        <bitrate>96</bitrate>
        <type>audio/mp3</type>
        <subtype>mp3</subtype>
        <fallback-mount>/offair</fallback-mount>
        <fallback-override>1</fallback-override>
        <hidden>0</hidden>
    </mount>

    <mount>
        <mount-name>/offair</mount-name>
        <password>password</password>
        <dump-file>/tmp/dump-offair.mp3</dump-file>
        <bitrate>96</bitrate>
        <type>audio/mp3</type>
        <subtype>mp3</subtype>
    </mount>
	
     <relays-on-demand>1</relays-on-demand>


    
    <relay> <!-- Remote Server for on demand relay -->
       <server>hostname_localhost</server>
       <port>8000</port>
       <mount>/radiostation3</mount>
       <local-mount>/remotemount</local-mount> <!-- can change name if wanted -->
       <on-demand>1</on-demand>
       <password>password</password>
       <relay-shoutcast-metadata>1</relay-shoutcast-metadata>
    </relay>

     <!-- PATHES -->
     <paths>
       <basedir>$OPENSHIFT_REPO_DIR/srv/icecast/share/icecast</basedir>
       <webroot>$OPENSHIFT_REPO_DIR/srv/icecast/share/icecast/web</webroot>
       <adminroot>$OPENSHIFT_REPO_DIR/srv/icecast/share/icecast/admin</adminroot>
       <logdir>$OPENSHIFT_REPO_DIR/srv/icecast/var/log/icecast</logdir>
       <pidfile>$OPENSHIFT_REPO_DIR/srv/icecast/share/icecast/icecast.pid</pidfile>
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

#rm -rf $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml 
#cp icecast.xml.orig icecast.xml

#cat $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml
sed -i 's/hostname_localhost/'${OPENSHIFT_GEAR_DNS}'/g'  $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml
sed -i 's/localhost/'${OPENSHIFT_DIY_IP}'/g'  $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml
sed -i 's/$OPENSHIFT_REPO_DIR/srv/'${OPENSHIFT_REPO_DIR}'/g'  $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml
sed -i 's/8000/15001/g'  $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml
#sed -i 's/hostname_localhost/54.172.97.196/g'  $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml


mkdir $OPENSHIFT_REPO_DIR/srv/icecast/var
mkdir $OPENSHIFT_REPO_DIR/srv/icecast/var/log
mkdir $OPENSHIFT_REPO_DIR/srv/icecast/var/log/icecast
#kill -9 `lsof -t -i :8080`
#Now give it a try and start the icecast server:
#$OPENSHIFT_REPO_DIR/srv/icecast/bin/icecast -c $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml -b


#lsof -t -i :8080
#lsof -t -i :8000
#npm
#ps aux

#Setting up the OGG/Vorbis streaming client: ices
mkdir $OPENSHIFT_REPO_DIR/srv/libshout

cd /tmp
wget http://downloads.us.xiph.org/releases/libshout/libshout-2.4.1.tar.gz
tar xf libshout-2.4.1.tar.gz
cd libshout-2.4.1
./configure \
--prefix=$OPENSHIFT_REPO_DIR/srv/libshout --with-ogg=$OPENSHIFT_REPO_DIR/srv/ogg \
--with-vorbis=$OPENSHIFT_REPO_DIR/srv/libvorbis
make 
make install

#Now download the ices client:
mkdir $OPENSHIFT_REPO_DIR/srv/ices
if [ ! -d ${OPENSHIFT_REPO_DIR}/srv/ices ]; then

	cd /tmp
	wget http://downloads.us.xiph.org/releases/ices/ices-2.0.2.tar.bz2
	tar xf ices-2.0.2.tar.bz2
	cd ices-2.0.2/
	export PKG_CONFIG_PATH=$OPENSHIFT_REPO_DIR/srv/ogg/lib/pkgconfig:$OPENSHIFT_REPO_DIR/srv/libvorbis/lib/pkgconfig:$OPENSHIFT_REPO_DIR/srv/libshout/lib/pkgconfig:$PKG_CONFIG_PATH
	./configure --prefix=$OPENSHIFT_REPO_DIR/srv/ices --with-ogg=$OPENSHIFT_REPO_DIR/srv/ogg  #--with-vorbis=$OPENSHIFT_REPO_DIR/srv/libvorbis

	make 
	make  install
 
 
	ls $OPENSHIFT_REPO_DIR/srv/ices/

	rm -rf $OPENSHIFT_REPO_DIR/srv/ices/ices1.xml 
	cat <<EOT >> $OPENSHIFT_REPO_DIR/srv/ices/ices1.xml
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
         <url>http://hostname_localhost:80/</url>
       </metadata>
       <input>
         <param name="type">basic</param>
         <param name="file">$OPENSHIFT_REPO_DIR/srv/ices/playlist1.txt</param>
         <param name="random">1</param>
         <param name="once">0</param>
         <param name="restart-after-reread">1</param>
       </input>
       <instance>
         <hostname>hostname_localhost</hostname>
         <port>8000</port>
         <password>password</password>
         <mount>/radiostation1</mount>
       </instance>
     </stream>
   
   </ices>
EOT
 
 
	#cat $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml
	sed -i 's/hostname_localhost/'${OPENSHIFT_GEAR_DNS}'/g'  $OPENSHIFT_REPO_DIR/srv/ices/ices1.xml
	sed -i 's/localhost/'${OPENSHIFT_DIY_IP}'/g'  $OPENSHIFT_REPO_DIR/srv/ices/ices1.xml
	sed -i 's/$OPENSHIFT_REPO_DIR/srv/'${OPENSHIFT_REPO_DIR}'/g'  $OPENSHIFT_REPO_DIR/srv/ices/ices1.xml
	sed -i 's/8000/15001/g' $OPENSHIFT_REPO_DIR/srv/ices/ices1.xml

fi

#Setting up the MP3 streaming client: icegenerator
 
 #To compile icegenerator download the source package from http://sourceforge.net/projects/icegenerator/ and store it in your src directory. Then go into the src directory and extract the source:
cd /tmp
mkdir $OPENSHIFT_REPO_DIR/srv/icegenerator
mkdir $OPENSHIFT_REPO_DIR/srv/icegenerator/bin
wget http://netcologne.dl.sourceforge.net/project/icegenerator/icegenerator/0.5.5-pre2/icegenerator-0.5.5-pre2.tar.gz
tar xfz icegenerator-0.5.5-pre2.tar.gz
cd icegenerator-0.5.5-pre2
export PKG_CONFIG_PATH=$OPENSHIFT_REPO_DIR/srv/ogg/lib/pkgconfig:$OPENSHIFT_REPO_DIR/srv/libvorbis/lib/pkgconfig:$OPENSHIFT_REPO_DIR/srv/libshout/lib/pkgconfig:$PKG_CONFIG_PATH
#nohup sh -c "./configure  --prefix=$OPENSHIFT_REPO_DIR/srv/icegenerator --bindir=$OPENSHIFT_REPO_DIR/srv/icegenerator/bin --with-shout=$OPENSHIFT_REPO_DIR/srv/libshout/ "   >  $OPENSHIFT_LOG_DIR/icegenerator_install.log 2>&1 &
#tail -f  $OPENSHIFT_LOG_DIR/icegenerator_install.log 
./configure  --prefix=$OPENSHIFT_REPO_DIR/srv/icegenerator --bindir=$OPENSHIFT_REPO_DIR/srv/icegenerator/bin #--with-shout=$OPENSHIFT_REPO_DIR/srv/libshout
make 
make install

ls -lah $OPENSHIFT_REPO_DIR/srv/icegenerator/bin/ice*
 cd $OPENSHIFT_REPO_DIR/srv/icegenerator
 rm -rf $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg
 #nano $OPENSHIFT_REPO_DIR/srv/icecast/etc/icegen1.cfg
 #IP=192.168.1.100 SHUFFLE=0 for linear writing SHUFFLE=1 for random 
cat <<EOT > $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg
IP=OPENSHIFT_DIY_IP
PORT=8000
SERVER=2
MOUNT=/radiostation1
PASSWORD=password
FORMAT=1
MP3PATH=m3u:$OPENSHIFT_REPO_DIR/srv/icecast/playlist2.m3u
LOOP=1
SHUFFLE=1
NAME=RadioStation 2: MP3
DESCRIPTION=Test Radio
GENRE=Varios
URL=http://$OPENSHIFT_GEAR_DNS:80/radiostation1
LOG=2
LOGPATH=$OPENSHIFT_REPO_DIR/srv/icecast/var/log/icecast/icegen1.log
BITRATE=8
SOURCE=source
EOT

sed -i 's/OPENSHIFT_GEAR_DNS/'${OPENSHIFT_GEAR_DNS}'/g'  $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg
sed -i 's/OPENSHIFT_REPO_DIR/'${OPENSHIFT_REPO_DIR}'/g'  $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg
sed -i 's/OPENSHIFT_DIY_IP/'${OPENSHIFT_DIY_IP}'/g'  $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg
sed -i 's/8000/15001/g' $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg
cat $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg
cp  $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg $OPENSHIFT_REPO_DIR/srv/icecast/etc/icegen1.cfg

mkdir $OPENSHIFT_REPO_DIR/srv/lame
cd /tmp
wget http://heanet.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xvfz lame-3.99.5.tar.gz
cd lame-3.99.5
./configure  --prefix=$OPENSHIFT_REPO_DIR/srv/lame
make
make install 
export PATH=$OPENSHIFT_REPO_DIR/srv/lame/bin:$PATH
#Usage:
#$OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input -b <bitrate> <file.mp3> <destination.mp3> 
cd $OPENSHIFT_REPO_DIR/srv/icecast/music
#for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input -b 18 "$f" $OPENSHIFT_REPO_DIR/srv/icecast/music/"$f" ; done


mkdir $OPENSHIFT_REPO_DIR/srv/SoX
cd /tmp
# git clone git://git.code.sf.net/p/sox/code sox
wget http://tenet.dl.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2.tar.gz
tar xvfz sox-14.4.2.tar.gz
cd sox-14.4.2
./configure  --prefix=$OPENSHIFT_REPO_DIR/srv/SoX #--with-lame=$OPENSHIFT_REPO_DIR/srv/lame
make -s
make install 


export PATH=$OPENSHIFT_REPO_DIR/srv/SoX/bin:$PATH
#$OPENSHIFT_REPO_DIR/srv/icecast/playlist2.m3u
mkdir $OPENSHIFT_REPO_DIR/srv/icecast/music
mkdir $OPENSHIFT_REPO_DIR/srv/icecast/music/album
: '
cd $OPENSHIFT_REPO_DIR/srv/icecast/music/album
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
for f in $OPENSHIFT_REPO_DIR/srv/icecast/music/album *; do mv "$f" "${f// /_}"; done
'

cd $OPENSHIFT_REPO_DIR/srv/icecast/music/album
mkdir $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k_en
cd $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k_en
: '
wget https://archive.org/compress/top60greatestenglishsongs/formats=VBR%20MP3&file=/top60greatestenglishsongs.zip
unzip * 
wget -r -l1 -H -t1 -nd -N -np -A.mp3 -erobots=off  https://24music.org/%D9%85%D8%AC%D9%85%D9%88%D8%B9%D9%87-%DB%B1%DB%B0%DB%B0-%D8%A2%D9%87%D9%86%DA%AF-%D8%AE%D8%A7%D8%B1%D8%AC%DB%8C-%D9%82%D8%AF%DB%8C%D9%85%DB%8C-%D8%A8%D8%B1%D8%AA%D8%B1-%D8%AF%D9%87%D9%87-%DB%B7%DB%B0/
for f in $OPENSHIFT_REPO_DIR/srv/icecast/music/album *; do mv "$f" "${f// /_}"; done
for f in $OPENSHIFT_REPO_DIR/srv/icecast/music/album *; do mv "$f" "${f//(/__}"; done
for f in $OPENSHIFT_REPO_DIR/srv/icecast/music/album *; do mv "$f" "${f//)/__}"; done
'
for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input --abr 18 -b 18 -F -V 9.999  "$f" $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k_en/"$f" && rm -rf "$f" ; done
cd $OPENSHIFT_REPO_DIR/srv/icecast/music/album && for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input --abr 18 -b 18 -F -V 9.999  "$f" $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k_en/"$f" && rm -rf "$f" ; done
#for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input --abr 18 -b 18 -F -V 9.999  "$f" ./"$f" && rm -rf "$f" ; done

mkdir $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k
cd $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k
#$OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input -b 18 *.mp3 m.mp3
for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/srv/lame/bin/lame --mp3input --abr 18 -b 18 -F -V 9.999  "$f" $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k/"$f" && rm -rf "$f" ; done
#for f in *.mp3 ; do $OPENSHIFT_REPO_DIR/srv/SoX/bin/sox  -C 16.01 "$f" $OPENSHIFT_REPO_DIR/srv/icecast/music/"$f" ; done
#rm -rf $OPENSHIFT_REPO_DIR/srv/icecast/music/album/*
du -h $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k
#$OPENSHIFT_REPO_DIR/srv/SoX/bin/sox m.mp3  -C 16.01 m_18kbps.mp3
#sox razhavaniazha_morning_18kbps.mp3  -C 16.01 razhavaniazha_morning_18kbps.mp3
ls
#unrar x filename.rar
rm -rf $OPENSHIFT_REPO_DIR/srv/icecast/playlist2.m3u
find $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k/ -name "*.mp3" >> $OPENSHIFT_REPO_DIR/srv/icecast/playlist2.m3u
find $OPENSHIFT_REPO_DIR/srv/icecast/music/new_18k_en/ -name "*.mp3" >> $OPENSHIFT_REPO_DIR/srv/icecast/playlist2.m3u

find $OPENSHIFT_REPO_DIR/srv/icecast/music/album -name "*.ogg" >> $OPENSHIFT_REPO_DIR/srv/ices/playlist1.txt
#find /music/artist/album/hel/ -name "*.mp3" > /usr/local/etc/playlist2.m3u


#nmap -v -sn 192.168.1.100

#iptables -A INPUT -i eth0 -p tcp --dport 8000 -j ACCEPT

kill -9 `lsof -t -i :8080`
kill -9 `lsof -t -i :80`
kill -9 `lsof -t -i :15001`
kill -9 `lsof -t -i :15002`
nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf" > ${OPENSHIFT_LOG_DIR}/server-template.log 2>&1 &

nohup sh -c "$OPENSHIFT_REPO_DIR/srv/icecast/bin/icecast -c $OPENSHIFT_REPO_DIR/srv/icecast/etc/icecast.xml -b  "    >  $OPENSHIFT_LOG_DIR/iccast_run.log 2>&1 &

#/opt/icecast/latest/bin/icecast -c /opt/icecast/latest/etc/icecast.xml -b -f /usr/local/etc/icegen1.cfg
#/opt/icecast/latest/bin/icecast -c "export LD_LIBRARY_PATH=/opt/icecast/latest/lib:$LD_LIBRARY_PATH; /usr/local/bin/icegenerator -f /usr/local/etc/icegen1.cfg"
#$OPENSHIFT_REPO_DIR/srv/icecast/bin/icecast -c "export LD_LIBRARY_PATH=$OPENSHIFT_REPO_DIR/srv/libshout/lib/:$LD_LIBRARY_PATH; $OPENSHIFT_REPO_DIR/srv/icegenerator/bin/icegenerator -f $OPENSHIFT_REPO_DIR/srv/icecast/etc/icegen1.cfg"
export LD_LIBRARY_PATH=$OPENSHIFT_REPO_DIR/srv/libshout/lib/:$LD_LIBRARY_PATH;

rm -rf  $OPENSHIFT_REPO_DIR/srv/icecast/var/log/icecast/icegen1.log
nohup sh -c "$OPENSHIFT_REPO_DIR/srv/icegenerator/bin/icegenerator -f $OPENSHIFT_REPO_DIR/srv/icegenerator/icegen1.cfg   "    >  $OPENSHIFT_LOG_DIR/icegenerator_run1.log 2>&1 &
nohup sh -c "$OPENSHIFT_REPO_DIR/srv/icegenerator/bin/icegenerator -f $OPENSHIFT_REPO_DIR/srv/icecast/etc/icegen1.cfg "    >  $OPENSHIFT_LOG_DIR/icegenerator_run1.log 2>&1 &
cat $OPENSHIFT_REPO_DIR/srv/icecast/var/log/icecast/icegen1.log

exec f<>/dev/tcp/${OPENSHIFT_DIY_IP}/8080
echo -e "GET / HTTP/1.0\n" >&f
cat <&f

 
 mkdir $OPENSHIFT_REPO_DIR/srv/libmnl
cd /tmp
#git clone git://git.savannah.gnu.org/libtool.git && cd libtool
wget http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
tar -xzvf libtool-2.4.6.tar.gz && cd libtool-2.4.6

./configure --prefix=$OPENSHIFT_REPO_DIR/srv/libtool 
 make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/libtool/bin:$PATH

mkdir $OPENSHIFT_REPO_DIR/srv/libmnl
cd /tmp && rm -rf *
#git clone https://github.com/threatstack/libmnl && cd libmnl
wget ftp://ftp.netfilter.org/pub/libmnl/libmnl-1.0.3.tar.bz2
tar jxf libmnl-1.0.3.tar.bz2 && cd libmnl-1.0.3
#./autogen.sh
#aclocal && autoheader && automake && autoconf && autoreconf -i
#autoreconf --install
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/libmnl 
 make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/libmnl/bin:$PATH


mkdir $OPENSHIFT_REPO_DIR/srv/bison
cd /tmp && rm -rf *
wget http://ftp.gnu.org/gnu/bison/bison-2.3.tar.gz
tar -xzvf  bison-2.3.tar.gz && cd bison-2.3
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/bison 
make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/bison/bin:$PATH

mkdir $OPENSHIFT_REPO_DIR/srv/flex
cd /tmp && rm -rf *
wget https://sourceforge.net/projects/flex/files/flex-2.6.0.tar.gz
tar -xzvf  flex-2.6.0.tar.gz && cd flex-2.6.0
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/flex 
make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/flex/bin:$PATH


mkdir $OPENSHIFT_REPO_DIR/srv/autoconf
cd /tmp && rm -rf *
wget http://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
tar -xzvf  autoconf-latest.tar.gz && cd autoconf-*
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/autoconf 
make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/autoconf/bin:$PATH


mkdir $OPENSHIFT_REPO_DIR/srv/automake
cd /tmp && rm -rf *
wget http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
tar -xzvf  automake-1.15.tar.gz && cd automake-1.15
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/automake 
make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/automake/bin:$PATH


mkdir $OPENSHIFT_REPO_DIR/srv/libnfnetlink
cd /tmp && rm -rf *
wget ftp://ftp.netfilter.org/pub/libnfnetlink/libnfnetlink-1.0.1.tar.bz2
tar jxf libnfnetlink-1.0.1.tar.bz2 && cd libnfnetlink-1.0.1
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/libnfnetlink 
make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/libnfnetlink/:$PATH
export PATH=$OPENSHIFT_REPO_DIR/srv/libnfnetlink/include/libnfnetlink/:$PATH
export PATH=$OPENSHIFT_REPO_DIR/srv/libnfnetlink/lib/:$PATH
export PATH=$OPENSHIFT_REPO_DIR/srv/libnfnetlink/lib/pkgconfig:$PATH
echo LIBNFNETLINK=$OPENSHIFT_REPO_DIR/srv/libnfnetlink/

mkdir $OPENSHIFT_REPO_DIR/srv/libnetfilter_conntrack
cd /tmp && rm -rf *
wget ftp://ftp.netfilter.org/pub/libnetfilter_conntrack/libnetfilter_conntrack-1.0.0.tar.bz2
tar jxf libnetfilter_conntrack-*.*.*.tar.bz2 && cd libnetfilter_conntrack-*.*.*
aclocal && autoheader && automake && autoconf && autoreconf -i
autoreconf --install
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/libnetfilter_conntrack \
 -with-libnetfilter_queue-includes=$OPENSHIFT_REPO_DIR/srv/libnfnetlink/include/ \
 --includedir=$OPENSHIFT_REPO_DIR/srv/libnfnetlink/include/
make
make install
export PATH=$OPENSHIFT_REPO_DIR/srv/libnetfilter_conntrack/bin:$PATH


mkdir $OPENSHIFT_REPO_DIR/srv/iptables
cd /tmp && rm -rf *
wget ftp://ftp.netfilter.org/pub/iptables/iptables-1.6.0.tar.bz2
tar jxf iptables-1.6.0.tar.bz2 && cd iptables-1.6.0
./configure --prefix=$OPENSHIFT_REPO_DIR/srv/iptables --enable-devel --enable-libipq
make
make install


#telnet  icecast3-icecast.rhcloud.com 8080 
#telnet  ${OPENSHIFT_DIY_IP} 8080
#pgrep -fl icecast
#pgrep -fl icegen
#lsof -t -i  :8080
#rebooting the system

# cd /tmp
 # nano install.sh
 # chmod 755 install.sh

 #nohup sh -c "./install.sh "    >  $OPENSHIFT_LOG_DIR/install.log 2>&1 &
#tail -f  $OPENSHIFT_LOG_DIR/install.log