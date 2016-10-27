
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
error_log {{OPENSHIFT_HOMEDIR}}/app-root/logs/nginx_error.log debug;

pid        {{NGINX_DIR}}/logs/nginx.pid;


events {
    worker_connections  5024;
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
    keepalive_timeout  465;
	proxy_connect_timeout 1s;
	
    gzip  on;
	gzip_min_length 1000;
	gzip_proxied expired no-cache no-store private auth;
	gzip_types text/plain application/xml application/javascript text/javascript text/css;
	gzip_disable "msie6";
	gzip_http_version 1.1;
	
	upstream frontends {
        #server pr4ss.tk;
        #server 222.66.115.233:80 weight=1;
		server {{OPENSHIFT_INTERNAL_IP}}:8081 ;
		
    }
	upstream frontends2 {
        server google.com;
        #server 222.66.115.233:80 weight=1;
		#server {{OPENSHIFT_INTERNAL_IP}}:8081 ;
		
    }
	upstream index0 {
        
		server {{OPENSHIFT_INTERNAL_IP}}:15001 weight=1;
		server {{OPENSHIFT_INTERNAL_IP}}:15002 weight=2;
		server {{OPENSHIFT_INTERNAL_IP}}:15003 weight=3;
		
    }
	upstream index {
		#server varkets.rhcloud.com;
		#server vb.lasa.ir;
		#server  vb-lasa3.rhcloud.com ;
		#server varkets.rhcloud.com;
		#server forums.fishsmarket.tk;
		#server  community.lasa.ir;
		#server free-papers.lasa.ir;
		#server  varkets2.rhcloud.com weight=1;
		server varkets3.rhcloud.com  ;#fail_timeout=3 ;
		server diy2-lasa2.rhcloud.com backup;
	}
	
	map_hash_bucket_size 128;
	map $http_host $served_host2 {
    #default $http_host;
	default varkets3.rhcloud.com;
    diy2-lasa2.rhcloud.com varkets3.rhcloud.com;
	}
	
	upstream main {
	fair;
	server {{OPENSHIFT_INTERNAL_IP}}:15010 weight=1 fail_timeout=1s; #varkets3.rhcloud.com
	#server {{OPENSHIFT_INTERNAL_IP}}:15011 weight=1 fail_timeout=1s; #diy2-lasa2.rhcloud.com
	server {{OPENSHIFT_INTERNAL_IP}}:15012 weight=1 fail_timeout=1s; #varkets4.rhcloud.com
	#server {{OPENSHIFT_INTERNAL_IP}}:15013 weight=1 fail_timeout=1s;
	#max_connections 3;
	keepalive 2100;

	}
	#match welcome {
    #     status 200;
    #    #header Content-Type = text/html;
    #    #body ~ "Welcome to nginx!";
    #}
	
	limit_req_zone $binary_remote_addr zone=one:10m rate=30r/m;
	limit_req_zone $binary_remote_addr zone=one2:10m rate=1r/m;
	limit_req_zone $http_x_forwarded_for zone=one3:10m rate=1r/m;
	proxy_cache_path  /tmp  levels=1:2    keys_zone=RUBYGEMS:10m  inactive=24h  max_size=100m;
	
	server {
  listen      {{OPENSHIFT_INTERNAL_IP}}:15010;
  server_name varkets3.rhcloud.com;
  location ~* ^/(.*) {
  if ($status != "503") {
		proxy_pass       http://varkets3.rhcloud.com;
		
		}
  #if ($status = "500") {
	#		proxy_pass       http://main;
	#		}
  if ($status = "503") {
			proxy_pass       http://main;
		}
  
		
    
    #proxy_pass       http://varkets3.rhcloud.com;
    proxy_set_header Host varkets3.rhcloud.com;
	proxy_cache RUBYGEMS;
      proxy_cache_valid 200 302 365d;
      proxy_cache_valid 404 1m;
	}
	}
	
	server {
  listen      {{OPENSHIFT_INTERNAL_IP}}:15011;
  server_name diy2-lasa2.rhcloud.com;
  location ~* ^/(.*) {
  if ($status != "503") {
		proxy_pass       http://diy2-lasa2.rhcloud.com;
		
		}
  #if ($status = "500") {
	#		proxy_pass       http://main;
	#		}
  if ($status = "503") {
			proxy_pass       http://main;
		}
    
    proxy_set_header Host diy2-lasa2.rhcloud.com;
	proxy_cache RUBYGEMS;
      proxy_cache_valid 200 302 365d;
      proxy_cache_valid 404 1m;
	}
	}
	server {
  listen      {{OPENSHIFT_INTERNAL_IP}}:15012;
  server_name varkets4.rhcloud.com;
  location ~* ^/(.*) {
	if ($status != "503") {
		proxy_pass       http://varkets4.rhcloud.com;
		
		}
	#if ($status = "500") {
	#		proxy_pass       http://main;
	#		}
  if ($status = "503") {
			proxy_pass       http://main;
		}
		
		
    proxy_set_header Host varkets4.rhcloud.com;
	proxy_cache RUBYGEMS;
      proxy_cache_valid 200 302 365d;
      proxy_cache_valid 404 1m;
	}
	}
	
	
    server {
        listen      {{OPENSHIFT_INTERNAL_IP}}:{{OPENSHIFT_INTERNAL_PORT}};
        server_name  {{OPENSHIFT_GEAR_DNS}} www.{{OPENSHIFT_GEAR_DNS}};
		root {{OPENSHIFT_REPO_DIR}};


		set_real_ip_from {{OPENSHIFT_INTERNAL_IP}};
		real_ip_header X-Forwarded-For;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location /main0 {
            root   {{OPENSHIFT_REPO_DIR}};
            index  index.html index.htm;
			try_files $uri $uri/ =404;
			
			autoindex on;
			autoindex_exact_size off;
			autoindex_localtime on;
            
            #proxy_set_header Authorization base64_encoding_of_"user:password";
			#proxy_pass_header Server;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_set_header  X-Real-IP  $remote_addr;
            proxy_set_header X-Scheme $scheme;

        }
		location  ~* ^/(.*) {
		 proxy_pass http://main;
		 #proxy_read_timeout 5s;
		 proxy_connect_timeout 1s;
		 access_log off;
		 proxy_cache RUBYGEMS;
		 proxy_cache_valid 200 302 365d;
		 proxy_cache_valid 404 1m;
		 #health_check match=welcome;
		 
		}
		#location  ~* ^/(.*) {
		location afffter {
		 proxy_pass_header on;
      proxy_set_header Host $served_host2;
      proxy_pass http://index/$1$is_args$args;
      proxy_cache RUBYGEMS;
      proxy_cache_valid 200 302 365d;
      proxy_cache_valid 404 1m;
      #sub_filter 'elec-lab.tk' 'varkets2.rhcloud.com';
      sub_filter_once off;
      #sub_filter_types application/json;
		}
		
		#location ~* ^/(.*) {
		location beffor {
            #root   html;
            #index  index.html index.htm;
			proxy_set_header Host  $served_host2;
			#proxy_set_header Host  $upstream_addr;
			proxy_pass_header Server;
            #proxy_set_header Host $proxy_host;
			#proxy_redirect  http://varkets.rhcloud.com/ http://community.lasa.ir/;
			#proxy_redirect  http://fm.lasa.ir/ http://community.lasa.ir/;
			proxy_pass http://index/$1$is_args$args;
			proxy_set_header  X-Real-IP  $remote_addr;
            #proxy_set_header X-Scheme $scheme;
			#sub_filter 'href="http://fm.lasa.ir/'  'href="http://community.lasa.ir/';
			#sub_filter '<base href="http://fm.lasa.ir/'   '<base href="http://community.lasa.ir/';
			sub_filter 'http://fm.lasa.ir/'   'http://community.lasa.ir/';
			sub_filter_once on;
			
		proxy_set_header X-outside-url $scheme://$host;
            		#proxy_set_header  X-Real-IP $remote_addr;
			
			
			
			
			
		proxy_cache            RUBYGEMS;
		proxy_cache_valid      200  1d;
		proxy_cache_use_stale  error timeout invalid_header updating
                               http_500 http_502 http_503 http_504;
							   
		proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection 'upgrade';
         
          proxy_cache_bypass $http_upgrade;

			
			proxy_set_header X-NginX-Proxy true;
			proxy_redirect off;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			
			
			client_max_body_size 100M;
			client_body_buffer_size 1m;
			proxy_intercept_errors on;
			proxy_buffering on;
			proxy_buffer_size 128k;
			proxy_buffers 256 16k;
			proxy_busy_buffers_size 256k;
			proxy_temp_file_write_size 256k;
			#proxy_max_temp_file_size 0;
			proxy_read_timeout 300;
        }

		location ^~ /admincp {
                if (!-f $request_filename) {
                        rewrite ^/admincp/(.*)$ /index.php?routestring=admincp/$1 last;
                }
				proxy_set_header Host varkets.rhcloud.com;
			proxy_redirect  http://varkets.rhcloud.com/ http://diy-lasa2.rhcloud.com/;
			proxy_pass http://comment/$1$is_args$args;
        }
		location /www {
            #root   {{OPENSHIFT_REPO_DIR}};
            index  index.html index.htm;
			
			autoindex on;
			autoindex_exact_size off;
			autoindex_localtime on;
            
            #proxy_set_header Authorization base64_encoding_of_"user:password";
			#proxy_pass_header Server;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_set_header  X-Real-IP  $remote_addr;
            proxy_set_header X-Scheme $scheme;
            proxy_pass http://frontends;
        }
		location /categories {
            #root   {{OPENSHIFT_REPO_DIR}};
            index  index.html index.htm;
			
			autoindex on;
			autoindex_exact_size off;
			autoindex_localtime on;
            
            #proxy_set_header Authorization base64_encoding_of_"user:password";
			#proxy_pass_header Server;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_set_header  X-Real-IP  $remote_addr;
            proxy_set_header X-Scheme $scheme;
            proxy_pass http://frontends2;
        }
		location /index0 {
            #root   {{OPENSHIFT_REPO_DIR}};
            index  index.html index.htm;
			
			autoindex on;
			autoindex_exact_size off;
			autoindex_localtime on;
			# an HTTP header important enough to have its own Wikipedia entry:
			#   http://en.wikipedia.org/wiki/X-Forwarded-For
			proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   Host             $host;
            proxy_set_header   X-Real-IP        $remote_addr;

	
			# enable this if you forward HTTPS traffic to unicorn,
			# this helps Rack set the proper URL scheme for doing redirects:
			# proxy_set_header X-Forwarded-Proto $scheme;
	
			# pass the Host: header from the client right along so redirects
			# can be set properly within the Rack application
			proxy_set_header Host $http_host;

			# we don't want nginx trying to do something clever with
			# redirects, we set the Host: header above already.
			proxy_redirect off;
	
			# set "proxy_buffering off" *only* for Rainbows! when doing
			# Comet/long-poll/streaming.  It's also safe to set if you're using
			# only serving fast clients with Unicorn + nginx, but not slow
			# clients.  You normally want nginx to buffer responses to slow
			# clients, even with Rails 3.1 streaming because otherwise a slow
			# client can become a bottleneck of Unicorn.
			#
			# The Rack application may also set "X-Accel-Buffering (yes|no)"
			# in the response headers do disable/enable buffering on a
			# per-response basis.
			# proxy_buffering off;
	
			
		



            client_max_body_size       10m;
            client_body_buffer_size    128k;

            proxy_connect_timeout      10;
            proxy_send_timeout         5;
            proxy_read_timeout         3600;

            proxy_buffer_size          4k;
            proxy_buffers              4 132k;
            proxy_busy_buffers_size    264k;
            proxy_temp_file_write_size 164k;
			proxy_pass http://index;			

            
            #proxy_set_header Authorization base64_encoding_of_"user:password";
			#proxy_pass_header Server;
            proxy_set_header Host $http_host;
        }
		
		

        
		location ~ \.php$ {

        if (!-f $request_filename) {
        rewrite ^/(.*)$ /index.php?routestring=$1 break;
        }
    
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass   {{OPENSHIFT_INTERNAL_IP}}:9000;
		#fastcgi_pass   unix:/tmp/php5-fpm.sock;
		fastcgi_index  index.php;
		#fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
		fastcgi_param  SCRIPT_FILENAME    $request_filename;

		fastcgi_connect_timeout 60;
		fastcgi_send_timeout 180;
		fastcgi_read_timeout 180;
		fastcgi_buffer_size 256k;
		fastcgi_buffers 4 256k;
		fastcgi_busy_buffers_size 256k;
		fastcgi_temp_file_write_size 256k;
		fastcgi_intercept_errors on;
		#fastcgi_param HTTPS on;
		
		fastcgi_param  PATH_INFO          $fastcgi_path_info;
		fastcgi_param  PATH_TRANSLATED    $document_root$fastcgi_path_info;
		
		fastcgi_param  QUERY_STRING       $query_string;
		fastcgi_param  REQUEST_METHOD     $request_method;
		fastcgi_param  CONTENT_TYPE       $content_type;
		fastcgi_param  CONTENT_LENGTH     $content_length;
		
		fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
		fastcgi_param  REQUEST_URI        $request_uri;
		fastcgi_param  DOCUMENT_URI       $document_uri;
		fastcgi_param  DOCUMENT_ROOT      $document_root;
		fastcgi_param  SERVER_PROTOCOL    $server_protocol;
		
		fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
		#fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;
		
		fastcgi_param  REMOTE_ADDR        $remote_addr;
		fastcgi_param  REMOTE_PORT        $remote_port;
		fastcgi_param  SERVER_ADDR        $server_addr;
		fastcgi_param  SERVER_PORT        $server_port;
		fastcgi_param  SERVER_NAME        $server_name;
		
		# PHP only, required if PHP was built with --enable-force-cgi-redirect
		fastcgi_param  REDIRECT_STATUS    200;
		
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
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}
		 location ~ \.php1$ {
                # handles legacy scripts
                if (!-f $request_filename) {
                        rewrite ^/(.*)$ /index.php?routestring=$1 break;
                }

                fastcgi_split_path_info ^(.+\.php)(.*)$;
                fastcgi_pass   {{OPENSHIFT_INTERNAL_IP}}:9000;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
                fastcgi_param QUERY_STRING $query_string;
                fastcgi_param REQUEST_METHOD $request_method;
                fastcgi_param CONTENT_TYPE $content_type;
                fastcgi_param CONTENT_LENGTH $content_length;
                fastcgi_intercept_errors on;
                fastcgi_ignore_client_abort off;
                fastcgi_connect_timeout 60;
                fastcgi_send_timeout 180;
                fastcgi_read_timeout 180;
                fastcgi_buffers 256 16k;
                fastcgi_buffer_size 32k;
                fastcgi_temp_file_write_size 256k;
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
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}

