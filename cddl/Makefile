.DEFAULT_GOAL := check

SHELL := /bin/bash

include tools.mk

%.cbor: %.diag
	$(diag2cbor) $< > $@

check:: cbor-tags-unique
check:: check-intrep check-intrep-examples
check:: check-corim check-corim-examples
check:: check-comid check-comid-examples
check:: check-cotl check-cotl-examples

# $1: label
# $2: cddl fragments
# $3: diag test files
define cddl_check_template

check-$(1): $(1)-autogen.cddl
	$$(cddl) $$< g 1 | $$(diag2diag) -e

.PHONY: check-$(1)

$(1)-autogen.cddl: $(2)
	for f in $$^ ; do ( grep -v '^;' $$$$f ; echo ) ; done > $$@

CLEANFILES += $(1)-autogen.cddl

check-$(1)-examples: $(1)-autogen.cddl $(3:.diag=.cbor)
	@for f in $(3:.diag=.cbor); do \
		echo ">> validating $$$$f against $$<" ; \
		$$(cddl) $$< validate $$$$f &>/dev/null || exit 1 ; \
		echo ">> saving prettified CBOR to $$$${f%.cbor}.pretty" ; \
		$$(cbor2pretty) $$$$f > $$$${f%.cbor}.pretty ; \
	done

.PHONY: check-$(1)-examples

CLEANFILES += $(3:.diag=.cbor)
CLEANFILES += $(3:.diag=.pretty)

endef # cddl_check_template

# Commented since CI doesn't have openssl
examples/sig-structure.diag: examples/sig-structure.diag.tmpl examples/payload-corim-4.diag examples/protected-header-map.diag
	payload="$$(cat examples/payload-corim-4.diag)" \
	protected="$$(cat examples/protected-header-map.diag)" \
	envsubst < examples/sig-structure.diag.tmpl > examples/sig-structure.diag

examples/testkey.pem:
	openssl ecparam -name secp384r1 -genkey -noout -out examples/testkey.pem

examples/corim-4.sig: examples/sig-structure.cbor examples/testkey.pem
	openssl dgst -sha384 -sign examples/testkey.pem -out examples/corim-4.sig examples/sig-structure.cbor

examples/corim-4.diag: examples/corim-4.sig examples/corim-4.diag.tmpl examples/payload-corim-4.diag examples/protected-header-map.diag
	payload="$$(cat examples/payload-corim-4.diag)" \
	protected="$$(cat examples/protected-header-map.diag)" \
	signature="h'$$(cat examples/corim-4.sig | xxd -p -c 128)'" \
	envsubst < examples/corim-4.diag.tmpl > examples/corim-4.diag

include corim-frags.mk

$(eval $(call cddl_check_template,comid,$(COMID_FRAGS),$(COMID_EXAMPLES)))
$(eval $(call cddl_check_template,cotl,$(COTL_FRAGS),$(COTL_EXAMPLES)))
$(eval $(call cddl_check_template,corim,$(CORIM_FRAGS),$(CORIM_EXAMPLES)))
$(eval $(call cddl_check_template,intrep,$(INTREP_FRAGS),$(INTREP_EXAMPLES)))

GITHUB := https://raw.githubusercontent.com/
COSWID_REPO := sacmwg/draft-ietf-sacm-coswid/master
COSWID_REPO_URL := $(join $(GITHUB), $(COSWID_REPO))

concise-swid-tag.cddl: ; $(curl) -O $(COSWID_REPO_URL)/$@

CLEANFILES += concise-swid-tag.cddl

clean: ; rm -f $(CLEANFILES)

# Extract the CBOR tags defined by CoRIM/CoMID (i.e., those in the 5xx space)
cbor-tags.txt: $(wildcard *.cddl) ; grep -h '#6\.5' *cddl | sort -u -t'=' -k2 > $@

# Return an error if there are duplicate CBOR Tags defined
cbor-tags-unique: cbor-tags.txt
	@echo -n "duplicated CBOR tag(s): "
	@if grep -E -h -o '#6\.[0-9]{3}' $< | uniq -d | grep . -c ; \
	then \
		echo "check the following:" ; \
		grep -E -h -o '#6\.[0-9]{3}' $< | uniq -d ; \
	fi
