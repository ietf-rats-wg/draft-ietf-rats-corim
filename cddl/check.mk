%.cbor: %.diag ; $(diag2cbor) $< > $@

# $1: label
# $2: cddl fragments
# $3: diag or json test files
# $4: imports (namespace=basename ...)
define cddl_check_template

check-$(1): $(1)-autogen.cddl
	$$(cddl) $$< g 1 | $$(diag2diag) -e

.PHONY: check-$(1)

$(1)-autogen.cddl: $(2) $(foreach i,$(4),$(lastword $(subst =, ,$(i)).cddl))
	$$(cddlc) $(foreach i,$(4),-I $(i)) -t cddl -2 $(2) > $$@

CLEANFILES += $(1)-autogen.cddl

check-$(1)-examples: $(1)-autogen.cddl $(3:.diag=.cbor)
	@for f in $(3:.diag=.cbor); do \
    echo ">> validating $$$$f against $$<" ; \
    $$(cddl) $$< validate $$$$f &>/dev/null || exit 1 ; \
  done

.PHONY: check-$(1)-examples

# Only clean up the example CBOR files generated from the EDN files; leave the
# JSON files alone.
CLEANFILES += $(patsubst %.diag,%.cbor,$(filter %.diag,$(3)))

endef # cddl_check_template
