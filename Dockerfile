# Set the base image
FROM tomcat:latest

# Install the AWS CLI
RUN apt-get update && apt-get install -y awscli

# Set the working directory
WORKDIR /usr/local/tomcat/webapps

# Download the WAR file from S3
RUN aws s3 cp s3://myaawsbucket/webapp/target/webapp.war .

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
