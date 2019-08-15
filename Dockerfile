FROM frolvlad/alpine-glibc
MAINTAINER Moritz Hedtke dev.mohe@github.com

#RUN apk add --no-cache curl jq libcurl3-gnutls bzip2 make git gcc libxml2 libargon2-dev locales file golang libfcgi-dev libuv1-dev libssl-dev

#RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8

# based on https://github.com/wshito/roswell-base by W.Shito (@waterloo_jp) LICENSED UNDER MIT License https://github.com/wshito/roswell-base/blob/master/LICENSE

RUN mkdir /tmp/workdir && cd /tmp/workdir

RUN apk --no-cache --update add --virtual build-dependencies \
    build-base \
    curl-dev \
    git \
    automake \
    autoconf

RUN apk --no-cache --update add libcurl git nano gcc libxml2-dev libc-dev cargo openssl-dev sudo argon2-dev libev-dev nginx fcgi-dev

RUN git clone -b release https://github.com/roswell/roswell.git \
    && cd roswell \
    && sh bootstrap \
    && ./configure \
    && make \
    && make install \
    && cd / && rm -rf /tmp/workdir \
    && ros setup

RUN apk del build-dependencies
