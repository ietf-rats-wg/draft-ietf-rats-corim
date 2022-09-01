.DEFAULT_GOAL := check

SHELL := /bin/bash

include tools.mk

%.cbor: %.diag
	$(diag2cbor) $< > $@

check:: check-corim check-corim-examples
check:: check-comid check-comid-examples

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

COMID_FRAGS := concise-mid-tag.cddl
COMID_FRAGS += attest-key-triple-record.cddl
COMID_FRAGS += class-id-type-choice.cddl
COMID_FRAGS += class-map.cddl
COMID_FRAGS += comid-entity-map.cddl
COMID_FRAGS += comid-role-type-choice.cddl
COMID_FRAGS += concise-mid-tag.cddl
COMID_FRAGS += coswid-triple-record.cddl
COMID_FRAGS += crypto-key-type-choice.cddl
COMID_FRAGS += domain-dependency-triple-record.cddl
COMID_FRAGS += domain-membership-triple-record.cddl
COMID_FRAGS += domain-type-choice.cddl
COMID_FRAGS += endorsed-triple-record.cddl
COMID_FRAGS += entity-map.cddl
COMID_FRAGS += entity-name-type-choice.cddl
COMID_FRAGS += environment-map.cddl
COMID_FRAGS += flags-map.cddl
COMID_FRAGS += group-id-type-choice.cddl
COMID_FRAGS += identity-triple-record.cddl
COMID_FRAGS += instance-id-type-choice.cddl
COMID_FRAGS += ip-addr-type-choice.cddl
COMID_FRAGS += linked-tag-map.cddl
COMID_FRAGS += mac-addr-type-choice.cddl
COMID_FRAGS += measured-element-type-choice.cddl
COMID_FRAGS += measurement-map.cddl
COMID_FRAGS += measurement-values-map.cddl
COMID_FRAGS += non-empty.cddl
COMID_FRAGS += oid.cddl
COMID_FRAGS += raw-value.cddl
COMID_FRAGS += reference-triple-record.cddl
COMID_FRAGS += svn-type-choice.cddl
COMID_FRAGS += tag-id-type-choice.cddl
COMID_FRAGS += tag-identity-map.cddl
COMID_FRAGS += tag-rel-type-choice.cddl
COMID_FRAGS += tag-version-type.cddl
COMID_FRAGS += tagged-int.cddl
COMID_FRAGS += triples-map.cddl
COMID_FRAGS += ueid.cddl
COMID_FRAGS += uuid.cddl
COMID_FRAGS += version-map.cddl
COMID_FRAGS += concise-swid-tag.cddl

COMID_EXAMPLES := $(wildcard examples/comid-*.diag)

$(eval $(call cddl_check_template,comid,$(COMID_FRAGS),$(COMID_EXAMPLES)))

CORIM_FRAGS := corim.cddl
CORIM_FRAGS += attest-key-triple-record.cddl
CORIM_FRAGS += class-id-type-choice.cddl
CORIM_FRAGS += class-map.cddl
CORIM_FRAGS += comid-entity-map.cddl
CORIM_FRAGS += comid-role-type-choice.cddl
CORIM_FRAGS += concise-mid-tag.cddl
CORIM_FRAGS += concise-tag-type-choice.cddl
CORIM_FRAGS += corim-entity-map.cddl
CORIM_FRAGS += corim-id-type-choice.cddl
CORIM_FRAGS += corim-locator-map.cddl
CORIM_FRAGS += corim-map.cddl
CORIM_FRAGS += corim-meta-map.cddl
CORIM_FRAGS += corim-role-type-choice.cddl
CORIM_FRAGS += corim-signer-map.cddl
CORIM_FRAGS += cose-label-and-value.cddl
CORIM_FRAGS += cose-sign1-corim.cddl
CORIM_FRAGS += coswid-triple-record.cddl
CORIM_FRAGS += crypto-key-type-choice.cddl
CORIM_FRAGS += domain-dependency-triple-record.cddl
CORIM_FRAGS += domain-membership-triple-record.cddl
CORIM_FRAGS += domain-type-choice.cddl
CORIM_FRAGS += endorsed-triple-record.cddl
CORIM_FRAGS += entity-map.cddl
CORIM_FRAGS += entity-name-type-choice.cddl
CORIM_FRAGS += environment-map.cddl
CORIM_FRAGS += flags-map.cddl
CORIM_FRAGS += group-id-type-choice.cddl
CORIM_FRAGS += identity-triple-record.cddl
CORIM_FRAGS += instance-id-type-choice.cddl
CORIM_FRAGS += ip-addr-type-choice.cddl
CORIM_FRAGS += linked-tag-map.cddl
CORIM_FRAGS += mac-addr-type-choice.cddl
CORIM_FRAGS += measured-element-type-choice.cddl
CORIM_FRAGS += measurement-map.cddl
CORIM_FRAGS += measurement-values-map.cddl
CORIM_FRAGS += non-empty.cddl
CORIM_FRAGS += oid.cddl
CORIM_FRAGS += profile-type-choice.cddl
CORIM_FRAGS += protected-corim-header-map.cddl
CORIM_FRAGS += raw-value.cddl
CORIM_FRAGS += reference-triple-record.cddl
CORIM_FRAGS += signed-corim.cddl
CORIM_FRAGS += svn-type-choice.cddl
CORIM_FRAGS += tag-id-type-choice.cddl
CORIM_FRAGS += tag-identity-map.cddl
CORIM_FRAGS += tag-rel-type-choice.cddl
CORIM_FRAGS += tag-version-type.cddl
CORIM_FRAGS += tagged-corim-map.cddl
CORIM_FRAGS += tagged-int.cddl
CORIM_FRAGS += triples-map.cddl
CORIM_FRAGS += ueid.cddl
CORIM_FRAGS += unprotected-corim-header-map.cddl
CORIM_FRAGS += uuid.cddl
CORIM_FRAGS += validity-map.cddl
CORIM_FRAGS += version-map.cddl
CORIM_FRAGS += concise-swid-tag.cddl

CORIM_EXAMPLES := $(wildcard examples/corim-*.diag)

$(eval $(call cddl_check_template,corim,$(CORIM_FRAGS),$(CORIM_EXAMPLES)))

GITHUB := https://raw.githubusercontent.com/
COSWID_REPO := sacmwg/draft-ietf-sacm-coswid/master
COSWID_REPO_URL := $(join $(GITHUB), $(COSWID_REPO))

concise-swid-tag.cddl: ; $(curl) -O $(COSWID_REPO_URL)/$@

CLEANFILES += concise-swid-tag.cddl

clean: ; $(RM) $(CLEANFILES)

# Extract the CBOR tags defined by CoRIM/CoMID (i.e., those in the 5xx space)
cbor-tags.txt: $(wildcard *.cddl) ; grep -h '#6\.5' *cddl | sort -u -t'=' -k2 > $@
