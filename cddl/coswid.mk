# CoSWID CDDL
github := https://raw.githubusercontent.com/
coswid_repo := sacmwg/draft-ietf-sacm-coswid/master
coswid_url := $(join $(github), $(coswid_repo))

concise-swid-tag.cddl: ; $(curl) -O $(coswid_url)/$@

CLEANFILES += concise-swid-tag.cddl
