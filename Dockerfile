FROM centos@sha256:2ae0d2c881c7123870114fb9cc7afabd1e31f9888dac8286884f6cf59373ed9b

RUN yum install postgresql -y && \
    yum install java-1.8.0-openjdk -y

COPY w3act /opt/w3act 

ENV POSTGRES_USER training
ENV POSTGRES_PASSWORD training
ENV POSTGRES_HOST postgres
ENV POSTGRES_DB w3act
ENV PGPASSWORD training

EXPOSE 9000

WORKDIR /opt/w3act

# Script that waits for the database to be accessible before starting w3act
CMD ["/opt/w3act/bin/wait_for_it.sh"]
