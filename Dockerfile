FROM alpine

LABEL maintainer="akshmakov@gmail.com"

RUN apk update && apk add socat

COPY serialport-server.sh /usr/local/bin/serialport-server

EXPOSE 2000

ENTRYPOINT [ "serialport-server" ]
