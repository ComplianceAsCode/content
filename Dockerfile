FROM centos:7

ENV OSCAP_USERNAME oscap
ENV OSCAP_DIR scap-security-guide
ENV BUILD_JOBS 4

RUN yum -y upgrade && \
    yum -y install make cmake openscap-utils && \
    mkdir -p /home/$OSCAP_USERNAME && \
    yum clean all && \
    rm -rf /usr/share/doc /usr/share/doc-base \
        /usr/share/man /usr/share/locale /usr/share/zoneinfo

WORKDIR /home/$OSCAP_USERNAME

COPY . $OSCAP_DIR/

# clean the build dir in case the user is also building SSG locally
RUN rm -rf $OSCAP_DIR/build/*

WORKDIR /home/$OSCAP_USERNAME/$OSCAP_DIR/build

RUN cmake ..

CMD /usr/bin/make -j $BUILD_JOBS
