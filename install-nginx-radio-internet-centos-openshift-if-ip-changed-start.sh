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
 
 