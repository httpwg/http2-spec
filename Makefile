xml2rfc = "/usr/local/bin/xml2rfc"
saxpath = "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -novw -l

draft_title = draft-ietf-httpbis-http2
current_rev = $(shell git tag | tail -1 | awk -F- '{print $$NF}')
next_rev = $(shell printf "%.2d" `echo ${current_rev}+1 | bc`)

stylesheet = lib/myxml2rfc.xslt
reduction  = lib/clean-for-DTD.xslt

TARGETS = $(draft_title).html \
          $(draft_title).redxml \
          $(draft_title).txt

latest: $(TARGETS)

submit: $(draft_title)-$(next_rev).xml $(draft_title)-$(next_rev).txt

$(draft_title)-$(next_rev).xml:
	cp $(draft_title).xml $(draft_title)-$(next_rev).xml
	sed -i '' -e"s/$(draft_title)-latest/$(draft_title)-$(next_rev)/" $(draft_title)-$(next_rev).xml

clean:
	rm -f $(draft_title).redxml
	rm -f $(draft_title)-*.xml
	rm -f $(draft_title)-*.txt

%.html: %.xml $(stylesheet)
	$(saxon) $< $(stylesheet) > $@

%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@
