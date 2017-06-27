FROM alpine
MAINTAINER garrett@garrettboast.com

RUN  apk add --no-cache  \
	apache2-proxy

RUN	sed -i -e 's/^\(LoadModule mpm_prefork_module\)/#\1/g' /etc/apache2/httpd.conf ; \
	sed -i -e 's/^#\(LoadModule mpm_event_module\)/\1/g' /etc/apache2/httpd.conf

# VOLUME /data/db /data/configdb
# 
# COPY docker-entrypoint.sh /bin/
# 
# RUN ln -s /bin/docker-entrypoint.sh /entrypoint.sh ; chmod a+x /bin/docker-entrypoint.sh ; mkdir /docker-entrypoint-initdb.d /docker-entrypoint-post-setup.d
# 
# COPY initdb.d/* /docker-entrypoint-initdb.d/
# COPY post-setup.d/* /docker-entrypoint-post-setup.d/

EXPOSE 80
CMD ["ash"]
