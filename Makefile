xml2rfc ?= "xml2rfc"
saxpath ?= "lib/saxon9.jar"
saxon ?= java -classpath $(saxpath) net.sf.saxon.Transform -novw -l

names := http2 header-compression alt-svc
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

idnits: $(addsuffix .txt,$(next))
	idnits $<

clean:
	-rm -f $(addsuffix .redxml,$(drafts))
	-rm -f $(addsuffix *.txt,$(drafts))
	-rm -f $(addsuffix *-[0-9][0-9].xml,$(drafts))
	-rm -f $(addsuffix *.html,$(drafts))

define makerule_submit_xml =
$(1)
	sed -e"s/$$(basename $$<)-latest/$$(basename $$@)/" $$< > $$@
endef
submit_deps := $(join $(addsuffix .xml: ,$(next)),$(addsuffix .redxml,$(drafts)))
$(foreach rule,$(submit_deps),$(eval $(call makerule_submit_xml,$(rule))))

$(addsuffix .txt,$(next)): %.txt: %.xml
	$(xml2rfc) $< $@

%.txt: %.redxml
	$(xml2rfc) $< $@

stylesheet := lib/myxml2rfc.xslt
extra_css := lib/style.css
css_content = $(shell cat $(extra_css))
%.htmltmp: %.xml $(stylesheet) $(extra_css)
	$(saxon) $< $(stylesheet) > $@

%.html: %.htmltmp
	sed -e's~</style>~</style><style tyle="text/css">$(css_content)</style>~' $< > $@

reduction := lib/clean-for-DTD.xslt
%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@

ghpages: $(addsuffix .txt,$(drafts)) $(addsuffix .html,$(drafts))
	$(MAKE) -v

# backup issues
issues:
	curl https://api.github.com/repos/http2/http2-spec/issues?state=open > issues.json
