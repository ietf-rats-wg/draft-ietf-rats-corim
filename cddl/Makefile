.DEFAULT_GOAL := check

SHELL := /bin/bash

include tools.mk
include check.mk
include corim-frags.mk

check:: cbor-tags-unique
check:: check-intrep-acs check-intrep-acs-examples
check:: check-intrep-rel check-intrep-rel-examples
check:: check-corim check-corim-examples
check:: check-comid check-comid-examples
check:: check-cotl check-cotl-examples

include measured-component.mk

$(eval $(call cddl_check_template,comid,$(COMID_FRAGS),$(COMID_EXAMPLES),$(COMID_IMPORTS)))
$(eval $(call cddl_check_template,cotl,$(COTL_FRAGS),$(COTL_EXAMPLES),$(COTL_IMPORTS)))
$(eval $(call cddl_check_template,corim,$(CORIM_FRAGS),$(CORIM_EXAMPLES),$(CORIM_IMPORTS)))
$(eval $(call cddl_check_template,intrep-acs,$(INTREP_ACS_FRAGS),$(INTREP_ACS_EXAMPLES),$(INTREP_ACS_IMPORTS)))
$(eval $(call cddl_check_template,intrep-rel,$(INTREP_REL_FRAGS),$(INTREP_REL_EXAMPLES),$(INTREP_REL_IMPORTS)))

clean: ; rm -f $(CLEANFILES)

# Extract the CBOR tags defined by CoRIM/CoMID (i.e., those in the 5xx space)
# The generated *-autogen.cddl files are excluded because they don't contribute
# any novel fragment.
CBOR_TAGS_SRC = $(filter-out %-autogen.cddl,$(wildcard *.cddl))
cbor-tags.txt: $(CBOR_TAGS_SRC)
	grep -h '#6\.5' $(CBOR_TAGS_SRC) | \
		awk '{ k = $$0; gsub(/[ \t]+/, "", k); if (!seen[k]++) print }' | \
		sort -u -t'=' -k2 > $@

# Return an error if there are duplicate CBOR Tags defined
cbor-tags-unique: cbor-tags.txt
	@echo -n "duplicated CBOR tag(s): "
	@if grep -E -h -o '#6\.[0-9]{3}' $< | uniq -d | grep . -c ; \
	then \
		echo "check the following:" ; \
		grep -E -h -o '#6\.[0-9]{3}' $< | uniq -d ; \
	fi
