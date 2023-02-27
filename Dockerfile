# Pull base image 
from tomcat:latest
# Maintainer 
LABEL MAINTAINER "pavandeepakpagadala@gmail.com"
# To copy war file from jenkins to  docker image tomcat server
COPY /root/webapp.war /usr/local/tomcat/webapps/ 
EXPOSE 8080
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]