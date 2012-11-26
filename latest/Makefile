xml2rfc = "../../xml2rfc/xml2rfc.tcl"
saxpath = "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -novw -l

stylesheet = ../../draft-ietf-httpbis/myxml2rfc.xslt
reduction  = ../../rfc2629xslt/clean-for-DTD.xslt

TARGETS = draft-ietf-httpbis-http2.html \
          draft-ietf-httpbis-http2.redxml \
          draft-ietf-httpbis-http2.txt

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.xml $(stylesheet)
	$(saxon) $< $(stylesheet) > $@

%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@
