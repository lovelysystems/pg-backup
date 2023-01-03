FROM python:3.11.1-alpine3.17

ENV OFELIA_VERSION=v0.2.2
RUN set -ex \
		\
    # Install ofelia
    && apk add --no-cache libc6-compat libffi-dev \
		&& wget https://github.com/mcuadros/ofelia/releases/download/${OFELIA_VERSION}/ofelia_${OFELIA_VERSION}_linux_amd64.tar.gz \
		&& tar -xf ofelia_${OFELIA_VERSION}_linux_amd64.tar.gz \
		&& rm -rf /ofelia_${OFELIA_VERSION}_linux_amd64.tar.gz \
		\
    # Install wal-e
    && apk add --no-cache pv lzo postgresql-client build-base \
    && pip install wal-e[aws] boto3 slack_sdk \
    && apk del build-base

COPY ./scripts /usr/local/bin/

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
