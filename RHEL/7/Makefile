IN = input
OUT = output
TRANS = transforms
REFS = "../../shared/references"
UTILS = utils
DIST = dist

ID = ssg

all: shorthand2xccdf tables guide content dist

shorthand-guide:
	xsltproc -o $(OUT)/rhel7-shorthand.xml $(IN)/guide.xslt $(IN)/guide.xml
	xmllint --format --output $(OUT)/rhel7-shorthand.xml $(OUT)/rhel7-shorthand.xml

shorthand2xccdf: shorthand-guide
	xsltproc -o $(OUT)/unlinked-unresolved-rhel7-xccdf.xml $(TRANS)/shorthand2xccdf.xslt $(OUT)/rhel7-shorthand.xml
	oscap xccdf resolve -o $(OUT)/unlinked-rhel7-xccdf.xml $(OUT)/unlinked-unresolved-rhel7-xccdf.xml
#	xsltproc -stringparam profile "stig-rhel7-server" -o $(OUT)/unlinked-rhel7-xccdf.xml \
#		$(TRANS)/xccdf-addrefs.xslt $(OUT)/unlinked-rhel7-xccdf.xml
	xsltproc -stringparam profile "rht-ccp" -o $(OUT)/unlinked-rhel7-xccdf.xml \
		$(TRANS)/xccdf-addrefs.xslt $(OUT)/unlinked-rhel7-xccdf.xml
#   extract manual check instructions from xccdf into an ocil file
	xsltproc -o $(OUT)/unlinked-rhel7-ocil.xml $(TRANS)/xccdf-create-ocil.xslt $(OUT)/unlinked-rhel7-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-rhel7-ocil.xml $(OUT)/unlinked-rhel7-ocil.xml 
	xsltproc -o $(OUT)/unlinked-ocilrefs-rhel7-xccdf.xml $(TRANS)/xccdf-ocilcheck2ref.xslt $(OUT)/unlinked-rhel7-xccdf.xml
	./$(TRANS)/combinefixes.py $(IN)/fixes/bash/ $(OUT)/bash-remediations.xml
	xsltproc -stringparam fixes "../$(OUT)/bash-remediations.xml" -o $(OUT)/unlinked-rhel7-xccdf.xml $(TRANS)/xccdf-addfixes.xslt $(OUT)/unlinked-rhel7-xccdf.xml
	xmllint --format --output $(OUT)/unlinked-rhel7-xccdf.xml $(OUT)/unlinked-rhel7-xccdf.xml

checks:
	xmlwf $(IN)/checks/*.xml
	$(TRANS)/combinechecks.py $(IN)/checks > $(OUT)/unlinked-rhel7-oval.xml
	xmllint --format --output $(OUT)/unlinked-rhel7-oval.xml $(OUT)/unlinked-rhel7-oval.xml

guide: shorthand2xccdf
#	remove auxiliary Groups which are only for use in tables, and not guide output.
#	specifying a nonexistent profile, "allrules," to make oscap print all Rules
	xsltproc -o $(OUT)/unlinked-rhel7-xccdf-guide.xml $(TRANS)/xccdf-removeaux.xslt $(OUT)/unlinked-rhel7-xccdf.xml
	xsltproc -o $(OUT)/unlinked-notest-rhel7-xccdf-guide.xml $(TRANS)/xccdf-removetested.xslt $(OUT)/unlinked-rhel7-xccdf-guide.xml
	oscap xccdf generate guide --profile allrules $(OUT)/unlinked-notest-rhel7-xccdf-guide.xml > $(OUT)/rhel7-guide.html
	xsltproc -o $(OUT)/rhel7-guide-custom.html $(TRANS)/xccdf2html.xslt $(OUT)/unlinked-notest-rhel7-xccdf-guide.xml

# example, if needed: for converting XCCDF into shorthand
#xccdf2shorthand:
#	xsltproc -o $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml $(TRANS)/xccdf2shorthand.xslt $(REFS)/usgcb-rhel5desktop-xccdf.xml
#	tidy -m -xml -utf8 --indent-spaces=0 $(XCCDF_OUTPUT_DIR)/rhel5-shorthand.xml

table-refs: shorthand2xccdf
	xsltproc -stringparam ref "nist" -o $(OUT)/table-rhel7-nistrefs.html $(TRANS)/xccdf2table-byref.xslt $(OUT)/unlinked-rhel7-xccdf.xml
	xsltproc -stringparam profile "common" -o $(OUT)/table-rhel7-nistrefs-common.html \
		$(TRANS)/xccdf2table-profilenistrefs.xslt $(OUT)/unlinked-rhel7-xccdf.xml

table-idents: shorthand2xccdf
	xsltproc -o $(OUT)/table-rhel7-cces.html $(TRANS)/xccdf2table-cce.xslt $(OUT)/unlinked-rhel7-xccdf.xml

table-srgmap: shorthand2xccdf
# the map-to-items filename must be provided relative to the root of the main document being processed
	xsltproc -stringparam map-to-items "../$(OUT)/unlinked-rhel7-xccdf.xml" -o $(OUT)/table-rhel7-srgmap.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml
	xsltproc -stringparam flat "y" -stringparam map-to-items "../$(OUT)/unlinked-rhel7-xccdf.xml" -o $(OUT)/table-rhel7-srgmap-flat.html \
		$(TRANS)/table-srgmap.xslt $(REFS)/disa-os-srg-v1r1.xml
	xmllint --xmlout --html --output $(OUT)/table-rhel7-srgmap-flat.xhtml $(OUT)/table-rhel7-srgmap-flat.html

table-stigs: shorthand2xccdf table-srgmap checks
	xsltproc -o $(OUT)/table-rhel5-stig.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf.xml  
	xsltproc -o $(OUT)/table-rhel5-stig-manual.html $(TRANS)/xccdf2table-stig.xslt $(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml  
#	xsltproc -stringparam notes "../$(IN)/auxiliary/transition_notes.xml" -o $(OUT)/table-rhel5-stig-manual-withnotes.html \
#		$(TRANS)/xccdf2table-stig.xslt \
#		$(REFS)/disa-stig-rhel5-v1r0.6-xccdf-manual.xml
#	temporarily retain an output file showing the short titles as well
	xsltproc -stringparam profile "stig-rhel7-server" -stringparam testinfo "y" -o $(OUT)/table-stig-rhel7-testinfo.html \
		$(TRANS)/xccdf2table-profileccirefs.xslt \
		$(OUT)/unlinked-rhel7-xccdf.xml
	xsltproc -stringparam overlay "../$(IN)/auxiliary/stig_overlay.xml" -o $(OUT)/unlinked-stig-rhel7-xccdf.xml \
		$(TRANS)/xccdf-apply-overlay-stig.xslt \
		$(OUT)/unlinked-rhel7-xccdf.xml
	xsltproc -o $(OUT)/table-rhel7-stig.html $(TRANS)/xccdf2table-stig.xslt $(OUT)/unlinked-stig-rhel7-xccdf.xml  

tables: table-refs table-idents table-srgmap table-stigs

content: shorthand2xccdf guide checks
#	the relabelids.py script chdirs to ./output, so refer to files from there.
#	its second argument controls the IDs, as well as the output filenames.
#	thus, with ID set to ssg, this creates ssg-rhel7-xccdf.xml and ssg-rhel7-oval.xml.
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-rhel7-oval.xml $(IN)/checks/platform/rhel7-cpe-dictionary.xml $(ID)
	$(TRANS)/relabelids.py unlinked-rhel7-xccdf.xml $(ID)
	$(TRANS)/relabelids.py unlinked-ocilrefs-rhel7-xccdf.xml $(ID)
#       Once things are relabelled, create a datastream
	xsltproc /usr/share/openscap/xsl/xccdf_1.1_remove_dangling_sub.xsl $(OUT)/$(ID)-rhel7-xccdf.xml \
		> $(OUT)/$(ID)-rhel7-xccdf-nodangles.xml
	xsltproc --stringparam reverse_DNS org.ssgproject.content /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl \
		$(OUT)/$(ID)-rhel7-xccdf-nodangles.xml > $(OUT)/$(ID)-rhel7-xccdf-1.2.xml
	sed -i '/idref="dangling reference to /d' $(OUT)/$(ID)-rhel7-xccdf-1.2.xml
	oscap ds sds-compose $(OUT)/$(ID)-rhel7-xccdf-1.2.xml $(OUT)/$(ID)-rhel7-ds.xml
#       Add in CPE and OVAL content to datastream
	oscap ds sds-add $(OUT)/$(ID)-rhel7-cpe-dictionary.xml $(OUT)/$(ID)-rhel7-ds.xml
	oscap ds sds-add $(OUT)/$(ID)-rhel7-oval.xml $(OUT)/$(ID)-rhel7-ds.xml


content-stig: shorthand2xccdf guide checks
	xmllint --format --output $(OUT)/unlinked-stig-rhel7-xccdf.xml $(OUT)/unlinked-stig-rhel7-xccdf.xml 
	$(TRANS)/cpe_generate.py $(OUT)/unlinked-rhel7-oval.xml $(IN)/checks/platform/rhel7-cpe-dictionary.xml disa-predraft
	$(TRANS)/relabelids.py unlinked-stig-rhel7-xccdf.xml disa-predraft
	xmllint --format --output $(OUT)/disa-predraft-stig-rhel7-xccdf.xml $(OUT)/disa-predraft-stig-rhel7-xccdf.xml

submission-stig-check: table-stigs
	cd output; ../$(UTILS)/verify-references.py -p stig-rhel7-server --rules-with-disarefs-outside-profile unlinked-rhel7-xccdf-prerefs.xml
#	$(TRANS)/xccdf2csv-stig.py $(OUT)/unlinked-stig-rhel7-xccdf.xml > $(OUT)/table-stig.csv

# content-usgcb: coming soon

validate-xml:
	oscap xccdf validate-xml $(OUT)/$(ID)-rhel7-xccdf.xml
	oscap oval validate-xml $(OUT)/$(ID)-rhel7-oval.xml
	oscap oval validate-xml $(OUT)/$(ID)-rhel7-cpe-oval.xml

validate: validate-xml
	cd output; ../$(UTILS)/verify-references.py --rules-with-invalid-checks --ovaldefs-unused ssg-rhel7-xccdf.xml
	oscap oval validate-xml --schematron $(OUT)/$(ID)-rhel7-oval.xml

eval-test:
	oscap xccdf eval --profile test $(OUT)/$(ID)-rhel7-xccdf.xml

eval-common:
	oscap xccdf eval --profile common --oval-results --results /tmp/results-test.xml $(OUT)/$(ID)-rhel7-xccdf.xml

# items in dist are expected for distribution in an rpm
dist: tables guide content
	mkdir -p $(DIST)/content
	cp $(OUT)/$(ID)-rhel7-xccdf.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhel7-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhel7-cpe-dictionary.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhel7-cpe-oval.xml $(DIST)/content
	cp $(OUT)/$(ID)-rhel7-ds.xml $(DIST)/content

clean:
	rm -f $(OUT)/*.xml $(OUT)/*.html $(OUT)/*.xhtml $(OUT)/*.pdf  $(OUT)/*.spec $(OUT)/*.tar $(OUT)/*.gz $(OUT)/*.ini $(OUT)/*.csv
	rm -rf $(DIST)/content
