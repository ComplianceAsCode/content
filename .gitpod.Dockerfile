FROM gitpod/workspace-full
ENV PYTHONUSERBASE=/workspace/.pip-modules
ENV PATH=$PYTHONUSERBASE/bin:$PATH
ENV PIP_USER=yes
USER gitpod
RUN sudo apt-get update -q && \
        sudo apt-get install -yq \
        cmake \
        ninja-build \
        libxml2-utils \
        xsltproc \
        python3-jinja2 \
        python3-yaml \
        python3-setuptools \
        ansible-lint \
        python3-github \
        bats \
        python3-pytest \
        python3-pytest-cov \
        libdbus-1-dev libdbus-glib-1-dev libcurl4-openssl-dev \
        libgcrypt20-dev libselinux1-dev libxslt1-dev libgconf2-dev libacl1-dev libblkid-dev \
        libcap-dev libxml2-dev libldap2-dev libpcre3-dev python3-dev swig libxml-parser-perl \
        libxml-xpath-perl libperl-dev libbz2-dev librpm-dev g++ libapt-pkg-dev libyaml-dev \
        libxmlsec1-dev libxmlsec1-openssl \
        shellcheck \
        bats \
        yamllint

RUN wget https://github.com/OpenSCAP/openscap/releases/download/1.3.6/openscap-1.3.6.tar.gz

RUN tar -zxvf openscap-1.3.6.tar.gz

RUN cd openscap-1.3.6 && \
        mkdir -p build && cd build && \
        cmake -DCMAKE_INSTALL_PREFIX=/ .. && \
        sudo make install && \
        cd ../..
