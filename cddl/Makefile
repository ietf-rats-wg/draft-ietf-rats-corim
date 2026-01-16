.DEFAULT_GOAL := check

SHELL := /bin/bash

include tools.mk
include check.mk
include corim-frags.mk

check:: cbor-tags-unique
check:: check-intrep check-intrep-examples
check:: check-corim check-corim-examples
check:: check-comid check-comid-examples
check:: check-cotl check-cotl-examples

include measured-component.mk

$(eval $(call cddl_check_template,comid,$(COMID_FRAGS),$(COMID_EXAMPLES),$(COMID_IMPORTS)))
$(eval $(call cddl_check_template,cotl,$(COTL_FRAGS),$(COTL_EXAMPLES),$(COTL_IMPORTS)))
$(eval $(call cddl_check_template,corim,$(CORIM_FRAGS),$(CORIM_EXAMPLES),$(CORIM_IMPORTS)))
$(eval $(call cddl_check_template,intrep,$(INTREP_FRAGS),$(INTREP_EXAMPLES),$(INTREP_IMPORTS)))

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
