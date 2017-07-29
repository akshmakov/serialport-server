# serialport-server

Simple Utility to Expose a local serial port on a network port, allowing for remote serial port access

Published on Dockerhub @ https://dockerhub.com/akshmakov/serialport-server



## Requirements

 - `socat`


## Usage

Start a server simply by

```
$ ./rs232-server.sh /dev/ttyUSB0
```

Full Usage Information:

```
Usage: rs232-server [OPTIONS] device 

options: 
     -p/--port=<PORT>         : exposed TCP Port (default=2000)
     -b/--tty-br=<BAUDRATE>   : baud rate of underlying device (default=9600)
     -l/--logfile=<FNAME>     : save output to file
     -h/--help                : print this usage
     -d/--daemon              : daemonize (background) 
     -v/--verbose             : more (debug) 

device: local socket or device (e.g. /dev/ttyUSB0)
```

## Usage - Docker

Docker container is available under dockerhub `akshmakov/serialport-server:TAG`, list of tags

- **latest** **amd64**  container for standard x86_64 systems (alpine base)
- **arm32v7** armv7 systems (RPI 2/3)
- **arm32v6** armv6 systems (RPI 1 , comaptible with 2/3)

if you leave the tag off, the amd64 tag will be pulled 

To start a dockerized serial port server on host port '2000'

```
$ docker run -d -p "2000:2000" --device "/dev/ttyUSB0:/dev/ttyUSB0" akshmakov/serialport-server:latest /dev/ttyUSB0
# test your server
$ nc 127.0.0.1 2000
```

## Usage - docker-compose

Start two serialport-servers using either command or environment variables

```
version: '2'
services:
  tty1:
    image: akshmakov/serialport-server
    devices:
      - "/dev/ttyUSB0:/dev/ttyUSB0"
    command: -b 19200 /dev/ttyUSB0
    ports:
      - "2000"
  tty2:
    image: akshmakov/serialport-server
    devices:
      - "/dev/ttyUSB1:/dev/ttyUSB1"
    environment:
      BAUDRATE:19200
      DEVICE:/dev/ttyUSB1
```

## Client

Connect to a serialport server using a number of common terminals that accept a network socket.

Simplest use case is `netcat`, note that many terminal commands lik `C-c` will not work 

```
$ nc ip.of.serial.server 2000

```

using `socom` to provide a true tty (accepts ctrl-c

```
$ socom file:'tty',raw,echo=0 tcp:ip.op.serial.server:2000,raw,echo=0
```


using `picocom` or `minicom` pointing them at the port

