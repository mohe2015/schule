FROM ubuntu:devel
MAINTAINER Moritz Hedtke dev.mohe@github.com

RUN apt update
RUN apt install -y curl jq libcurl3-gnutls bzip2 make git gcc libxml2 libargon2-dev locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN curl -sOL `curl -s https://api.github.com/repos/roswell/roswell/releases/latest | jq -r '.assets | .[] | select(.name|test("deb$")) | .browser_download_url'`
RUN dpkg -i *.deb
RUN ros install sbcl-bin/1.5.4
RUN ros install prove
