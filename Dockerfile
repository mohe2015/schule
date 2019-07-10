FROM debian:stretch
MAINTAINER Moritz Hedtke dev.mohe@github.com

RUN apt update
RUN apt install -y curl jq libcurl3-gnutls bzip2 make git
RUN curl -sOL `curl -s https://api.github.com/repos/roswell/roswell/releases/latest | jq -r '.assets | .[] | select(.name|test("deb$")) | .browser_download_url'`
RUN dpkg -i *.deb
RUN ros install sbcl-bin/1.5.4
RUN ros install prove
