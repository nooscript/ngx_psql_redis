FROM alpine:3.4

MAINTAINER NGINX Docker Maintainer "docker-maint@nginx.com"
MAINTAINER NGINX noscript "mygthub@gmail.com"

ENV NGINX_VERSION 1.9.15

ENV GPG_KEYS B0F4253373F8F6F510D42178520A9993A1C052F8
ENV CONFIG "\
	--prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--modules-path=/usr/lib/nginx/modules \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--user=nginx \
	--group=nginx \
        --add-module=/usr/src/ngx_postgres \
        --add-module=/usr/src/ngx_devel_kit \
        --add-module=/usr/src/form-input-nginx-module \
        --add-module=/usr/src/rds-json-nginx-module \
	--add-module=/usr/src/ngx_redislog_module \
	--add-dynamic-module=/usr/src/echo-nginx-module \
        --add-dynamic-module=/usr/src/redis2-nginx-module \
        --add-dynamic-module=/usr/src/srcache-nginx-module \
	--add-dynamic-module=/usr/src/ngx_http_redis \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-http_xslt_module=dynamic \
	--with-http_image_filter_module=dynamic \
	--with-http_geoip_module=dynamic \
	--with-http_perl_module=dynamic \
	--with-threads \
	--with-stream \
	--with-stream_ssl_module \
	--with-http_slice_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-http_v2_module \
	--with-ipv6 \
	"

RUN \
	addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& apk add --no-cache --virtual .build-deps \
		postgresql-dev \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev \
		perl-dev \
	&& curl -fSL http://people.freebsd.org/~osa/ngx_http_redis-0.3.8.tar.gz -o ngx_http_redis.tar.gz \
	&& curl -fSL https://github.com/openresty/redis2-nginx-module/archive/v0.13.tar.gz -o redis2-nginx-module.tar.gz \
	&& curl -fSL https://github.com/openresty/echo-nginx-module/archive/v0.59.tar.gz -o echo-nginx-module.tar.gz \
	&& curl -fSL https://github.com/openresty/srcache-nginx-module/archive/v0.31.tar.gz -o srcache-nginx-module.tar.gz \
	&& curl -fSL https://github.com/FRiCKLE/ngx_postgres/archive/1.0rc7.tar.gz -o ngx_postgres.tar.gz \
	&& curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz -o ngx_devel_kit.tar.gz \
	&& curl -fSL https://github.com/calio/form-input-nginx-module/archive/v0.12.tar.gz -o form-input-nginx-module.tar.gz \
	&& curl -fSL https://github.com/openresty/rds-json-nginx-module/archive/v0.14.tar.gz -o rds-json-nginx-module.tar.gz \
	&& curl -fSL https://github.com/nooscript/ngx_psql_redis/raw/master/ngx_redislog.tar.gz -o ngx_redislog.tar.gz \
	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
	&& gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& rm -r "$GNUPGHOME" nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f ngx_redislog.tar.gz \
	&& tar -zxC /usr/src -f ngx_http_redis.tar.gz \
	&& mv /usr/src/ngx_http_redis* /usr/src/ngx_http_redis \
	&& tar -zxC /usr/src -f redis2-nginx-module.tar.gz \
	&& mv /usr/src/redis2-nginx-module* /usr/src/redis2-nginx-module \
	&& tar -zxC /usr/src -f echo-nginx-module.tar.gz \
	&& mv /usr/src/echo-nginx-module* /usr/src/echo-nginx-module \
	&& tar -zxC /usr/src -f srcache-nginx-module.tar.gz \
	&& mv /usr/src/srcache-nginx-module* /usr/src/srcache-nginx-module \
	&& tar -zxC /usr/src -f ngx_postgres.tar.gz \
	&& mv /usr/src/ngx_postgres* /usr/src/ngx_postgres \
	&& tar -zxC /usr/src -f ngx_devel_kit.tar.gz \
	&& mv /usr/src/ngx_devel_kit* /usr/src/ngx_devel_kit \
	&& tar -zxC /usr/src -f form-input-nginx-module.tar.gz \
	&& mv /usr/src/form-input-nginx-module* /usr/src/form-input-nginx-module \
	&& tar -zxC /usr/src -f rds-json-nginx-module.tar.gz \
	&& mv /usr/src/rds-json-nginx-module* /usr/src/rds-json-nginx-module \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& rm ngx_redislog.tar.gz \
	&& rm ngx_http_redis.tar.gz \
	&& rm redis2-nginx-module.tar.gz \
	&& rm echo-nginx-module.tar.gz \
	&& rm srcache-nginx-module.tar.gz \
	&& rm ngx_postgres.tar.gz \
	&& rm ngx_devel_kit.tar.gz \
	&& rm form-input-nginx-module.tar.gz \
	&& rm rds-json-nginx-module.tar.gz \
	&& rm nginx.tar.gz \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make \
	&& mv objs/nginx objs/nginx-debug \
	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
	&& mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so \
	&& mv objs/ngx_http_echo_module.so objs/ngx_http_echo_module-debug.so \
	&& mv objs/ngx_http_redis2_module.so objs/ngx_http_redis2_module-debug.so \
	&& mv objs/ngx_http_redis_module.so objs/ngx_http_redis_module-debug.so \
	&& mv objs/ngx_http_srcache_filter_module.so objs/ngx_http_srcache_filter_module-debug.so \
	&& ./configure $CONFIG \
	&& make \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
	&& install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
	&& install -m755 objs/ngx_http_echo_module-debug.so /usr/lib/nginx/modules/ngx_http_echo_module-debug.so \
        && install -m755 objs/ngx_http_redis2_module-debug.so /usr/lib/nginx/modules/ngx_http_redis2_module-debug.so \
        && install -m755 objs/ngx_http_redis_module-debug.so /usr/lib/nginx/modules/ngx_http_redis_module-debug.so \
        && install -m755 objs/ngx_http_srcache_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_srcache_filter_module-debug.so \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& runDeps="$( \
		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& rm -rf /usr/src/* \
	&& apk add --no-cache gettext \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

#COPY nginx.conf /etc/nginx/nginx.conf
#COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
