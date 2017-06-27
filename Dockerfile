FROM alpine
MAINTAINER garrett@garrettboast.com
ENV FCGI_HOST="127.0.0.1:9000"
ENV WEBROOT=/var/www/html

RUN  apk add --no-cache  \
	apache2-proxy \
	&& rm -rf /var/cache/apk/*

RUN	sed -i -e 's/^\(LoadModule mpm_prefork_module\)/#\1/g' /etc/apache2/httpd.conf ; \
	sed -i -e 's/^#\(LoadModule mpm_event_module\)/\1/g' /etc/apache2/httpd.conf ; \
	echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/apache2/httpd.conf ; \
	echo "LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" >> /etc/apache2/httpd.conf ; \
	echo "DirectoryIndex /index.php index.php" >> /etc/apache2/httpd.conf ; \
	echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://${FCGI_HOST}/${WEBROOT}/$1" >> /etc/apache2/httpd.conf
	

	
EXPOSE 80
CMD ["ash"]
