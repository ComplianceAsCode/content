SITECONFIG="../ssg-docs.cfg"

all: user_guide developer_guide

user_guide:
	cd User_Guide/ \
	&& publican build --publish --formats html,html-single,epub --embedtoc --langs en-US \
	&& publican install_book --site_config $(SITECONFIG) --lang en-US

developer_guide:
	cd Developer_Guide/ \
	&& publican build --publish --formats html,html-single,epub --embedtoc --langs en-US \
	&& publican install_book --site_config $(SITECONFIG) --lang en-US

clean:
	cd User_Guide &&  publican clean 
	cd Developer_Guide && publican clean 
