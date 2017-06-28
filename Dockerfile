FROM alpine
MAINTAINER garrett@garrettboast.com
ENV FCGI_HOST="127.0.0.1:9000"
ENV WEBROOT=/var/www/html
EXPOSE 80

RUN  apk add --no-cache  \
	apache2-proxy \
	&& rm -rf /var/cache/apk/*

COPY entrypoint.sh /bin/entrypoint.sh

RUN	sed -i -e 's/^\(LoadModule mpm_prefork_module\)/#\1/g' /etc/apache2/httpd.conf && \
	sed -i -e 's/^#\(LoadModule mpm_event_module\)/\1/g' /etc/apache2/httpd.conf && \
#	echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/apache2/httpd.conf && \
#	echo "LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" >> /etc/apache2/httpd.conf && \
	echo "DirectoryIndex /index.php index.php" >> /etc/apache2/httpd.conf && \
	echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://\${FCGI_HOST}/\${WEBROOT}/\$1" >> /etc/apache2/httpd.conf && \
	echo "LoadModule slotmem_shm_module modules/mod_slotmem_shm.so" >> /etc/apache2/conf.d/slotmem_shm.conf && \
	mkdir -p /run/apache2/ && \
	chmod a+x /bin/entrypoint.sh && \
	ln -s /bin/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["httpd"]
