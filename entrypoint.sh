#!/bin/ash

# The following environment variables are relevant:
# - ALLOW_PLAY=0|1	: Allow the Minio Play server to be registered by default
# - SOURCE_BUCKET	: Minio bucket/path containing the source code
# - SOURCE_FILE=""	: OPTIONAL - if specified, instead of performing a recursive copy of the bucket contents,
#                                this file will be downloaded and then extracted into the target path
# - SOURCE_ROOT=	: Path to place the contents of the bucket
# TODO: move this into its own subcontainer to not contaminate our apache image...
if [ ! -z "$GET_SRC" ] ; then
    ALLOW_PLAY=${ALLOW_PLAY:-0}
	MINIO_HOST=${MINIO_HOST:-"https://play.minio.io:9000/"}

	SECRET_PATH=/run/secrets
	ACCESS_KEY_PATH="$SECRET_PATH/access_key"
	SECRET_KEY_PATH="$SECRET_PATH/secret_key"
	if [ -e "$ACCESS_KEY_PATH" ] ; then
		ACCESS_KEY=`cat $ACCESS_KEY_PATH`
	else if [ -z "$ACCESS_KEY" -a "$ALLOW_PLAY" = "0" ] ; then echo "access_key docker secret does not exist" ; exit 1 ; fi
	fi

	if [ -e "$SECRET_KEY_PATH" ] ; then
		SECRET_KEY=`cat $SECRET_KEY_PATH`
	else if [ -z "$SECRET_KEY" -a "$ALLOW_PLAY" = "0" ] ; then echo "secret_key docker secret does not exist" ; exit 1 ; fi
	fi

	# Minio Play mode
	if [ "$ALLOW_PLAY" != "0" ] ; then ACCESS_KEY=${ACCESS_KEY:-"Q3AM3UQ867SPQQA43P2F"} ; fi
	if [ "$ALLOW_PLAY" != "0" ] ; then SECRET_KEY=${SECRET_KEY:-"zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG"} ; fi

	SOURCE_BUCKET=${SOURCE_BUCKET:-"my-test-bucket/src"}
	SOURCE_ROOT=${SOURCE_ROOT:-/var/www/localhost/htdocs}
	
	mc config host a src "$MINIO_HOST" "$ACCESS_KEY" "$SECRET_KEY"
	rm -rf "$SOURCE_ROOT"
	if [ ! -z "$SOURCE_FILE" ] ; then
	    SRCTMP=$( tempfile )
		mc cp "src/$SOURCE_BUCKET/$SOURCE_FILE" /tmp/
		tar -C"$SOURCE_ROOT" xfz "/tmp/$SOURCE_FILE"
	else
	    mc cp --recursive "src/$SOURCE_BUCKET/$SOURCE_PATH" "$SOURCE_ROOT"
    fi
fi

httpd

tail -f /var/log/apache2/*.log