# nginxwebdemo

docker run -it -d -p 8380-8389:80 --name nginxwebdemo nginx:1.23.0
docker container ls | grep nginxwebdemo
curl http://localhost:8380

docker exec -it nginxwebdemo /bin/bash
apt update
apt install dnsutils inetutils-ping net-tools -y
apt install wget curl nano git -y
ifconfig
ping 8.8.8.8
cd /usr/share/nginx/html
cat index.html
exit

docker cp index.html nginxwebdemo:/usr/share/nginx/html/index.html
curl http://localhost:8380/


docker commit nginxwebdemo mkbahk/nginxwebdemo:0.1
docker commit nginxwebdemo mkbahk/nginxwebdemo:latest
docker push mkbahk/nginxwebdemo:0.1
docker push mkbahk/nginxwebdemo:latest

//dockerhub.com에서 확인

docker container stop nginxwebdemo
docker container rm nginxwebdemo
docker image rm mkbahk/nginxwebdemo:0.1
docker image rm mkbahk/nginxwebdemo:latest
docker image ls | grep mkbahk



//Dockerfile:image build자동화
cat Dockerfile
###
FROM nginx:1.23.0
MAINTAINER "Moon-Kee Bahk, mkbahk@gmail.com"
#
RUN apt update
RUN apt install dnsutils inetutils-ping net-tools -y
RUN apt install wget curl nano git -y
#
EXPOSE 80
#
COPY index.html /usr/share/nginx/html
#
CMD ["nginx", "-g", "daemon off;"]
####
#docker build . -t mkbahk/nginxwebdemo:0.1
#docker build . -t mkbahk/nginxwebdemo:latest
#docker run -it -d -p 8380-8389:80 -n nginxwebdemo nginxwebdemo:0.1 
#이경우 여러개 같은 명령어를 수행하면 8380-8389 중 하나를 선택하면

//빌드 후 수행 테스트
docker build . -t mkbahk/nginxwebdemo:0.1
docker build . -t mkbahk/nginxwebdemo:latest
docker run -it -d -p 8380-8389:80 --name nginxwebdemo mkbahk/nginxwebdemo:latest

//DOCKER-COMPOSE를 이용한 Service화(docker run -d 명령을 script화)

cat docker-compose.yaml
###
version : "3"
services:
   nginxwebdemo:
      image: "mkbahk/nginxwebdemo:latest"
      ports:
         - "8380-8389:80"
      networks:
         - nginx-net
networks:
   nginx-net:
###

docker-compose up -d --scale nginxwebdemo=10
docker-compose up --scale nginxwebdemo=5
docker-compose down

//docker-compose는 서비스화는 하지만, 관리는 하지 않는다. 그래서 docker stack+swarm

//docekr swarm 설치
docker swarm init --advertise-addr 218.145.56.75

root@pod641:~# docker swarm init --advertise-addr 218.145.56.75
Swarm initialized: current node (9eymmbwhxqvuvcf7tazfhqisd) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-40kcxme15zwvn0ktypbix1mfw0ea80w9ujznisyigcexqpjkok-0m1u4kzamn1j0bdthcqyupe5i 218.145.56.75:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

docker node ls
root@pod641:~# docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
9eymmbwhxqvuvcf7tazfhqisd *   pod641              Ready               Active              Leader              19.03.8
ll22mmp1pukxh37yeozieqpqc     pod642              Ready               Active                                  19.03.8














