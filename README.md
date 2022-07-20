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
docker image ls
docker tag mkbahk/nginxwebdemo:0.1 mkbahk/nginxwebdemo:latest
docker image ls
docker run -it -d -p 8380-8389:80 --name nginxwebdemo mkbahk/nginxwebdemo:latest

curl http://localhost:8380
or
browse http://192.168.56.202:8380/

//정리
docker container stop nginxwebdemo
docker container ls -a
docker container rm nginxwebdemo
docker system prune -a


//DOCKER-COMPOSE를 이용한 Service화(docker run -d 명령을 script화)
//docker engine version  20.10.17의 경우 아래 동작하지 않음. 버그로 추정됨. 아래 버젼으로 맞추어 주세요.
root@master202:~/nginxwebdemo# docker --version
Docker version 19.03.8, build afacb8b7f0

root@master202:~/nginxwebdemo# docker-compose --version
docker-compose version 1.24.1, build 4667896b


cat docker-compose.yaml
###
version : "3"
services:
   nginxwebdemo:
#      image: "mkbahk/nginxwebdemo:latest"
      build:
         context: .
         dockerfile: ./Dockerfile
      ports:
         - "8380-8389:80"
      networks:
         - nginx-net
networks:
   nginx-net:
###
#docker-compose up -d --build
#docker-compose down --rmi all
#
#docker-compose up -d --build --scale nginxwebdemo=10
#docker-compose up --scale nginxwebdemo=5
#docker-compose down --rmi all
#
###

docker-compose up -d --build --scale nginxwebdemo=10
docker container ls

curl http://localhost:8380

docker-compose scale nginxwebdemo=5
docker-compose down --rmi all
docker system prune -a

//docker-compose는 서비스화는 하지만, 관리는 하지 않는다. 그래서 docker stack+swarm

//docekr swarm 설치
root@master202:~# docker swarm init --advertise-addr  192.168.56.202
Swarm initialized: current node (ivvqdgznogt65ed0dn6i7j21p) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-1gbj0meujt4d1ga3d6emjj7whh91l6walybjdu7bso330ylhv7-71z07b7n3rotet9mpztla6w7i 192.168.56.202:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

root@worker203:~# docker swarm join --token SWMTKN-1-1gbj0meujt4d1ga3d6emjj7whh91l6walybjdu7bso330ylhv7-71z07b7n3rotet9mpztla6w7i 192.168.56.202:2377
This node joined a swarm as a worker.
root@worker203:~#

root@worker204:~# docker swarm join --token SWMTKN-1-1gbj0meujt4d1ga3d6emjj7whh91l6walybjdu7bso330ylhv7-71z07b7n3rotet9mpztla6w7i 192.168.56.202:2377
This node joined a swarm as a worker.
root@worker204:~#


docker node ls
root@pod641:~# docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
9eymmbwhxqvuvcf7tazfhqisd *   pod641              Ready               Active              Leader              19.03.8
ll22mmp1pukxh37yeozieqpqc     pod642              Ready               Active                                  19.03.8



cat  docker-stack-compose.yaml
###
version : "3"
services:
   nginxwebdemo:
      image: "mkbahk/nginxwebdemo:latest"
      build:
         context: .
         dockerfile: ./Dockerfile
      deploy:
         replicas: 5
         restart_policy:
            condition: on-failure
         resources:
           limits:
             cpus: "0.1"
             memory: 50M
      ports:
         - "8380:80"
      networks:
         - nginx-net
networks:
   nginx-net:
###
#docker stack deploy -c docker-stack-compose.yaml nginxstack
#docker stack ls
#docker service ls
#docker stack rm nginxstack
###


docker stack deploy -c docker-stack-compose.yaml nginxwebdemostack
docker stack ls
docker service ls
curl http://localhost:8380/

//docker engine version  20.10.17의 경우 아래 동작하지 않음. 버그로 추정됨.
docker container stop 
docker service ls

docker stack rm nginxwebdemostack


//End of Documents









