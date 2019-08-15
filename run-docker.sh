docker run -it -w /root/projects -v common-lisp-cache:/root/.cache/common-lisp/ -v quicklisp-cache:/root/.roswell/lisp/quicklisp/dists/ -v projects-cache:/root/projects devmohe/debian-roswell

mkdir /root/projects
cd /root/projects
git clone --recursive https://github.com/mohe2015/wiki.git
cd wiki
./setup.sh

cd rust-web-push
./setup.sh
cd ..

export LD_LIBRARY_PATH=/usr/lib
ros run
(ql:quickload :spickipedia)





git config --global user.email "mohe2015@users.noreply.github.com"
git config --global user.name mohe2015


sendfile on;
tcp_nopush on;

keepalive_timeout 65;

gzip on;
gzip_types *;
gzip_comp_level 9;

server {
  listen 8443 ssl http2;
  server_name localhost;
  ssl_certificate /etc/ssl/certs/localhost.pem;
  ssl_certificate_key /etc/ssl/private/localhost-key.pem;
  
  location / {
    fastcgi_intercept_errors on;
    fastcgi_pass 127.0.0.1:5000;
    include fastcgi_params;
  }
}
