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
friendly_names := index compression alt-svc
FRIENDLY := $(addsuffix .txt,$(friendly_names)) \
	    $(addsuffix .html,$(friendly_names))

.PHONY: latest submit idnits clean issues $(names) hpack
.INTERMEDIATE: $(addsuffix .redxml,$(drafts))
.PRECIOUS: $(TARGETS)

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

index.%: draft-ietf-httpbis-http2.%
	cp -f $< $@

compression.%: draft-ietf-httpbis-header-compression.%
	cp -f $< $@

alt-svc.%: draft-ietf-httpbis-alt-svc.%
	cp -f $< $@

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
%.html: %.xml $(stylesheet) $(extra_css)
	$(saxon) $< $(stylesheet) | sed -e's~</style>~</style><style tyle="text/css">$(css_content)</style>~' > $@

reduction := lib/clean-for-DTD.xslt
%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@

GHPAGES_TMP := /tmp/ghpages$(shell echo $$$$)
.TRANSIENT: $(GHPAGES_TMP)
GIT_ORIG_BRANCH := $(shell git branch | grep '*' | cut -c 3-)
GIT_ORIG_REV := $(shell git rev-list HEAD~..)

IS_LOCAL := $(if $(TRAVIS),true,)
ifeq (master,$(TRAVIS_BRANCH))
IS_MASTER := $(findstring false,$(TRAVIS_PULL_REQUEST))
else
IS_MASTER := true
endif

ghpages: $(FRIENDLY) $(TARGETS)
ifneq (,$(or $(IS_LOCAL),$(IS_MASTER)))
	mkdir $(GHPAGES_TMP)
	cp -f $^ $(GHPAGES_TMP)
	git clean -qfdX
	ls;git status
ifeq (true,$(TRAVIS))
	git config user.email "ci-bot@example.com"
	git config user.name "Travis CI Builder"
	git checkout -q --orphan gh-pages
	git rm -qr --cached .
	git clean -qfd
	ls;git status
	git pull -qf origin gh-pages --depth=5
else
	git checkout gh-pages
	git pull
endif
	mv -f $(GHPAGES_TMP)/* $(CURDIR)
	git add $^
	if test `git status -s | wc -l` -gt 0; then git commit -m "Script updating gh-pages."; fi
ifneq (,$(GH_TOKEN))
	@git push https://$(GH_TOKEN)@github.com/http2/http2-spec.git gh-pages
endif
	-git checkout -qf "$(GIT_ORIG_BRANCH)" || git checkout -qf "$(GIT_ORIG_REV)"
	-rm -rf $(GHPAGES_TMP)
endif

# backup issues
issues:
	curl https://api.github.com/repos/http2/http2-spec/issues?state=open > issues.json
