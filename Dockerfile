FROM centos:7

ENV OSCAP_USERNAME oscap
ENV OSCAP_DIR scap-security-guide

RUN yum -y upgrade && \
    yum -y install make cmake openscap-utils openscap-python python-lxml rpmlib && \
    mkdir -p /home/$OSCAP_USERNAME && \
    yum clean all && \
    rm -rf /usr/share/doc /usr/share/doc-base \
        /usr/share/man /usr/share/locale /usr/share/zoneinfo

WORKDIR /home/$OSCAP_USERNAME

COPY . $OSCAP_DIR/

WORKDIR /home/$OSCAP_USERNAME/$OSCAP_DIR/build

RUN cmake ..

ENTRYPOINT ["/usr/bin/make"]
CMD ["all"]
