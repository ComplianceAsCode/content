FROM opensuse/leap:15.2

ENV OSCAP_USERNAME oscap
ENV OSCAP_DIR content
ENV BUILD_JOBS 4

RUN true \
	&& zypper --non-interactive in cmake ninja expat openscap-utils libxml2-tools libxslt-tools python3-PyYAML python3-Jinja2 python3-pytest python3-pytest-cov python3-Sphinx python3-sphinx_rtd_theme python3-pip python3-myst-parser \
        && pip install pip --upgrade \
        && pip install json2html sphinxcontrib.jinjadomain \
	&& mkdir -p /home/$OSCAP_USERNAME \
	&& rm -rf /usr/share/doc /usr/share/doc-base \
		/usr/share/man /usr/share/locale /usr/share/zoneinfo \
	&& true

WORKDIR /home/$OSCAP_USERNAME

COPY . $OSCAP_DIR/

# clean the build dir in case the user is also building SSG locally
RUN rm -rf $OSCAP_DIR/build/*

WORKDIR /home/$OSCAP_USERNAME/$OSCAP_DIR/build

CMD true \
	&& cmake -G Ninja .. \
	&& ninja -j $BUILD_JOBS \
	&& ctest --output-on-failure -j $BUILD_JOBS \
	&& true
