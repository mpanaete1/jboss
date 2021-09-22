FROM maven As build 

COPY ./src /home/app/src 

COPY pom.xml /home/app/pom.xml 

RUN mvn -f /home/app/pom.xml clean package 

FROM redhat/ubi8

MAINTAINER phoesi@gmail.com 

RUN yum install -y sudo unzip java-1.8.0-openjdk-devel && \
	yum clean all && \
	echo "%wheel ALL=(ALL) NOPASSWD: ALL " >> /etc/sudoers && \
	mkdir /opt/jboss && \
	useradd -m jboss; echo jboss: |chpasswd ; usermod -a -G wheel jboss && \
	cat /etc/passwd ; cat /etc/group 
	

WORKDIR /opt/jboss 

COPY ./jboss-eap-6.2 .

COPY --from=build /home/app/target/spring-boot-hello-world-0.0.1-SNAPSHOT.jar /opt/jboss/standalone/deployments/spring-boot-hello-world-0.0.1.jar


RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> /opt/jboss/bin/standalone.conf && \
	/opt/jboss/bin/add-user.sh admin admin@18 -s 
#	chown -R jboss:jboss /opt/jboss

EXPOSE 8080 9990 9999 

USER root

ENTRYPOINT /opt/jboss/bin/standalone.sh -c standalone-full-ha.xml 

CMD /bin/bash 
