#### The authorized-by field in Appraisal Claims Set {#sec-authorized-by}

The `a` field in an ECT in the ACS indicates the entity whose authority backs the claim.

An entity is authoritative when it makes Claims that are inside its area of
competence. The Verifier keeps track of the authorities that assert Claims so
that it can filter out claims from entities that do not satisfy appraisal
policies.

When adding an Evidence Claim to the ACS, the
Verifier SHALL set the `authorized-by` field in that Claim to the trusted
authority keys at the head of each key chain which signed that Evidence. This
key is often the subject of a self-signed certificate.
The Verifier has already verified the certificate chain.
See {{sec-crypto-validate-evidence}}.

If multiple authorities approve the same Claim, for example if multiple key chains
are available, then the `authorized-by` field SHALL be set to include the trusted
authority keys used by each of those authorities.

When adding Endorsement Claims to the ACS that resulted
from CoRIM processing ({{sec-add-to-acs}}) the Verifier SHALL set the
`authorized-by` field in that Evidence to the trusted authority key that is
at the head of the key chain that signed the CoRIM.

When searching the ACS for an entry which matches a Reference
Value containing an `authorized-by` field, the Verifier SHALL ignore ACS
entries if none of the keys present in the Reference Value `authorized-by` field
are also present in the ACS `authorized-by` field.

The Verifier SHOULD set the `authorized-by` field in ACS entries
to a format which contains only a key, for example the `tagged-cose-key-type`
format. Using a common format makes it easier to compare the field.