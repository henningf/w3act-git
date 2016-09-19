FROM centos:7

RUN yum install postgresql -y && \
    yum install java-1.8.0-openjdk -y

COPY w3act /opt/w3act 

ENV POSTGRES_USER training
ENV POSTGRES_PASSWORD training
ENV POSTGRES_HOST postgres
ENV POSTGRES_DB w3act

EXPOSE 9000

WORKDIR /opt/w3act

# Script that waits for the database to be accessible before starting w3act
CMD ["/opt/w3act/bin/wait_for_it.sh"]
