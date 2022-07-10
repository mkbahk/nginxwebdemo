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
###
#docker build . -t mkbahk/nginxwebdemo:0.1
#docker build . -t mkbahk/nginxwebdemo:latest
#docker run -it -d -p 8380-8389:80 -n nginxwebdemo nginxwebdemo:0.1 
#이경우 여러개 같은 명령어를 수행하면 8380-8389 중 하나를 선택하면
