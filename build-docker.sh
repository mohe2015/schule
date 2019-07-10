docker build -t devmohe/debian-roswell .
docker login && docker push devmohe/debian-roswell
docker run -it --rm devmohe/debian-roswell
