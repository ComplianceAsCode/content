FROM centos:7

ENV OSCAP_USERNAME oscap
ENV OSCAP_GIT https://github.com/OpenSCAP/scap-security-guide.git
ENV OSCAP_DIR scap-security-guide

RUN yum -y upgrade && \
    yum -y install git make openscap-utils openscap-python python-lxml rpmlib && \
    useradd --home /home/$OSCAP_USERNAME --create-home --user-group --shell /bin/bash $OSCAP_USERNAME && \
    yum clean all && \
    rm -rf /usr/share/doc /usr/share/doc-base \
        /usr/share/man /usr/share/locale /usr/share/zoneinfo

WORKDIR /home/$OSCAP_USERNAME

USER $OSCAP_USERNAME
RUN git clone $OSCAP_GIT $OSCAP_DIR

WORKDIR /home/$OSCAP_USERNAME/$OSCAP_DIR

VOLUME /home/$OSCAP_USERNAME/$OSCAP_DIR

ENTRYPOINT ["/usr/bin/make"]
CMD ["all"]
