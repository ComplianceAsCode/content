# Note: There seems to be known bugs when attempting to publish PDF files.
# To undo any --format pdf builds, you will need to cleanup the docs DB by issuing
# the following commands:
# $ sqlite3 ssg-docs.db 
# SQLite version 3.6.20
# Enter ".help" for instructions
# Enter SQL statements terminated with a ";"
# sqlite> select * from books ;
# 1|en-US|SCAP_Security_Guide|0.1|User_Guide|html||||2013-11-06
# 2|en-US|SCAP_Security_Guide|0.1|User_Guide|html-single||||2013-11-06
# 3|en-US|SCAP_Security_Guide|0.1|Developer_Guide|html||||2013-11-06
# 4|en-US|SCAP_Security_Guide|0.1|Developer_Guide|html-single||||2013-11-06
# 6|en-US|SCAP_Security_Guide|0.1|Developer_Guide|epub||||2013-11-06
# 7|en-US|SCAP_Security_Guide|0.1|User_Guide|epub||||2013-11-06
# 8|en-US|SCAP_Security_Guide|0.1|Developer_Guide|pdf||||2013-11-06     <-- Note the invalid entry 
# sqlite> delete from books where format = 'pdf' ;
# sqlite> select * from books ;
# 1|en-US|SCAP_Security_Guide|0.1|User_Guide|html||||2013-11-06
# 2|en-US|SCAP_Security_Guide|0.1|User_Guide|html-single||||2013-11-06
# 3|en-US|SCAP_Security_Guide|0.1|Developer_Guide|html||||2013-11-06
# 4|en-US|SCAP_Security_Guide|0.1|Developer_Guide|html-single||||2013-11-06
# 6|en-US|SCAP_Security_Guide|0.1|Developer_Guide|epub||||2013-11-06
# 7|en-US|SCAP_Security_Guide|0.1|User_Guide|epub||||2013-11-06
# sqlite> .exit


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
