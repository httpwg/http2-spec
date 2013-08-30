xml2rfc ?= "/usr/local/bin/xml2rfc"
saxpath ?= "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon ?= java -classpath $(saxpath) net.sf.saxon.Transform -novw -l

names := http2 header-compression
drafts := $(addprefix draft-ietf-httpbis-,$(names))
current_ver = $(shell git tag | grep "$(draft)" | sort | tail -1 | awk -F- '{print $$NF}')
next_ver := $(foreach draft, $(drafts), -$(shell printf "%.2d" $$((1$(current_ver)-99)) ) )
next := $(join $(drafts),$(next_ver))

TARGETS := $(addsuffix .txt,$(drafts)) \
          $(addsuffix .html,$(drafts))

.PHONY: latest submit idnits clean issues $(names) hpack
.INTERMEDIATE: $(addsuffix .redxml,$(drafts))

latest: $(TARGETS)

# build rules for specific targets
makerule = $(join $(addsuffix :: ,$(names)),$(addsuffix .$(1),$(drafts)))
$(foreach rule,$(call makerule,txt) $(call makerule,html),$(eval $(rule)))
hpack: header-compression

submit: $(addsuffix .txt,$(next))

ifeq "$(shell uname -s 2>/dev/null)" "Darwin"
    sed_i := sed -i ''
else
    sed_i := sed -i
endif

define submit_makerule =
$(1)
	cp $$< $$@
	$$(sed_i) -e"s/$$(basename $$<)-latest/$$(basename $$@)/" $$@
endef
submit_deps := $(join $(addsuffix .xml: ,$(next)),$(addsuffix .xml,$(drafts)))
$(foreach rule,$(submit_deps),$(eval $(call submit_makerule,$(rule))))

idnits: $(addsuffix .txt,$(next))
	idnits $<

clean:
	-rm -f $(addsuffix .redxml,$(drafts))
	-rm -f $(addsuffix *.txt,$(drafts))
	-rm -f $(addsuffix *.html,$(drafts))

stylesheet := lib/myxml2rfc.xslt
extra_css := lib/style.css
css_content = $(shell cat $(extra_css))
%.html: %.xml $(stylesheet) $(extra_css)
	$(saxon) $< $(stylesheet) > $@
	$(sed_i) -e"s*</style>*</style><style tyle='text/css'>$(css_content)</style>*" $@

reduction := lib/clean-for-DTD.xslt
%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@

# backup issues
issues:
	curl https://api.github.com/repos/http2/http2-spec/issues?state=open > issues.json
