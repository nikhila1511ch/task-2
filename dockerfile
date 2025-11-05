FROM ubuntu:latest

RUN apt update 

RUN apt-get -y  update 

RUN apt-get -y install apache2

COPY index.html  /var/www/html 

EXPOSE 80

CMD ["ubuntu"]


