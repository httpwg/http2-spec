xml2rfc ?= "/usr/local/bin/xml2rfc"
saxpath ?= "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon ?= java -classpath $(saxpath) net.sf.saxon.Transform -novw -l

http2_name = http2
compression_name = header-compression
names = $(http2_name) $(compression_name)
drafts = $(addprefix draft-ietf-httpbis-,$(names))
next_ver = $(foreach draft, $(drafts), -$(shell printf "%.2d" $$((1$(shell git tag | grep "$(draft)" | sort | tail -1 | awk -F- '{print $$NF}')-99)) ) )
next = $(join $(drafts),$(next_ver))

TARGETS = $(addsuffix .txt,$(drafts)) \
          $(addsuffix .html,$(drafts))

.PHONY: latest submit idnits clean issues $(names)
.INTERMEDIATE: $(addsuffix .redxml,$(drafts))

latest: $(TARGETS)
$(names): $(addsuffix .txt,$(drafts))

submit: $(addsuffix .txt,$(next))

ifeq "$(shell uname -s 2>/dev/null)" "Darwin"
    sed_i := sed -i ''
else
    sed_i := sed -i
endif

$(addsuffix .xml,$(next)): $(addsuffix .xml,$(drafts))
	cp $< $@
	$(sed_i) -e"s/$(basename $<)-latest/$(basename $@)/" $@

idnits: $(addsuffix .txt,$(next))
	idnits $<

clean:
	-rm -f $(addsuffix .redxml,$(drafts))
	-rm -f $(addsuffix *.txt,$(drafts))
	-rm -f $(addsuffix *.html,$(drafts))

stylesheet = lib/myxml2rfc.xslt
%.html: %.xml $(stylesheet)
	$(saxon) $< $(stylesheet) > $@
	$(sed_i) -e"s*</style>*</style><style tyle='text/css'>$(shell cat lib/style.css)</style>*" $@

reduction  = lib/clean-for-DTD.xslt
%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@

# backup issues
issues:
	curl https://api.github.com/repos/http2/http2-spec/issues?state=open > issues.json
