COMID_FRAGS := concise-mid-tag.cddl
COMID_FRAGS += accepted-claims-set.cddl
COMID_FRAGS += attest-key-triple-record.cddl
COMID_FRAGS += class-id-type-choice.cddl
COMID_FRAGS += class-map.cddl
COMID_FRAGS += comid-entity-map.cddl
COMID_FRAGS += comid-role-type-choice.cddl
COMID_FRAGS += conditional-endorsement-series-triple-record.cddl
COMID_FRAGS += conditional-series-record.cddl
COMID_FRAGS += cose-key.cddl
COMID_FRAGS += cose-label-and-value.cddl
COMID_FRAGS += coswid-triple-record.cddl
COMID_FRAGS += crypto-key-type-choice.cddl
COMID_FRAGS += domain-dependency-triple-record.cddl
COMID_FRAGS += domain-membership-triple-record.cddl
COMID_FRAGS += conditional-endorsement-triple-record.cddl
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
COMID_FRAGS += raw-value-compare.cddl
COMID_FRAGS += reference-triple-record.cddl
COMID_FRAGS += stateful-environment-record.cddl
COMID_FRAGS += svn-type-choice.cddl
COMID_FRAGS += tag-id-type-choice.cddl
COMID_FRAGS += tag-identity-map.cddl
COMID_FRAGS += tag-rel-type-choice.cddl
COMID_FRAGS += tag-version-type.cddl
COMID_FRAGS += tagged-bytes.cddl
COMID_FRAGS += triples-map.cddl
COMID_FRAGS += ueid.cddl
COMID_FRAGS += uuid.cddl
COMID_FRAGS += version-map.cddl
COMID_FRAGS += digest.cddl
COMID_FRAGS += integrity-registers.cddl
COMID_FRAGS += concise-swid-tag.cddl

COMID_EXAMPLES := $(wildcard examples/comid-*.diag)

CORIM_FRAGS := corim.cddl
CORIM_FRAGS += concise-bom-tag.cddl
CORIM_FRAGS += concise-tag-type-choice.cddl
CORIM_FRAGS += corim-entity-map.cddl
CORIM_FRAGS += corim-id-type-choice.cddl
CORIM_FRAGS += corim-locator-map.cddl
CORIM_FRAGS += corim-map.cddl
CORIM_FRAGS += corim-meta-map.cddl
CORIM_FRAGS += corim-role-type-choice.cddl
CORIM_FRAGS += corim-signer-map.cddl
CORIM_FRAGS += cose-sign1-corim.cddl
CORIM_FRAGS += profile-type-choice.cddl
CORIM_FRAGS += protected-corim-header-map.cddl
CORIM_FRAGS += signed-corim.cddl
CORIM_FRAGS += tagged-corim-map.cddl
CORIM_FRAGS += tagged-concise-rim-type-choice.cddl
CORIM_FRAGS += tagged-signed-corim.cddl
CORIM_FRAGS += tagged-concise-swid-tag.cddl
CORIM_FRAGS += tagged-concise-mid-tag.cddl
CORIM_FRAGS += tagged-concise-bom-tag.cddl
CORIM_FRAGS += unprotected-corim-header-map.cddl
CORIM_FRAGS += validity-map.cddl

CORIM_FRAGS += $(COMID_FRAGS)

CORIM_EXAMPLES := $(wildcard examples/corim-*.diag)

INTREP_FRAGS := intrep-start.cddl
INTREP_FRAGS += intrep-acs.cddl
INTREP_FRAGS += intrep-ae.cddl
INTREP_FRAGS += intrep-ar.cddl
INTREP_FRAGS += intrep-ars.cddl
INTREP_FRAGS += intrep-ect.cddl
INTREP_FRAGS += intrep-ev.cddl
INTREP_FRAGS += intrep-policy.cddl
INTREP_FRAGS += intrep-rv.cddl
INTREP_FRAGS += intrep-claims-map.cddl
INTREP_FRAGS += intrep-key.cddl
# deps
INTREP_FRAGS += non-empty.cddl
INTREP_FRAGS += environment-map.cddl
INTREP_FRAGS += class-map.cddl
INTREP_FRAGS += measurement-values-map.cddl
INTREP_FRAGS += version-map.cddl
INTREP_FRAGS += svn-type-choice.cddl
INTREP_FRAGS += digest.cddl
INTREP_FRAGS += flags-map.cddl
INTREP_FRAGS += raw-value.cddl
INTREP_FRAGS += tagged-bytes.cddl
INTREP_FRAGS += mac-addr-type-choice.cddl
INTREP_FRAGS += ip-addr-type-choice.cddl
INTREP_FRAGS += ueid.cddl
INTREP_FRAGS += uuid.cddl
INTREP_FRAGS += integrity-registers.cddl
INTREP_FRAGS += crypto-key-type-choice.cddl
INTREP_FRAGS += profile-type-choice.cddl
INTREP_FRAGS += cose-key.cddl
INTREP_FRAGS += cose-label-and-value.cddl
INTREP_FRAGS += class-id-type-choice.cddl
INTREP_FRAGS += oid.cddl

INTREP_EXAMPLES := $(wildcard examples/intrep-*.diag)
