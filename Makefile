LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif

include cddl/corim-frags.mk

define cddl_targets

$(drafts_xml): cddl/$(1)-autogen.cddl

cddl/$(1)-autogen.cddl: $(addprefix cddl/,$(2))
	$(MAKE) -C cddl check-$(1)
	$(MAKE) -C cddl check-$(1)-examples

endef # cddl_targets

$(eval $(call cddl_targets,corim,$(CORIM_FRAGS)))
$(eval $(call cddl_targets,comid,$(COMID_FRAGS)))
$(eval $(call cddl_targets,cotl,$(COTL_FRAGS)))
$(eval $(call cddl_targets,intrep,$(INTREP_FRAGS)))

cddl/concise-swid-tag.cddl: ; $(MAKE) -C cddl $(notdir $@)

clean:: ; $(MAKE) -C cddl clean
