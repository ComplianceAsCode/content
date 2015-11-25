compare:
	diff output/ ../ | grep -v "Only in ../"

copy:
OUTPUT:=$(shell mkdir -p output)

	cp output/*.sh ../

clean:
	rm -f output/*.sh
	rm -rf output/
