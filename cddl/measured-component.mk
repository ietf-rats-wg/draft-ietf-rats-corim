# EAT MC CDDL
github := https://github.com/ietf-rats-wg/
eat_mc_rel_dl := draft-ietf-rats-eat-measured-component/releases/download/
eat_mc_tag := cddl-draft-ietf-rats-eat-measured-component-10
eat_mc_url := $(join $(github), $(join $(eat_mc_rel_dl), $(eat_mc_tag)))

measured-component.cddl: ; $(curl) -LO $(eat_mc_url)/$@

CLEANFILES += measured-component.cddl
