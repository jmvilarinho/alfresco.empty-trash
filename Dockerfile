#
# Base para Alfresco check
#
#
FROM ubuntu:18.04
MAINTAINER Jose Manuel Vilarino jmvilarinho@gmail.com


ENV DEBIAN_FRONTEND=noninteractive
RUN apt update &&\
  apt install -y make libxml-simple-perl libnet-ssleay-perl libssl-dev libjson-perl libcrypt-ssleay-perl gcc &&\
  rm -rf /var/lib/apt/lists/*  

ENV PERL_MM_USE_DEFAULT=1 
RUN cpan install Time::HiRes
RUN cpan install Color::Output &&\
   cpan install LWP::UserAgent HTTP::Request::Common HTTP::Request::StreamingUpload LWP::Protocol::https &&\
   cpan install Net::SSL

COPY check /opt/check

RUN chmod 644 /opt/check/* && chmod 755 /opt/check/*.sh

WORKDIR /opt/check

CMD exec /bin/sh -c "trap : TERM INT; while [ 1 ]; do sleep 15; done & wait"

