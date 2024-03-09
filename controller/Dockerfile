FROM debian:bookworm-slim

MAINTAINER Ferenc Vajda, ferenc.vajda@gmail.com

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update; \
    apt-get -y install \
        openssh-server \
        less \
        vim \
        sshpass \
        software-properties-common \
        ; \
        \
    apt-add-repository ppa:ansible/ansible; \
    apt-get update; \
    apt-get -y install ansible; \
        \
    mkdir -p /var/work;\
    mkdir -p /var/run/sshd; \
    mkdir -p /root/.ssh; \
        \
    echo 'root:root' | chpasswd; \
        \
    sed -i 's/UsePAM yes/#&/g' /etc/ssh/sshd_config; \
    sed -Ei 's/^#?\s*(PermitRootLogin)\s.*/\1 yes/' /etc/ssh/sshd_config

COPY ./docker-entrypoint.sh /

WORKDIR /var/work

EXPOSE 22

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD    ["/usr/sbin/sshd", "-D"]
