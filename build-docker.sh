docker build -t devmohe/debian-roswell .
echo docker run -it --rm devmohe/debian-roswell
docker login && docker push devmohe/debian-roswell
