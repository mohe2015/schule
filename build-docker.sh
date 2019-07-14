docker build -t devmohe/debian-roswell .
docker login && docker push devmohe/debian-roswell
./run-docker.sh
