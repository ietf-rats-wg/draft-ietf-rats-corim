---
v: 3

title: Concise Reference Integrity Manifest
abbrev: CoRIM
docname: draft-ietf-rats-corim-latest
category: std
consensus: true
submissiontype: IETF

ipr: trust200902
area: "Security"
workgroup: "Remote ATtestation ProcedureS"
keyword: RIM, RATS, attestation, verifier, supply chain

stand_alone: true
pi:
  toc: yes
  sortrefs: yes
  symrefs: yes
  tocdepth: 3

author:
- ins: H. Birkholz
  name: Henk Birkholz
  org: Fraunhofer SIT
  email: henk.birkholz@ietf.contact
- ins: T. Fossati
  name: Thomas Fossati
  organization: Linaro
  email: Thomas.Fossati@linaro.org
- ins: Y. Deshpande
  name: Yogesh Deshpande
  organization: arm
  email: yogesh.deshpande@arm.com
- ins: N. Smith
  name: Ned Smith
  org: Independent
  email: ned.smith.ietf@outlook.com
- ins: W. Pan
  name: Wei Pan
  org: Huawei Technologies
  email: william.panwei@huawei.com

contributor:
  - ins: C. Bormann
    name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org
    contribution: >
      Carsten Bormann contributed to the CDDL specifications and the IANA considerations.
  - ins: A. Draper
    name: Andrew Draper
    org: Altera
    email: andrew.draper@altera.com
    contribution: >
      Andrew contributed the concept, description, and semantics of conditional endorsements as well as consistent contribution to weekly reviews of others' edits.
  - ins: D. Glaze
    name: Dionna Glaze
    org: Google LLC
    email: dionnaglaze@google.com
    contribution: >
      Dionna contributed many clarifying questions and disambiguations to the semantics of attestation appraisal as well as consistent contribution to weekly reviews of others' edits.

normative:
  RFC9562: uuid
  RFC5280: pkix-cert
  RFC7468: pkix-text
  RFC8610: cddl
  RFC9090: cbor-oids
  RFC9164: cbor-ip
  STD96:
    -: cose
    =: RFC9052
  STD94:
    -: cbor
    =: RFC8949
  STD66:
    -: uri
    =: RFC3986
  RFC9393: coswid
  RFC9597: CWT_CLAIMS_COSE
  RFC8392: CWT
  RFC9711: eat
  I-D.ietf-rats-msg-wrap: cmw
  I-D.ietf-rats-eat-measured-component: eat-mc
  IANA.language-subtag-registry: language-subtag
  X.690: CCITT.X690.2002
  I-D.ietf-cose-hash-envelope: cose-hash-envelope

informative:
  RFC7519: jwt
  RFC7942:
  RFC9334: rats-arch
  I-D.fdb-rats-psa-endorsements: psa-endorsements
  I-D.ydb-rats-cca-endorsements: cca-endorsements
  RFC9783: psa-token
  I-D.ietf-rats-endorsements: rats-endorsements
  I-D.ietf-rats-evidence-trans: rats-evidence-trans
  DICE.Layer:
    title: DICE Layering Architecture
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.0, Revision 0.19
    date: July 2020
    target: https://trustedcomputinggroup.org/wp-content/uploads/DICE-Layering-Architecture-r19_pub.pdf
  IANA.coswid: coswid-reg
  I-D.ietf-rats-concise-ta-stores: ta-store
  DICE.cert:
    title: DICE Certificate Profiles
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.1
    date: April 2025
    target: https://trustedcomputinggroup.org/wp-content/uploads/DICE-Certificate-Profiles-v1.1_pub.pdf
  DICE.endorsement:
    title: DICE Endorsement Architecture for Devices
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.0, Revision 0.38
    date: November 2022
    target: https://trustedcomputinggroup.org/wp-content/uploads/TCG-Endorsement-Architecture-for-Devices-V1-R38_pub.pdf
  TNC.Arch:
    title: "TCG Trusted Network Connect TNC Architecture for Interoperability"
    author:
      org: Trusted Computing Group
    seriesinfo: Specification Version 1.1 Revision 2
    date: 1 May 2006
    target: https://trustedcomputinggroup.org/wp-content/uploads/TNC_Architecture_v1_1_r2.pdf
  TPM2.Part1:
    title: "Trusted Platform Module Library, Part 1: Architecture"
    author:
      org: Trusted Computing Group
    seriesinfo: Family "2.0", Level 00, Revision 01.83
    date: January 24, 2024,
    target: https://trustedcomputinggroup.org/resource/tpm-library-specification/
  IEEE-802.OandA: DOI.10.1109/IEEESTD.2014.6847097

entity:
  SELF: "RFCthis"

--- abstract

Remote Attestation Procedures (RATS) enable Relying Parties to assess the trustworthiness of a remote Attester and therefore to decide whether or not to engage in secure interactions with it.
Evidence about trustworthiness can be rather complex and it is deemed unrealistic that every Relying Party is capable of the appraisal of Evidence.
Therefore that burden is typically offloaded to a Verifier.
In order to conduct Evidence appraisal, a Verifier requires not only fresh Evidence from an Attester, but also trusted Endorsements and Reference Values from Endorsers and Reference Value Providers, such as manufacturers, distributors, or device owners.
This document specifies the information elements for representing Endorsements and Reference Values in CBOR format.

--- middle

# Introduction {#sec-intro}

The RATS Architecture {{Section 4 of -rats-arch}} specifies several roles, including Endorsers and Reference Value Providers.
These two roles are typically fulfilled by supply chain actors, such as manufacturers, distributors, or device owners.
Endorsers and Reference Value Providers supply Endorsements (e.g., test results or certification data) and Reference Values (e.g., digest ) relating to an Attester.
This information is used by a Verifier to appraise Evidence received from an Attester which describes Attester operational state.

In a complex supply chain, multiple actors will likely produce these values over several points in time.
As such, one supply chain actor might only supply a portion of the Reference Values or Endorsements that otherwise fully characterizes an Attester.
Ideally, only the supply chain actor who is the most knowledgeable entity regarding a particular component will supply Reference Values or Endorsements for that component.

Attesters vary across vendors and even across products from a single vendor.
Not only Attesters can evolve and therefore new measurement types need to be expressed, but an Endorser may also want to provide new security relevant attributes about an Attester at a future point in time.

In order to promote inter-operability, consistency and accuracy in the representation of Endorsements and Reference Values this document specifies a data model for Endorsements and Reference Values known as Concise Reference Integrity Manifests (CoRIM).
The CoRIM data model is expressed in CDDL which is used to realize a CBOR {{-cbor}} encoding suitable for cryptographic operations (e.g., hashing, signing, encryption) and transmission over computer networks.
Additionally, this document describes multiple phases of a Verifier Appraisal and provides an example of a possible use of CoRIM messages from multiple supply chain actors to represent a homogeneous representation of Attester state.
CoRIM is extensible to accommodate supply chain diversity while supporting a common representation for Endorsement and Reference Value inputs to Verifiers.
See {{sec-verifier-rec}}.


## Terminology and Requirements Language

{::boilerplate bcp14}

This document uses terms and concepts defined by the RATS architecture.
Specifically the terms Attester, Reference Value Provider, Endorser, Verifier Owner, and Relying Party are taken from {{Section 4 of -rats-arch}}.

For a complete glossary, see {{Section 4 of -rats-arch}}.

This document uses the terms _"actual state"_ and _"reference state"_ as defined in {{Section 2 of -rats-endorsements}}.

In this document, the term CoRIM message and CoRIM documents are used as synonyms. A CoRIM data structure can be at rest (e.g., residing in a file system as a document) or can be in flight (e.g., conveyed as a message in a protocol exchange). The bytes composing the CoRIM data structure are the same either way.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}. Terms and concepts are always referenced as proper nouns, i.e., with Capital Letters.

### Glossary {#sec-glossary}

This document uses the following terms:

{: vspace="0"}
Appraisal Claims Set (ACS):
: A structure that holds Environment-Claim Tuples that have been appraised.
The ACS contains Attester state that has been authorized by Verifier processing and Appraisal Policy.

Appraisal Policy:
: A description of the conditions that, if met, allow appraisal of Claims.
Typically, the entity asserting a Claim should have knowledge, expertise, or context that gives credibility to the assertion.
Appraisal Policy resolves which entities are credible and under what conditions.
See also "Appraisal Policy for Evidence" in {{-rats-arch}}.

Authority:
: The entity asserting that a Claim is true.
Typically, a Claim is asserted using a cryptographic key to digitally sign the Claim.
A cryptographic key can be a proxy for a human or organizational entity.

Claim:
: A piece of information, in the form of a key-value pair.
See also {{Section 4.2 of -rats-arch}} and {{Section 2 of -jwt}}.

Class ID:
: An identifier for an Environment that is shared among similar Environment instances, such as those with the same hardware assembly.
See also {{Section 4.2.4 of -eat}}.

Composite Attester:
: A Composite Attester is either a Composite Device ({{Section 3.3 of -rats-arch}}) or a Layered Attester ({{Section 3.2 of -rats-arch}}) or any composition involving a combination of one or more Composite Devices or Layered Attesters.

Domain:
: A domain is a hierarchical description of a Composite Attester in terms of its constituent Environments and their compositional relationships.

Endorsed values:
: A set of characteristics of an Attester that do not appear in Evidence.
For example, Endorsed Values may include testing or certification data related to a hardware or firmware module.
Endorsed Values are said to be "conditional" when they apply if Attester's actual state matches Verifier's accepted Claims.
See also {{Section 3 of -rats-endorsements}}.

Environment:
: A logical partition within an Attester.
The term "Target Environment" refers to the group of system security metrics that are reported through Evidence.
The term "Attesting Environment" refers to the entity that collects and cryptographically signs such security metrics.
See also {{Section 3.1 of -rats-arch}}.

Environment-Claim Tuple (ECT):
: A structure containing a set of values that describe a Target Environment plus a set of Measurement / Claim values that describe properties of the Target Environment.
The ECT also contains Authority which identifies the entity that authored the ECT.

Instance ID:
: An identifier of an Environment that is unique to that Environment instance, such as the serial number of a hardware module.
See also {{Section 4.2.1 of -eat}}.

Measurement:
: A value associated with specific security characteristics of an Attester that influences the trustworthiness of that Attester.
The object of a Measurement could be the invariant part of a firmware component loaded into memory during startup, a run-time integrity check (RTIC), a file system object, or a CPU register.
A measured object is part of the Attester's Target Environment.
Expected, or "golden," Measurements are compiled as Reference Values, which are used by the Verifier to assess the trust state of the Attester.
See also {{TNC.Arch}}, and Section 9.5.5 of {{TPM2.Part1}}.

Reference Values:
: A set of values that represent the desired or undesired state of an Attester.
Reference Values are compared against Evidence to determine whether Attester state is corroborated by a Reference Value Provider.
Reference Values with matching Evidence produce "acceptable Claims."
See also {{Section 4.2 of -rats-arch}}, {{Section 8.3 of -rats-arch}}, and {{Section 2 of -rats-endorsements}}.

Triple:
: A term derived from the Resource Description Framework (RDF) to mean a statement expressing a relationship between a subject and an object resource.
The nature of the relationship between subject and object is expressed via a predicate.
In CoRIM, unlike RDF, the predicate of the triple is implicit and is encoded in the triple's name/codepoint.
CoRIM triples typically represent assertions made by the CoRIM author regarding Attesting or Target Environments and their security features, such as Measurements and cryptographic key material.
See also Section 3.1 of {{?W3C.rdf11-primer}}.

# Verifier Reconciliation {#sec-verifier-rec}

This specification describes the CoRIM format and documents how a Verifier must process the CoRIM.
This ensures that the behaviour of the CoRIM-based appraisal is predictable and consistent, in a word deterministic.

A Verifier needs to reconcile its various inputs, with CoRIM being one of them.
In addition to the external CoRIM documents, the Verifier is expected to create an internal representation for each input and map each external representation to an internal one.
By using the internal representation, the Verifier processes inputs as if they are part of a conversation, keeping track of who said what.
The origin of the inputs is tracked as *authority*.
The authority for the Claims in a CoRIM is the CoRIM issuer.
To this effect, this specification defines one possible internal representation of the attester's actual state for use during the appraisal procedure, known as Appraisal Claims Set (ACS).

Effectively, Attesters, Reference Value Providers, Endorsers, Verifier Owners, Relying Parties, and even the Verifier potentially all contribute to the conversation.
Each producer of corresponding RATS Conceptual Messages can assert Claims about an Attester's actual or allowed state.
The Verifier's objective is to produce a list of Claims that describe the Attester's presumed actual state.
Producers of RATS Conceptual Messages can assert contradictory assertions.
For example, a compromised Attester may produce false claims that conflict with the Reference Values provided by a Reference Value Provider (RVP).
In essence, if Evidence is not corroborated by an RVP's Claims, then the RVP's Claims are not included in the ACS. Please see {{fig-verifier-internal}}.

A Verifier relies on input from appraisal policy to identify relevant assertions included in the ACS.
For example, if a policy requires corroborated assertions issued by a particular RVP, then those assertions may be conveyed as Attestation Results.
The Verifier may produce new assertions as a result of an applied appraisal policy.
For example, if an appraisal procedure finds all of the components of a subsystem are configured correctly, the policy may direct the Verifier to produce new assertions, "Subsystem=X" has the Claim "TRUSTED=TRUE".
Consequently, the internal ACS structure is a reconciled conversation between several producers of RATS Conceptual Messages that has mapped each message into a consistent internal representation, has associated the identity of the corresponding RATS role with each assertion (the authority), and has applied Conceptual Message constraints to the assertion.

The CoRIM data model specified in this document covers the RATS Conceptual Message types, "Reference Values" and "Endorsements".
Reference values and Endorsements are required for Verifier reconciliation, and Evidence is required for corresponding internal ACS creation as illustrated in {{sec-interact-acs}}.

## Internal Representation {#sec-internal-rep}

In this document CDDL is used to specify both the CoRIM structure and to specify an internal representation for use in the appraisal procedure.
The actual internal representation of a Verifier is implementation-specific and out-of-scope of this document.
Requirements for an internal representation of Conceptual Messages are defined in {{tbl-cmrr}}, where each Conceptual Message type has a structure as depicted by the *Structure* column.
The internal representations used by this document are defined in {{sec-ir}}.

## Interacting with an ACS {#sec-interact-acs}

Conceptual Messages interact with an ACS by specifying criteria that should be met by the ACS and by presenting the assertions that should be added to the ACS if the criteria are satisfied.
The processing sequence of Conceptual Message interaction with ACS is guided by {{sec-match-and-augment}}.

The internal representations of Conceptual Messages and ACS SHOULD satisfy the requirements in {{tbl-cmrr}} for Verifier reconciliation and appraisal processing:

| CM Type | Structure | Description |
|---
| Evidence | List of Evidence claims | If the Attester is authenticated, add Evidence claims to the ACS with Attester authority |
| Reference Values | List of Reference Values claims | If a reference value in a CoRIM matches claims in the ACS, then the authority of the CoRIM issuer is added to those claims. |
| Endorsements | List of expected actual state claims, List of Endorsed Values claims | If the list of expected claims are in the ACS, then add the list of Endorsed Values claims to the ACS with Endorser authority |
| Series Endorsements | List of expected actual state claims and a series of selection-addition tuples | If the expected claims are in the ACS, and if the series selection condition is satisfied, then add the additional claims to the ACS with Endorser authority. See {{sec-ir-endval}} |
{: #tbl-cmrr title="Conceptual Message Representation Requirements"}


# Typographical Conventions for CDDL {#sec-type-conv}

The CDDL definitions in this document follows the naming conventions illustrated in {{tbl-typography}}.

| Type trait | Example | Typographical convention |
|---
| extensible type choice | `int / text / ...` | `$`NAME`-type-choice` |
| closed type choice | `int / text` | NAME`-type-choice` |
| group choice | `( 1 => int // 2 => text )` | `$$`NAME`-group-choice` |
| group | `( 1 => int, 2 => text )` | NAME`-group` |
| type | `int` | NAME`-type`|
| tagged type | `#6.123(int)` | `tagged-`NAME`-type`|
| map | `{ 1 => int, 2 => text }` | NAME-`map` |
| flags | `&( a: 1, b: 2 )` | NAME-`flags` |
{: #tbl-typography title="Type Traits and Typographical Conventions"}

# Concise Reference Integrity Manifest (CoRIM) {#sec-corim}

A CoRIM is a collection of tags and related metadata in a concise CBOR {{-cbor}} encoding.
A CoRIM can be digitally signed with a COSE {{-cose}} signature.
A tag is a structured, machine-readable data format used to uniquely identify, describe, and manage modules or components of a system.

Tags can be of different types:

* Concise Module ID (CoMID) tags ({{sec-comid}}) contain metadata and claims about the hardware and firmware modules.

* Concise Software ID (CoSWID) tags ({{-coswid}}) are used to identify, describe and manage software components.

* Concise Tag List (CoTL) tags ({{sec-cotl}}) contain the list of CoMID and CoSWID tags that the Verifier should consider as "active" at a certain point in time.

CoRIM allows for new types of tags to be added in future specifications.
For example, Concise Trust Anchor Stores (CoTS) ({{-ta-store}}) is currently being defined as a standard CoRIM extension.

Each CoRIM contains a unique identifier to distinguish a CoRIM from other CoRIMs.

CoRIM can also carry the following optional metadata:

* A locator, which allows discovery of possibly related RIMs.

* A profile identifier, which is used to interpret the information contained in the enclosed tags.
A profile allows the base CoRIM CDDL definition to be customized to fit a specific Attester by augmenting the base CDDL data definition via the specified extension points or by constraining types defined.
A profile MUST NOT change the base CoRIM CDDL definition's semantics, which includes not changing or overloading names and numbers registered at IANA registries used by this document.
For more detail, see {{sec-corim-profile-types}}.

* A validity period, which indicates the time period for which the CoRIM contents are valid.

* Information about the supply chain entities responsible for the contents of the CoRIM and their associated roles.

A CoRIM can be signed ({{sec-corim-signed}}) using COSE Sign1 to provide end-to-end security to the CoRIM contents.
When CoRIM is signed, the protected header carries further identifying information about the CoRIM signer.
Alternatively, CoRIM can be encoded as a #6.501 CBOR-tagged payload ({{sec-corim-map}}) and transported over a secure channel.

The following CDDL describes the top-level CoRIM.

~~~ cddl
{::include cddl/corim.cddl}
~~~

See Sections 4 and 5 of {{DICE.endorsement}} for diagrams and additional information on CoRIM structure.

## CoRIM Map {#sec-corim-map}

The CDDL specification for the `corim-map` is as follows and this rule and its
constraints MUST be followed when creating or validating a CoRIM map.

~~~ cddl
{::include cddl/corim-map.cddl}
~~~

The following describes each child item of this map.

* `id` (index 0): A unique identifier to identify a CoRIM. Described
  in {{sec-corim-id}}.

* `tags` (index 1):  An array of one or more CoMID, CoSWID or CoTL tags.  Described
  in {{sec-corim-tags}}.

* `dependent-rims` (index 2): One or more services supplying additional,
  possibly dependent, manifests or related files.
  Described in {{sec-corim-locator-map}}.

* `profile` (index 3): An optional profile identifier for the tags contained in
  this CoRIM.  The profile MUST be understood by the CoRIM processor.  Failure
  to recognize the profile identifier MUST result in the rejection of the
  entire CoRIM.
  See {{sec-corim-profile-types}}

* `rim-validity` (index 4): Specifies the validity period of the CoRIM.
  Described in {{sec-common-validity}}.

* `entities` (index 5): A list of entities involved in a CoRIM life-cycle.
  Described in {{sec-corim-entity}}.

* `$$corim-map-extension`: This CDDL socket is used to add new information
  structures to the `corim-map`.
  Described in {{sec-iana-corim}}.

A `corim-map` is unsigned, and its tagged form is an entrypoint for parsing a CoRIM, so it is named `tagged-unsigned-corim-map`.

~~~ cddl
{::include cddl/tagged-unsigned-corim-map.cddl}
~~~

### CoRIM Identifier {#sec-corim-id}

A CoRIM Identifier uniquely identifies a CoRIM instance within the context of a CoRIM issuer.
In other words the CoRIM identifier can be used to distinguish CoRIMs that come from the same issuer.

The base CDDL definition allows UUID and text identifiers.
Other types of identifiers could be defined as needed.

~~~ cddl
{::include cddl/corim-id-type-choice.cddl}
~~~

### Tags {#sec-corim-tags}

A `$concise-tag-type-choice` is a tagged CBOR payload that carries either a
CoMID ({{sec-comid}}), a CoSWID ({{-coswid}}), or a CoTL ({{sec-cotl}}).

~~~ cddl
{::include cddl/concise-tag-type-choice.cddl}
~~~

### Locator Map {#sec-corim-locator-map}

The locator map contains pointers to repositories where dependent manifests,
certificates, or other relevant information can be retrieved by the Verifier.

~~~ cddl
{::include cddl/corim-locator-map.cddl}
~~~

The following describes each child element of this type.

* `href` (index 0): a URI or array of alternative URIs identifying locations where the additional resource can be fetched.

* `thumbprint` (index 1): expected digest or an array of digests referenced by `href` or an array of `href`s. See {{sec-common-hash-entry}}.

### Profile Types {#sec-corim-profile-types}

Profiling is the mechanism that allows the base CoRIM CDDL definition to be customized to fit a specific Attester.

A profile defines which of the optional parts of a CoRIM are required, which are prohibited and which extension points are exercised and how.
A profile MUST NOT alter the syntax or semantics of CoRIM types defined in this document.

A profile MAY constrain the values of a given CoRIM type to a subset of the values.
A profile MAY extend the set of a given CoRIM type using the defined extension points ({{sec-extensibility}}).
Exercised extension points SHOULD preserve the intent of the original semantics.

CoRIM profiles SHOULD be specified in a publicly available document.

A CoRIM profile can use one of the base CoRIM media type defined in {{sec-mt-rim-cbor}} with the `profile` parameter set to the appropriate value.
Alternatively, it MAY define and register its own media type.

A profile identifier is either an OID {{-cbor-oids}} or a URL {{-uri}}.

The profile identifier uniquely identifies a documented profile.  Any changes
to the profile, even the slightest deviation, is considered a different profile
that MUST have a different identifier.

The CoRIM profile must describe at a minimum the following:  (a) how cryptographic verification key material is represented (e.g., using Attestation Keys triples, or CoTS tags), and
(b) how key material is associated with the Attesting Environment.
The CoRIM profile should also specify whether CBOR deterministic encoding is required.

~~~ cddl
{::include cddl/profile-type-choice.cddl}
~~~

For an example profile definition, see {{-psa-endorsements}}.

### Entities {#sec-corim-entity}

The CoRIM Entity is an instantiation of the Entity generic ({{sec-common-entity}}) using a `$corim-role-type-choice`.

The only role defined in this specification for a CoRIM Entity is
`manifest-creator`.

The `$$corim-entity-map-extension` extension socket is empty in this
specification.

~~~ cddl
{::include cddl/corim-entity-map.cddl}

{::include cddl/corim-role-type-choice.cddl}
~~~

The `corim-entity-map` MUST NOT contain two entities with the `manifest-signer` role.

## Signed CoRIM {#sec-corim-signed}

~~~ cddl
{::include cddl/signed-corim.cddl}
~~~

Signing a CoRIM follows the procedures defined in CBOR Object Signing and
Encryption {{-cose}}. A CoRIM tag MUST be wrapped in a COSE_Sign1 structure.
The CoRIM MUST be signed by the CoRIM creator.

The following CDDL specification defines a restrictive subset of COSE header
parameters that MUST be used in the protected header alongside additional
information about the CoRIM encoded in a `corim-meta-map` ({{sec-corim-meta}}) or alternatively in a `CWT-Claims` ({{-CWT_CLAIMS_COSE}}).

~~~ cddl
{::include cddl/cose-sign1-corim.cddl}
~~~

The following describes each child element of this type.

* `protected`: A CBOR Encoded protected header which is protected by the COSE
  signature. Contains information as given by Protected Header Map below.

* `unprotected`: A COSE header that is not protected by COSE signature.

* `payload`: When the payload is signed directly, either a CBOR-encoded tagged CoRIM, or nil if it is detached.
  When the payload is signed indirectly, the digest of a CBOR-encoded tagged CoRIM.

* `signature`: A COSE signature block, as defined in {{Section 4 of -cose}}.

### Protected Header Map

~~~ cddl
{::include cddl/protected-corim-header-map.cddl}
~~~

The CoRIM protected header map uses some common COSE header parameters plus additional metadata.
Additional metadata can either be carried in a `CWT_Claims` (index: 15) parameter as defined by {{-CWT_CLAIMS_COSE}},
or in a `corim-meta` map as a legacy alternative, described in {{sec-corim-meta}}.

The following describes each child item of this map.

* `alg` (index 1): An integer that identifies a signature algorithm.

Either, when the payload is signed directly:

* `content-type` (index 3): A string that represents the "MIME Content type" carried in the CoRIM payload.

Or, when the payload is signed indirectly using a Hash Envelope ({{-cose-hash-envelope}}):

* `payload_hash_alg` (index 258): The hash algorithm used to produce the payload.

* `payload_preimage_content_type` (index 259): A string that represents the "MIME Content type" of the CoRIM document used as the pre-image of the payload.

* `payload_location` (index 260): An optional identifier enabling retrieval of the original resource (preimage) identified by the payload.

At least one of:

* `CWT-Claims` (index 15): A map that contains metadata associated with a signed CoRIM.
  Described in {{-CWT_CLAIMS_COSE}}.

* `corim-meta` (index 8): A map that contains metadata associated with a signed CoRIM.
  Described in {{sec-corim-meta}}.

Documents MAY include both `CWT-Claims` and `corim-meta`, in which case the signer MUST ensure that their contents are semantically identical: the `CWT-Claims` issuer (`iss`) MUST have the same value as `signer-name` in `corim-meta`, and the `nbf` and `exp` values in the `CWT-Claims` MUST match the `signature-validity` in `corim-meta`.

Additional data can be included in the COSE header map as per ({{Section 3 of -cose}}).

### CWT Claims {#cwt-claims}

The CWT Claims ({{-CWT_CLAIMS_COSE}}) map identifies the entity that created and signed the CoRIM.
This ensures the consumer is able to identify credentials used to authenticate its signer.
To avoid any possible ambiguity with the contents of the CoRIM tags, the CWT Claims map MUST NOT contain claims that have semantic overlap with the information contained in CoRIM tags.

The following describes each child item of this group.

* `iss` (index 1): Issuer or signer for the CoRIM, formerly `signer-name` or `signer-uri` in {{sec-corim-signer}}.

* `sub` (index 2): Optional - identifies the CoRIM document, equivalent to a string representation of $corim-id-type-choice

Additional data can be included in the CWT Claims, as per {{-CWT}}, such as:

* `exp` (index 4): Expiration time, formerly `signature-validity` in {{sec-common-validity}}.

* `nbf` (index 5): Not before time, formerly `signature-validity` in {{sec-common-validity}}.

### Meta Map {#sec-corim-meta}

The CoRIM meta map identifies the entity or entities that create and sign the CoRIM.
This ensures the consumer is able to identify credentials used to authenticate its signer.


~~~ cddl
{::include cddl/corim-meta-map.cddl}
~~~

The following describes each child item of this group.

* `signer` (index 0): Information about the entity that signs the CoRIM.
  Described in {{sec-corim-signer}}.

* `signature-validity` (index 1): Validity period for the CoRIM.
Described in {{sec-common-validity}}.

#### Signer Map {#sec-corim-signer}

~~~ cddl
{::include cddl/corim-signer-map.cddl}
~~~

* `signer-name` (index 0): Name of the organization that performs the signer
  role

* `signer-uri` (index 1): A URI identifying the same organization

* `$$corim-signer-map-extension`: Extension point for future expansion of the
Signer map.

### Unprotected CoRIM Header Map {#sec-corim-unprotected-header}

~~~ cddl
{::include cddl/unprotected-corim-header-map.cddl}
~~~

## Signer authority of securely conveyed unsigned CoRIM {#sec-conveyed-signer}

An unsigned (#6.501-tagged) CoRIM may be a payload in an enveloping signed document, {{-pkix-cert}} or it may be conveyed unsigned within the protection scope of a secure channel.
The CoRIM signer authority is taken from the authenticated credential (e.g., OAUTH token) of the entity that originates the CoRIM.
For example, this entity could be the sending peer in a secure channel.
A CoRIM role entry expressing the origin of the unsigned CoRIM (i.e., the enveloping signed document or the origin endpoint of the secure channel) via the `manifest-signer` role MUST be added to `corim-entity-map`.
If the authority cannot be expressed directly via the existing authority types, the receiver SHOULD establish a local authority in one of the supported authority formats (e.g., if an unsigned CoRIM is received over a secure channel where authentication is token- or password-based).
If it is impossible to assert the authority of the origin, the Verifier's appraisal policy MAY assert the Verifier’s authority as the CoRIM origin.

It is out of scope of this document to specify a method of delegating the signer role in the case that an unsigned CoRIM is conveyed through multiple secured links with different notions of authenticity without end-to-end integrity protection.

### CoRIM collections

Several CoRIMs may share the same signer (e.g., as collection payload in a different signed message) and use locally-resolvable references to each other, for example using a RATS Conceptual Message Wrapper (CMW) {{-cmw}}.
The Collection CMW type is similar to a profile in its way of restricting the shape of the CMW collection.
The Collection CMW type for a CoRIM collection SHALL be `tag:{{&SELF}}:corim`.

A COSE_Sign1-signed CoRIM Collection CMW has a similar requirement to a signed CoRIM.
The signing operation MUST include either a `CWT-Claims` or a `corim-meta` and MAY contain both, in the COSE_Sign1 `protected-header` parameter.
These metadata containers ensure that each CoRIM in the collection has an identified signer.
The COSE protected header can include a Collection CMW type name by using the `cmwc_t` content type parameter for the `&(content-type: 3)` COSE header, or `&(payload_preimage_content_type: 259)` in the case of hash envelopes.

If using other signing envelope formats, ({{sec-conveyed-signer}}) the CoRIM signing authority MUST be specified. For example, this can be accomplished by adding the `manifest-signer` role to every CoRIM, or by using a protected header analogous to `corim-meta`.

~~~ cddl
{::include cddl/cmw-corim-collection.cddl}
~~~

The Collection CMW MAY use any label for its CoRIMs.
If there is a hierarchical structure to the CoRIM Collection CMW, the base entry point SHOULD be labeled `0` in CBOR or `"base"` in JSON.
It is RECOMMENDED to label a CoRIM with its tag-id in string format, where `uuid-type` string format is specified by {{-uuid}}.
CoRIMs distributed in a CoRIM Collection CMW MAY declare their interdependence `dependent-rims` with local resource indicators.
It is RECOMMENDED that a CoRIM with a `uuid-type` tag-id be referenced with URI `urn:uuid:`_tag-id-uuid-string_.
It is RECOMMENDED that a CoRIM with a `tstr` tag-id be referenced with `tag:{{&SELF}}:local,`_tag-id-tstr_.
It is RECOMMENDED for a `corim-locator-map` containing local URIs to afterwards list a nonzero number of reachable URLs as remote references.

The following example demonstrates these recommendations for bundling CoRIMs with a common signer but have different profiles.

~~~cbor-diag
{::include-fold cddl/examples/cmw-corim-collection.diag}
~~~

# Concise Module Identifier (CoMID) {#sec-comid}

A CoMID tag contains information about hardware, firmware, or module composition.

Each CoMID has a unique ID that is used to unambiguously identify CoMID instances when cross referencing CoMID tags, for example in typed link relations, or in a CoTL tag.

A CoMID defines several types of Claims, using "triples" semantics.

At a high level, a triple is a statement that links a subject to an object via a predicate.
CoMID triples typically encode assertions made by the CoRIM author about Attesting or Target Environments and their security features, for example measurements, cryptographic key material, etc.

This specification defines two classes of triples, the Mandatory To Implement (MTI) and the Optional To Implement (OTI).
The MTI triples are essential to basic appraisal processing as illustrated in {{-rats-arch}} and {{-rats-endorsements}}.
Every CoRIM Verifier MUST implement the MTI triples.
The OTI class of triples are generally useful across profiles.
A CoRIM Verifier SHOULD implement OTI triples.
Verifiers may be constrained in various ways that may make implementation of the OTI class infeasible or unnecessary.
For example, deployment environments may have constrained resources, limited code size, or limited scope Attesters.

MTI Triples:

* Reference Values triples: containing Reference Values that are expected to match Evidence for a given Target Environment ({{sec-comid-triple-refval}}).
* Endorsed Values triples: containing "Endorsed Values", i.e., features about an Environment that do not appear in Evidence. Specific examples include testing or certification data pertaining to a module ({{sec-comid-triple-endval}}).
* Conditional Endorsement triples: describing one or more conditions that, once matched, result in augmenting the Attester's actual state with the supplied Endorsed Values ({{sec-comid-triple-cond-endors}}).

OTI Triples:

* Conditional Endorsement Series triples: describing conditional endorsements that are evaluated using a special matching algorithm ({{sec-comid-triple-cond-endors}}).
* Device Identity triples: containing cryptographic credentials - for example, an IDevID - uniquely identifying a device ({{sec-comid-triple-identity}}).
* Attestation Key triples: containing cryptographic keys that are used to verify the integrity protection on the Evidence received from the Attester ({{sec-comid-triple-attest-key}}).
* Domain dependency triples: describing trust relationships between domains, i.e., collection of related environments and their measurements ({{sec-comid-triple-domain-dependency}}).
* Domain membership triples: describing topological relationships between (sub-)modules. For example, in a composite Attester comprising multiple sub-Attesters (sub-modules), this triple can be used to define the topological relationship between lead- and sub- Attester environments ({{sec-comid-triple-domain-membership}}).
* CoMID-CoSWID linking triples: associating a Target Environment with existing CoSWID Payload tags ({{sec-comid-triple-coswid}}).

CoMID triples are extensible ({{sec-comid-triples}}).
Triples added via the extensibility feature MUST be OTI class triples.
This document specifies profiles (see {{sec-extensibility}}).
OTI triples MAY be reclassified as MTI using a profile.
Conversely, profiles can choose not to _use_ certain MTI triples.
Profiles MUST NOT reclassify MTI triples as OTI.

## Structure

The CDDL specification for the `concise-mid-tag` map is as follows and this
rule and its constraints MUST be followed when creating or validating a CoMID
tag:

~~~ cddl
{::include cddl/concise-mid-tag.cddl}
~~~

The following describes each member of the `concise-mid-tag` map.

* `lang` (index 0): A textual language tag that conforms with IANA "Language
  Subtag Registry" {{-language-subtag}}. The context of the specified language
  applies to all sibling and descendant textual values, unless a descendant
  object has defined a different language tag. Thus, a new context is
  established when a descendant object redefines a new language tag.  All
  textual values within a given context MUST be considered expressed in the
  specified language.

* `tag-identity` (index 1): A `tag-identity-map` containing unique
  identification information for the CoMID.
  Described in {{sec-comid-tag-id}}.

* `entities` (index 2): Provides information about one or more organizations
  responsible for producing the CoMID tag.
  Described in {{sec-comid-entity}}.

* `linked-tags` (index 3): A list of one or more `linked-tag-map` providing typed relationships between this and
  other CoMIDs.
  Described in {{sec-comid-linked-tag}}).

* `triples` (index 4): One or more triples providing information specific to
  the described module, e.g.: reference or endorsed values, cryptographic
  material, or structural relationship between the described module and other
  modules.
  Described in {{sec-comid-triples}}.

### Tag Identity {#sec-comid-tag-id}

~~~ cddl
{::include cddl/tag-identity-map.cddl}
~~~

The following describes each member of the `tag-identity-map`.

* `tag-id` (index 0): A universally unique identifier for the CoMID.
  Described in {{sec-tag-id}}.

* `tag-version` (index 1): Optional versioning information for the `tag-id`.
  Described in {{sec-tag-version}}.

#### Tag ID {#sec-tag-id}

~~~ cddl
{::include cddl/tag-id-type-choice.cddl}
~~~

A Tag ID is either a 16-byte binary string, or a textual identifier, uniquely
referencing the CoMID. The tag identifier MUST be globally unique. Failure to
ensure global uniqueness can create ambiguity in tag use since the tag-id
serves as the global key for matching, lookups and linking. If represented as a
16-byte binary string, the identifier MUST be a valid universally unique
identifier as defined by {{-uuid}}. There are no strict guidelines on how the
identifier is structured, but examples include a 16-byte GUID (e.g., class 4
UUID) {{-uuid}}, or a URI {{-uri}}.

#### Tag Version {#sec-tag-version}

~~~ cddl
{::include cddl/tag-version-type.cddl}
~~~

Tag Version is an integer value that indicates the specific release revision of
the tag.  Typically, the initial value of this field is set to 0 and the value
is increased for subsequent tags produced for the same module release.  This
value allows a CoMID tag producer to correct an incorrect tag previously
released without indicating a change to the underlying module the tag
represents. For example, the tag version could be changed to add new metadata,
to correct a broken link, to add a missing reference value, etc. When producing
a revised tag, the new tag-version value MUST be greater than the old
tag-version value.

### Entities {#sec-comid-entity}

~~~ cddl
{::include cddl/comid-entity-map.cddl}
~~~

The CoMID Entity is an instantiation of `entity-map` ({{sec-common-entity}}) using a `$comid-role-type-choice`.

The `$$comid-entity-map-extension` extension socket is empty in this
specification.

~~~ cddl
{::include cddl/comid-role-type-choice.cddl}
~~~

The roles defined for a CoMID entity are:

* `tag-creator` (value 0): creator of the CoMID tag.

* `creator` (value 1): original maker of the module described by the CoMID tag.

* `maintainer` (value 2): an entity making changes to the module described by the CoMID tag.

### Linked Tag {#sec-comid-linked-tag}

The linked tag map represents a typed relationship between the embedding CoMID
tag (the source) and another CoMID tag (the target).

~~~ cddl
{::include cddl/linked-tag-map.cddl}
~~~

The following describes each member of the `tag-identity-map`.

* `linked-tag-id` (index 0): Unique identifier for the target tag.
  See {{sec-tag-id}}.

* `tag-rel` (index 1): the kind of relation linking the source tag to the
  target identified by `linked-tag-id`.

~~~ cddl
{::include cddl/tag-rel-type-choice.cddl}
~~~

The relations defined in this specification are:

* `supplements` (value 0): the source tag provides additional information about
  the module described in the target tag.

* `replaces` (value 1): the source tag corrects erroneous information
  contained in the target tag.  The information in the target MUST be
  disregarded.

### Triples {#sec-comid-triples}

The `triples-map` contains all the CoMID triples broken down per category.  Not
all category need to be present but at least one category MUST be present and
contain at least one entry.

In most cases, the supply chain entity that is responsible for providing a triple (i.e., Reference Values or Endorsed Values) is by default the CoRIM signer.
The signer of a triple is said to be its *authority*.
However, multiple authorities may be involved in signing triples.
See {{-cose}}.
Consequently, authority may differ for search criteria.
See {{sec-measurements}}.

~~~ cddl
{::include cddl/triples-map.cddl}
~~~

The following describes each member of the `triples-map`:

* `reference-triples` (index 0): Triples containing reference values.
  Described in {{sec-comid-triple-refval}}.

* `endorsed-triples` (index 1): Triples containing endorsed values.
  Described in {{sec-comid-triple-endval}}.

* `identity-triples` (index 2): Triples containing identity credentials.
  Described in {{sec-comid-triple-identity}}.

* `attest-key-triples` (index 3): Triples containing verification keys associated with attesting environments.
  Described in {{sec-comid-triple-attest-key}}.

* `dependency-triples` (index 4): Triples describing trust relationships between domains.
  Described in {{sec-comid-triple-domain-dependency}}.

* `membership-triples` (index 5): Triples describing topological relationships between (sub-)modules.
  Described in {{sec-comid-triple-domain-membership}}.

* `coswid-triples` (index 6): Triples associating modules with existing CoSWID tags.
  Described in {{sec-comid-triple-coswid}}.

* `conditional-endorsement-series-triples` (index 8): Triples describing a series of Endorsements that are applicable based on the acceptance of a condition.
  Described in {{sec-comid-triple-cond-series}}.

* `conditional-endorsement-triples` (index 10): Triples describing a series of conditional Endorsements based on the acceptance of a stateful environment.
  Described in {{sec-comid-triple-cond-endors}}.

#### Environments {#sec-environments}

An `environment-map` may be used to represent a whole Attester, an Attesting
Environment, or a Target Environment.  The exact semantic depends on the
context (triple) in which the environment is used.

An environment is named after a class, instance or group identifier (or a
combination thereof).

An environment MUST be globally unique.
The combination of values within `class-map` MUST combine to form a globally unique identifier.

~~~ cddl
{::include cddl/environment-map.cddl}
~~~

The following describes each member of the `environment-map`:

* `class` (index 0): Contains "class" attributes associated with the module.
  Described in {{sec-comid-class}}.

* `instance` (index 1): Contains a unique identifier of a module's instance.
  Described in {{sec-comid-instance}}.

* `group` (index 2): identifier for a group of instances, e.g., if an
  anonymization scheme is used.
  Described in {{sec-comid-group}}.

#### Environment Class {#sec-comid-class}

The Class name consists of class attributes that distinguish the class of
environment from other classes. The class attributes include class-id, vendor,
model, layer, and index. The CoMID author determines which attributes are
needed.

~~~ cddl
{::include cddl/class-map.cddl}

{::include cddl/class-id-type-choice.cddl}
~~~

The following describes each member of the `class-map`:

* `class-id` (index 0): Identifies the environment via a well-known identifier.
  Typically, `class-id` is an object identifier (OID) variable-length opaque byte string ({{sec-common-tagged-bytes}}) or universally unique identifier (UUID).
  Use of this attribute is preferred.

* `vendor` (index 1): Identifies the entity responsible for choosing values for
  the other class attributes that do not already have naming authority.

* `model` (index 2): Describes a product, generation, and family.  If
  populated, vendor MUST also be populated.

* `layer` (index 3): Is used to capture where in a sequence the environment
  exists. For example, the order in which bootstrap code is executed may have
  security relevance.

* `index` (index 4): Is used when there are clones (i.e., multiple instances)
  of the same class of environment.  Each clone is given a different index
  value to disambiguate it from the other clones. For example, given a chassis
  with several network interface controllers (NIC), each NIC can be given a
  different index value.

#### Environment Instance {#sec-comid-instance}

An `instance-id` is a unique value that identifies a Target Environment instance.
The identifier is reliably bound to the Target Environment.
For example, if an X.509 certificate's subject public key is unique for each instance of a target environment, the `instance-id` might be created from that subject public key.
See {{Section 4.1 of -pkix-cert}}.
Alternatively, if the certificate's subject public key is large, the `instance-id` might be a key identifier that is a digest of that public key.
See {{Section 4.2.1.2 of -pkix-cert}}.
The key identifier is reliably bound to the subject public key because the identifier is a digest of the key.

The types defined for an instance identifier are CBOR tagged expressions of
UEID, UUID, variable-length opaque byte string ({{sec-common-tagged-bytes}}), cryptographic keys, or cryptographic key identifiers.

~~~ cddl
{::include cddl/instance-id-type-choice.cddl}
~~~

#### Environment Group {#sec-comid-group}

A group carries a unique identifier that is reliably bound to a group of
Attesters, for example when a number of Attester are hidden in the same
anonymity set.

The types defined for a group identifier are UUID and variable-length opaque byte string ({{sec-common-tagged-bytes}}).

~~~ cddl
{::include cddl/group-id-type-choice.cddl}
~~~

#### Measurements {#sec-measurements}

Measurements can be of a variety of things including software, firmware,
configuration files, read-only memory, fuses, IO ring configuration, partial
reconfiguration regions, etc. Measurements comprise raw values, digests, or
status information.

An environment has one or more measurable elements. Each element can have a
dedicated measurement or multiple elements could be combined into a single
measurement. Measurements can have class, instance or group scope.  This is
typically determined by the triple's environment.

Class measurements apply generally to all the Attesters in a given class.

Instance measurements apply to a specific Attester instance.  Environments
identified by a class identifier have measurements that are common to the
class. Environments identified by an instance identifier have measurements that
are specific to that instance.

An environment may have multiple measured elements.
Measured elements are distinguished from each other by measurement keys.
Measurement keys may be used to disambiguate measurements of the same type originating from different elements.

Triples that have search conditions may specify authority as matching criteria by populating `authorized-by`.

~~~ cddl
{::include cddl/measurement-map.cddl}
~~~

The following describes each member of the `measurement-map`:

* `mkey` (index 0): An optional measurement key.
 Described in {{sec-comid-mkey}}.
 A `measurement-map` without an `mkey` is said to be anonymous.

* `mval` (index 1): The measurements associated with the environment.
 Described in {{sec-comid-mval}}.

* `authorized-by` (index 2): The cryptographic identity of the entity (individual or organization) that is
 the designated authority for measurement Claims.
 For example, the signer of a CoMID triple.
 See {{sec-crypto-keys}}.
 An entity is authoritative when it makes Claims that are inside its area of
competence.

##### Measurement Keys {#sec-comid-mkey}

A Measurement Key is an identifier for a measured element.
It can be used to identify the type of measured element (see {{-cca-endorsements}}) or to identify
multiple measured element instances within the same environment.
The initial types defined are OID, UUID, uint, and tstr.

A single anonymous `measurement-map` is allowed within the same environment.
Two or more measurement-map entries within the same environment MUST populate `mkey`.

~~~ cddl
{::include cddl/measured-element-type-choice.cddl}
~~~

##### Measurement Values {#sec-comid-mval}

A `measurement-values-map` contains measurements associated with a certain
environment. Depending on the context (triple) in which they are found,
elements in a `measurement-values-map` can represent class or instance
measurements. Note that some of the elements have instance scope only.

Measurement values may support use cases beyond Verifier appraisal.
Typically, a Relying Party determines if additional processing is desirable
and whether the processing is applied by the Verifier or the Relying Party.

~~~ cddl
{::include cddl/measurement-values-map.cddl}
~~~

The following describes each member of the `measurement-values-map`.

* `version` (index 0): Typically changes whenever the measured environment is updated.
  Described in {{sec-comid-version}}.

* `svn` (index 1): The security version number typically changes only when a security relevant change is made to the measured environment.
  Described in {{sec-comid-svn}}.

* `digests` (index 2): Contains the digest(s) of the measured environment
  together with the respective hash algorithm used in the process.
  It uses the `digests-type`.
  Described in {{sec-common-hash-entry}}.

* `flags` (index 3): Describes security relevant operational modes.
  For example, whether the environment is in a debug mode, recovery mode, not fully
  configured, not secure, not replay protected or not integrity protected.
  The `flags` field indicates which operational modes are currently associated with measured environment.
  Described in {{sec-comid-flags}}.

* `raw-value` (index 4): Contains the actual (not hashed) value of the element.
  The vendor determines the encoding of `raw-value`.
  When used for comparison, the `tagged-masked-raw-value` variant includes a mask indicating which bits in the value to compare.
  Described in {{sec-comid-raw-value-types}}

* `raw-value-mask-DEPRECATED` (index 5): Is an obsolete method of indicating which bits in a raw value to compare. New CoMID files should use the `tagged-masked-raw-value` on index 4 instead of using index 5.

* `mac-addr` (index 6): An EUI-48 (Extended Unique Identifier 48) or EUI-64 MAC address {{IEEE-802.OandA}} associated with the measured environment.
  Described in {{sec-comid-address-types}}.

* `ip-addr` (index 7): An IPv4 or IPv6 address associated with the measured environment.
  Described in {{sec-comid-address-types}}.

* `serial-number` (index 8): A text string representing the product serial number.

* `ueid` (index 9): UEID associated with the measured environment.
  Described in {{sec-common-ueid}}.

* `uuid` (index 10): UUID associated with the measured environment.
  Described in {{sec-common-uuid}}.

* `name` (index 11): a name associated with the measured environment.

* `cryptokeys` (index 13): identifies cryptographic keys that are protected by the Target Environment
  See {{sec-crypto-keys}} for the supported formats.
  An Attesting Environment determines that keys are protected as part of Claims collection.
  Appraisal verifies that, for each value in `cryptokeys`, there is a matching Reference Value entry.
  Matching is described in {{sec-cryptokeys-matching}}.

* `integrity-registers` (index 14): A group of one or more named measurements associated with the environment.  Described in {{sec-comid-integrity-registers}}.

##### Version {#sec-comid-version}

A `version-map` contains details about the versioning of a measured
environment.

~~~ cddl
{::include cddl/version-map.cddl}
~~~

The following describes each member of the `version-map`:

* `version` (index 0): the version string

* `version-scheme` (index 1): an optional indicator of the versioning
  convention used in the `version` attribute.
  Defined in {{Section 4.1 of -coswid}}.
  The CDDL is copied below for convenience.

~~~ cddl
$version-scheme /= &(multipartnumeric: 1)
$version-scheme /= &(multipartnumeric-suffix: 2)
$version-scheme /= &(alphanumeric: 3)
$version-scheme /= &(decimal: 4)
$version-scheme /= &(semver: 16384)
$version-scheme /= int / text
~~~

##### Security Version Number {#sec-comid-svn}

The following details the security version number (`svn`) and the minimum security version number (`min-svn`) statements.
A security version number is used to track changes to an object (e.g., a secure enclave, a boot loader executable, a configuration file, etc.) that are security relevant.
Rollback of a security relevant change is considered to be an attack vector; as such, security version numbers cannot be decremented.
If a security relevant flaw is discovered in the Target Environment and is subsequently fixed, the `svn` value is typically incremented.

There may be several revisions to a Target Environment that are in use at the same time.
If there are multiple revisions with different `svn` values, the revision with a lower `svn` value may
or may not be in a security critical condition. The Endorser may provide a minimum security version number
using `min-svn` to specify the lowest `svn` value that is acceptable.
`svn` values that are equal to or greater than `min-svn` do not signal a security critical condition.
`svn` values that are below `min-svn` are in a security critical condition that is unsafe for normal use.

The `svn-type-choice` measurement consists of a `tagged-svn` or `tagged-min-svn` value.
The `tagged-svn` and `tagged-min-svn` tags are CBOR tags with the values `#6.552` and `#6.553` respectively.

~~~ cddl
{::include cddl/svn-type-choice.cddl}
~~~

##### Flags {#sec-comid-flags}

The `flags-map` measurement describes a number of boolean operational modes.
If a `flags-map` value is not specified, then the operational mode is unknown.
Note that, while the fields may not be completely independent of one another, this specification imposes no restrictions on combinations of the `flags-map` booleans.
However, a profile may restrict the possible `flags-map` booleans and their valid combinations.

~~~ cddl
{::include cddl/flags-map.cddl}
~~~

The following describes each member of the `flags-map`:

* `is-configured` (index 0): If the flag is true, the measured environment is fully configured for normal operation.

* `is-secure` (index 1): If the flag is true, the measured environment's configurable
security settings are fully enabled.

* `is-recovery` (index 2): If the flag is true, the measured environment is in recovery
mode.

* `is-debug` (index 3): If the flag is true, the measured environment is in a debug enabled
mode.

* `is-replay-protected` (index 4): If the flag is true, the measured environment is
protected from rollback to previous software images.

* `is-integrity-protected` (index 5): If the flag is true, the measured environment is
protected from unauthorized update.

* `is-runtime-meas` (index 6): If the flag is true, the measured environment is measured
after being loaded into memory.

* `is-immutable` (index 7): If the flag is true, the measured environment is immutable.

* `is-tcb` (index 8): If the flag is true, the measured environment is a trusted
computing base.

* `is-confidentiality-protected` (index 9): If the flag is true, the measured environment
is confidentiality protected. For example, if the measured environment consists of memory,
the sensitive values in memory are encrypted.

##### Raw Values Types {#sec-comid-raw-value-types}

Raw value measurements are typically vendor defined values that are checked by Verifiers
for consistency only, since the security relevance is opaque to Verifiers. A profile may choose
to define more specific semantic meaning to a raw value.

A `raw-value` measurement, or an Endorsement, is a tagged value of type `bytes`.
This specification defines tag #6.560.
The default raw value measurement is of type `tagged-bytes` ({{sec-common-tagged-bytes}}).

Additional value types can be added to `$raw-value-type-choice`. These additional values MUST be CBOR tagged `bstr`s.
Constraining all raw value types to be `bstr` lets Verifiers compare raw values without understanding their contents.

A raw value intended for comparison can include a mask value, which selects the bits to compare during appraisal.
The mask is applied by the Verifier as part of appraisal.
Only the raw value bits with corresponding TRUE mask bits are compared during appraisal.

The `raw-value-mask-DEPRECATED` in `measurement-values-map` is deprecated, but retained for backwards compatibility.
This code point may be removed in a future revision of this specification.

~~~ cddl
{::include cddl/raw-value.cddl}
{::include cddl/tagged-masked-raw-value.cddl}
~~~

##### Address Types {#sec-comid-address-types}

This specification defines types for 48-bit and 64-bit MAC identifiers.
For IP addresses, it reuses the "Address Format" types defined in {{-cbor-ip}} with the CBOR tag removed.

All the types represent a single address.

~~~ cddl
{::include cddl/mac-addr-type-choice.cddl}

{::include cddl/ip-addr-type-choice.cddl}
~~~

#### Crypto Keys {#sec-crypto-keys}

A cryptographic key can be one of the following formats:

* `tagged-pkix-base64-key-type`: PEM encoded SubjectPublicKeyInfo.
  Defined in {{Section 13 of -pkix-text}}.

* `tagged-pkix-base64-cert-type`: PEM encoded X.509 public key certificate.
  Defined in {{Section 5 of -pkix-text}}.

* `tagged-pkix-base64-cert-path-type`: X.509 certificate chain created by the
  concatenation of as many PEM encoded X.509 certificates as needed.  The
  certificates MUST be concatenated in order so that each directly certifies
  the one preceding.

* `tagged-cose-key-type`: CBOR encoded COSE_Key or COSE_KeySet.
  Defined in {{Section 7 of -cose}}.

* `tagged-pkix-asn1der-cert-type`: a `bstr` of ASN.1 DER encoded X.509 public key certificate.
  Defined in {{Section 4 of -pkix-cert}}.

A cryptographic key digest can be one of the following formats:

* `tagged-key-thumbprint-type`: a `digest` (e.g., the SHA-2 hash) of a raw public key.
For example, the digest value can be used to locate a public key contained in a lookup table.
Ultimately, the discovered keys have to be successfully byte-by-byte compared with the corresponding keys.

* `tagged-cert-thumbprint-type`: a `digest` of a certificate.
  The digest value may be used to find the certificate if contained in a lookup table.

* `tagged-cert-path-thumbprint-type`: a `digest` of a certification path.
  The digest value may be used to find the certificate path if contained in a lookup table.

* `tagged-bytes`: a key identifier with no prescribed construction method.

~~~ cddl
{::include cddl/crypto-key-type-choice.cddl}
~~~

#### Integrity Registers {#sec-comid-integrity-registers}

An Integrity Registers map groups together one or more measured "objects".
Each measured object has a unique identifier and one or more associated digests.
Identifiers are either unsigned integers or text strings and their type matters, e.g., unsigned integer 5 is distinct from the text string "5".
The digests use `digests-type` semantics ({{sec-common-hash-entry}}).

~~~ cddl
{::include cddl/integrity-registers.cddl}
~~~

All the measured objects in an Integrity Registers map are explicitly named and the order in which they appear in the map is irrelevant.
Any digests associated with a measured object represent an acceptable state for the object.
Therefore, if multiple digests are provided, the acceptable state is their cross-product.
For example, given the following Integrity Registers:

~~~cbor-diag
{
  0: [ [ 0, h'00' ] ],
  1: [ [ 0, h'11' ], [ 1, h'12' ] ]
}
~~~

then both

~~~ cbor-diag
{
  0: [ 0, h'00' ],
  1: [ 0, h'11' ]
}
~~~

and

~~~cbor-diag
{
  0: [ 0, h'00' ],
  1: [ 1, h'12' ]
}
~~~

are acceptable states.

Integrity Registers can be used to model the PCRs in a TPM or vTPM, in which case the identifier is the register index, or other kinds of vendor-specific measured objects.


#### Int Range {#sec-comid-int-range}

An int range describes an integer value that can be compared with linear order in the target environment.
An int range is represented with either major type 0 or major type 1 ints.

~~~ cddl
{::include cddl/int-range-type-choice.cddl}
~~~

The signed integer range representation is an inclusive range unless either `min` or `max` are infinite as represented by `null`, in which case, each infinity is necessarily exclusive.

### Reference Values Triple {#sec-comid-triple-refval}

Reference Values Triples describe the possible intended states of an Attester.
At any given point in time, an Attester is expected to match only one of these states.

A Reference Values Triple provides reference values pertaining to a Target Environment.
In a Reference Value triple, the subject identifies a Target Environment, the object contains reference measurements associated with one or more measured elements of the Environment, and the predicate asserts that these represent the expected state of the Target Environment.

The Reference Values Triple has the following structure:

~~~ cddl
{::include cddl/reference-triple-record.cddl}
~~~
{: #triple-rv title="Reference Values Triple Definition"}

The `reference-triple-record` has the following parameters:

* `ref-env`: Identifies the Target Environment
* `ref-claims`: Contains one or more reference measurements for the Target Environment

CoMID triples ({{sec-comid-triples}}) may contain multiple `reference-triple-record` entries, each of which describes one or more possible states for a particular Target Environment.

The `ref-claims` in a `reference-triple-record` can contain one or more entries.
This multiplicity can have different meanings:

1. Each `ref-claims` entry can represent a different possible state of the Environment.
1. Each `ref-claims` entry can represent a possible state of a different measured element (identified by its `mkey`) within the Environment.

Note that the same semantics can be expressed using multiple Reference Value Triples.

Note also that a measurement key-value pair could be defined to have multiple values or use "wild carding" to describe a range of acceptable values, for example when using `int-range` and `min-svn`.

Any of these multiplicities could be used in the context of Reference Values Triples.

To process a `reference-triple-record`, the `ref-env` and `ref-claims` criteria are compared with Evidence entries.
First, `ref-env` is used as search criteria to locate matching Evidence environments.
Then, the `ref-claims` from this triple are used to match against the Evidence measurements for a matched environment.
If the search criteria are satisfied, the matching entry is added to the body of Attester state, except these Claims are asserted with the Reference Value Provider's authority.
By re-asserting Evidence matched with Reference Values using the RVP's authority, the Verifier avoids confusing Reference Values (reference / possible state) with Evidence (actual state).
See {{-rats-endorsements}}.
Evidence Claims that are re-asserted using RVP authority are said to be "corroborated Evidence" because the actual state in Evidence was found within the corpus of the RVP's possible state.

### Endorsed Values Triple {#sec-comid-triple-endval}

An Endorsed Values triple provides additional Endorsements - i.e., claims reflecting the actual state - for an existing Target Environment.
For Endorsed Values Claims, the subject is a Target Environment, the object contains Endorsement Claims for the Environment, and the predicate defines semantics for how the object relates to the subject.

The Endorsed Values Triple has the following structure:

~~~ cddl
{::include cddl/endorsed-triple-record.cddl}
~~~
{: #triple-ev title="Endorsed Values Triple Definition"}

The `endorsed-triple-record` has the following parameters:

* `condition`: Search criterion that locates an Evidence, corroborated Evidence, or Endorsements environment.
* `endorsement`: Additional Endorsement Claims.

To process a `endorsed-triple-record` the `condition` is compared with existing Evidence, corroborated Evidence, and Endorsements.
If the search criterion is satisfied, the `endorsement` Claims are combined with the `condition` `environment-map` to form a new (actual state) entry.
The new entry is added to the existing set of entries using the Endorser's authority.

### Conditional Endorsement Triple {#sec-comid-triple-cond-endors}

A Conditional Endorsement Triple declares one or more conditions that, once matched, results in augmenting the Attester's actual state with the Endorsement Claims.
The conditions are expressed via `stateful-environment-records`, which match Target Environments from Evidence in certain reference state.

The Conditional Endorsement Triple has the following structure:

~~~ cddl
{::include cddl/conditional-endorsement-triple-record.cddl}

{::include cddl/stateful-environment-record.cddl}
~~~
{: #triple-ce title="Conditional Endorsement Triple Definition"}

The `conditional-endorsement-triple-record` has the following parameters:

* `conditions`: Search criteria that locates Evidence, corroborated Evidence, or Endorsements.
* `endorsements`: Additional Endorsements.

To process a `conditional-endorsement-triple-record` the `conditions` are compared with existing Evidence, corroborated Evidence, and Endorsements.
If the search criteria are satisfied, the `endorsements` entries are asserted with the Endorser's authority as new Endorsements.

### Conditional Endorsement Series Triple {#sec-comid-triple-cond-series}

The Conditional Endorsement Series Triple employs a 2-stage matching convention to assert endorsed values based on an initial condition match followed by a series selection match. If both the condition and selection criteria are satisfied, a set of endorsed values are added to the matching triple records. The condition match identifies the set of Claims to which the selection criteria are applied.
The selection specifies a pattern of measurements that, if present, controls when a focused set of endorsed values are to be asserted.
The 2-stage approach enables Endorsement authors the ability to craft powerful search criteria while avoiding problematic repetition of search criteria.

The Conditional Endorsement Series Triple has the following structure:

~~~ cddl
{::include cddl/conditional-endorsement-series-triple-record.cddl}

{::include cddl/conditional-series-record.cddl}
~~~
{: #triple-ces title="Conditional Endorsement Series Triple Definition"}

The `conditional-endorsement-series-triple-record` has the following parameters:

* `condition`: Initial selection criteria that locates Evidence, corroborated Evidence, or Endorsements from the current set of accepted Claims.
The condition consists of an `environment-map`, a (possibly empty) `claims-list`, and an optional `authorized-by`.

* `series`: A sequence of selection-addition tuples.

The `conditional-series-record` has the following parameters:

* `selection`: Secondary selection criteria that locates Evidence, corroborated Evidence, or Endorsements from the initial selection criteria's `condition` result.

* `addition`: Endorsements that are added if the `selection` criteria are satisfied.

##### Condition Matching

The condition matching criteria is applied to the set of Claims the Verifier has previously accepted. The criteria is expressed in terms of environments (i.e., `environment-map`) and optionally measurements (i.e., `claims-list`) or authority (i.e., `authorized-by`).
Condition matching is intended to powerfully enable broad or narrow searches that serve as staging for subsequent selection matching.

Note that `measurement-map` can also specify authority criteria. To avoid conflicting criteria, the `authorized-by` in `condition` takes precedence over the `authorized-by` in `measurement-map`.

##### Selection Matching

Every `conditional-series-record` selection MUST select the same mkeys where every selected mkey's corresponding set of code points represented as mval.key MUST be the same across each `conditional-series-record`.
For example, if a selection matches on 3 `measurement-map` statements; `mkey` is the same for all 3 statements and `mval` contains only A= variable-X, B= variable-Y, and C= variable-Z (exactly the set of code points A, B, and C) respectively for every `conditional-series-record` in the series.

These restrictions ensure that evaluation order does not change the meaning of the triple during the appraisal process.
Series entries are ordered such that the most precise match is evaluated first and least precise match is evaluated last.
The first series condition that matches terminates series matching and the endorsement values are added to the Attester's actual state.

##### Processing the Addition

To process a `conditional-endorsement-series-record` the selection criteria in `condition` entries are matched with existing Evidence, corroborated Evidence, and Endorsements.
If the selection criteria are satisfied, the `series` tuples are processed.

The `series` array contains an ordered list of `conditional-series-record` entries.
Evaluation order begins at list position 0.

For each `series` entry, if the `selection` criteria matches an entry found in the `condition` result, the `series` `addition` is combined with the `environment-map` from the `condition` result to form a new Endorsement entry.
The new entry is added to the existing set of Endorsements.

The first `series` entry that successfully matches the `selection` criteria terminates `series` processing.

### Device Identity Triple {#sec-comid-triple-identity}

Device Identity triples (see `identity-triples` in {{sec-comid-triples}}) endorse that the keys were securely provisioned to the named Target Environment.
A single Target Environment (as identified by `environment` and `mkey`) may contain one or more cryptographic keys.
The existence of these keys is asserted in Evidence, Reference Values, or Endorsements.

The device identity keys may have been used to authenticate the Attester device or may be held in reserve for later use.

Device Identity triples instruct a Verifier to perform key validation checks, such as revocation, certificate path construction & verification, or proof of possession.
The Verifier SHOULD verify keys contained in Device Identity triples.

Additional details about how a key was provisioned or is protected may be asserted using Endorsements such as `endorsed-triples`.

Depending on key formatting, as defined by `$crypto-key-type-choice`, the Verifier may take different steps to locate and verify the key.

If a key has usage restrictions that limit its use to device identity challenges, the Verifier SHOULD enforce key use restrictions.

Each successful verification of a key in `key-list` SHALL produce Endorsement Claims that are added to the Attester's Claim set.
Claims are asserted with the joint authority of the Endorser (CoRIM signer) and the Verifier.
The Verifier MAY report key verification results as part of an error reporting function.

~~~ cddl
{::include cddl/identity-triple-record.cddl}
~~~
{: #triple-di title="Device Identity Triple Definition"}

* `environment`: An `environment-map` condition used to identify the target Evidence or Reference Value.
  See {{sec-environments}}.

* `key-list`: A list of `$crypto-key-type-choice` keys that identifies which keys are to be verified.
  See {{sec-crypto-keys}}.

* `mkey`: An optional `$measured-element-type-choice` condition used to identify the element within the target Evidence or Reference Value.
  See {{sec-comid-mkey}}.

* `authorized-by`: An optional list of `$crypto-key-type-choice` keys that identifies the authorities that asserted the `key-list` in the target Evidence or Reference Values.

### Attest Key Triple {#sec-comid-triple-attest-key}

Attest Key triples (see `attest-key-triples` in {{sec-comid-triples}}) endorse that the keys were securely provisioned to the named Attesting Environment.
An Attesting Environment (as identified by `environment` and `mkey`) may contain one or more cryptographic keys.
The existence of these keys is asserted in Evidence, Reference Values, or Endorsements.

The attestation keys may have been used to sign Evidence or may be held in reserve for later use.

Attest Key triples instruct a Verifier to perform key validation checks, such as revocation, certification path construction and validation, or proof of possession.
The Verifier SHOULD verify keys contained in Attest Key triples.

Additional details about how a key was provisioned or is protected may be asserted using Endorsements such as `endorsed-triples`.

Depending on key formatting, as defined by `$crypto-key-type-choice`, the Verifier may take different steps to locate and verify the key.
If a key has usage restrictions that limits its use to Evidence signing, the Verifier SHOULD enforce key use restrictions.
For example, see Section 5.1.5.3 in {{DICE.cert}}).

Each successful verification of a key in `key-list` SHALL produce Endorsement Claims that are added to the Attester's Claim set.
Claims are asserted with the joint authority of the Endorser (CoRIM signer) and the Verifier.
The Verifier MAY report key verification results as part of an error reporting function.

~~~ cddl
{::include cddl/attest-key-triple-record.cddl}
~~~
{: #triple-ak title="Attest Key Triple Definition"}

See {{sec-comid-triple-identity}} for additional details.

### Triples for domain definitions {#sec-comid-domains}

A domain is a hierarchical description of a Composite Attester in terms of its constituent Environments and their compositional relationships.

The following CDDL describes domain type.

~~~ cddl
{::include cddl/domain-type.cddl}
~~~

Domain structure is defined with the following types of triples.

#### Domain Membership Triple {#sec-comid-triple-domain-membership}

A Domain Membership Triple (DMT) links a domain identifier to its member Environments.
The triple's subject is the domain identifier while the triple’s object lists all the member Environments within the domain.

The Domain Membership Triple allows an Endorser (for example, an Integrator) to issue an authoritative statement about the composition of an Attester as a collection of Environments.
This allows a topological description of an Attester to be expressed by linking a parent Environment (e.g., a lead Attester) to its child Environments (e.g., one or more sub-Attesters).

If the Verifier Appraisal policy requires Domain Membership, the Domain Membership Triple is used to match an Attester's reference composition with the actual composition represented in Evidence.

Representing members of a DMT as domains enables the recursive construction of an entity's topology, such as a Composite Device (see {{Section 3.3 of -rats-arch}}), where multiple lower-level domains can be aggregated into a higher-level domain.

~~~ cddl
{::include cddl/domain-membership-triple-record.cddl}
~~~
{: #triple-dm title="Domain Membership Triple Definition"}

#### Domain Dependency Triple {#sec-comid-triple-domain-dependency}

A Domain Dependency Triple (DDT) links a domain to a set of *trustee* domains.
A domain dependency triple is used by an Endorser to assert that a trust dependency exists between various components.
A DDT specifies which component (identified by `domain-id`) depends on which other components (identified by `trustees`) for proper operation.
A series of DDTs can be used to describe the trust dependencies of a system of components as a graph.
CoRIM uses `environment-map` to identify components and groupings of components (i.e., domains).

Trust dependency means that an environment can only be fully trusted if one or more trustee environments have been appraised and found to be trustworthy.
A candidate environment can only be trusted if the trustee environments it depends on exist, have been appraised and are found to be trustworthy.

The first four phases of appraisal (see {{sec-match-and-augment}}) might not determine whether a component is trustworthy.
Subsequent Verifier stages or Relying Party processing might be needed to finalize trustworthiness.
Therefore, the trustworthiness of trustee domains MUST be appraised before the trustworthiness of the subject domain can be finalized.
Consequently, trust dependency semantics may need to be represented in Attestation Results if Relying Parties play a role in finalizing which components are trustworthy.

There are a variety of use cases where trust dependency might exist.
For example, trust in an operating system (OS) might depend on trustworthy loading of the OS loader image.
Consequently, the OS loader is a trustee domain of the OS.
Alternatively, trust in a peripheral device might depend on trustworthy operation of a peripheral device's bus controller.
The bus controller is therefore a trustee domain of the peripheral device.

DDTs cannot create domains.
Instead, DDT processing first checks that a `domain-id` has already been accepted into the ACS before adding trust dependencies.

The domain dependency triple subject (`domain-id`) identifies the member domain (see {{sec-comid-triple-domain-membership}}) that has trustees.
The triple object `trustees` lists the domains that are trustees of the subject domain.
The triple predicate asserts that a trust appraisal of `domain-id` is not complete without appraisal of the `trustees`.

~~~ cddl
{::include cddl/domain-dependency-triple-record.cddl}
~~~
{: #triple-dd title="Domain Dependency Triple Definition"}

All of the DDT subjects (`domain-id`) and objects (`trustees`) MUST also be domain members for the DDT expression to be processed.

Trust dependency graphs are acyclic, meaning a `domain-id` MUST NOT appear in the `trustees` list or within a trustee's subtree.

A terminating "leaf" trustee is a "root of trust" for that subtree.
Leaf trustees SHOULD have a corresponding Endorsement triple.
Verifiers MAY use DDTs with appraisal policies to assess the veracity of domain-to-trustee linkages.

Trust dependency typically exists if any of the following are true:

* A trustee performs any Attesting Environment functions relating to a Target Environment (TE), such as Claims collection, Claims signing, loading or initialization of the TE, provisioning TE secrets - including cryptographic keys or other security-relevant material.
* A trustee executes security-relevant code in response to an execution thread that originates from the `domain-id` environment.
* A trustee is a component embedded within another component identified by `domain-id`.

Trust dependency processing is described in {{sec-proc-dd}}.

### CoMID-CoSWID Linking Triple {#sec-comid-triple-coswid}

A CoSWID triple relates reference measurements contained in one or more CoSWIDs
to a Target Environment. The subject identifies a Target Environment, the
object one or more unique tag identifiers of existing CoSWIDs, and the
predicate asserts that these contain the expected (i.e., reference)
measurements for the Target Environment.

~~~ cddl
{::include cddl/coswid-triple-record.cddl}
~~~
{: #triple-ccl title="CoMID-CoSWID Linking Triple Definition"}

## Extensibility {#sec-extensibility}

The base CoRIM document definition is described using CDDL {{-cddl}} that can be extended only at specific allowed points known as "extension points".

The following types of extensions are supported in CoRIM.

### Map Extensions

Map extensions provide extensibility support to CoRIM map structures.
CDDL map extensibility enables a CoRIM profile to extend the base CoRIM CDDL definition.
CDDL map extension points have the form `($$NAME-extension)` where "NAME" is the name of the map and '$$' signifies map extensibility.
Typically, map extension requires a convention for code point naming that avoids code-point reuse.
Well-known code points may be in a registry, such as CoSWID {{-coswid-reg}}.
Non-negative integers are reserved for IANA to assign meaning globally.

### Data Type Extensions

Data type extensibility has the form `($NAME-type-choice)` where "NAME" is the type name and '$' signifies type extensibility.

New data type extensions SHOULD be documented to facilitate interoperability.
CoRIM profiles are best used to document vendor or industry defined extensions.

# CoTL {#sec-cotl}

A Concise Tag List (CoTL) object represents the signal for the
Verifier to activate the listed tags. Verifier policy determines whether CoTLs are required.

When CoTLs are required, each tag MUST be activated by a CoTL before being processed.
All the tags listed in the CoTL MUST be activated atomically. If any tag activated by a CoTL is not available to the Verifier, the entire CoTL is rejected.

The number of CoTLs required in a given supply chain ecosystem is dependent on
Verifier Owner's Appraisal Policy for Evidence. Corresponding policies are often driven by the complexity and nature of the use case.

If a Verifier Owner has a policy that does not require CoTL, tags within a CoRIM received by a Verifier
are activated immediately and treated valid for appraisal.

There may be cases when Verifier receives CoRIMs from multiple
Reference Value providers and Endorsers. In such cases, a supplier (or other authorities, such as integrators)
may be designated to issue a single CoTL to activate all the tags submitted to the Verifier
in these CoRIMs.

In a more complex case, there may be multiple authorities that issue CoTLs at different points in time.
An Appraisal Policy for Evidence may dictate how multiple CoTLs are to be processed within the Verifier.

## Structure

The CDDL specification for the `concise-tl-tag` map and additional grammatical requirements specified in the text of this Section MUST be followed when creating or validating a CoTL tag are given below:

~~~ cddl
{::include cddl/concise-tl-tag.cddl}
~~~

The following describes each member of the `concise-tl-tag` map.

* `tag-identity` (index 0): A `tag-identity-map` containing unique
  identification information for the CoTL.
  Described in {{sec-comid-tag-id}}.

* `tags-list` (index 1): One or more `tag-identity-maps` identifying
  the CoMID and CoSWID tags that constitute the list, i.e.,
  a complete set of verification-related information.  The `tags-list` behaves
  like a signaling mechanism from the supply chain (e.g., a product vendor) to
  a Verifier that activates the tags in `tags-list` for use in the Evidence
  appraisal process, and the activation is atomic. All tags listed in `tags-list`
  MUST be activated or no tags are activated.

* `tl-validity` (index 2): Specifies the validity period of the CoTL.
  Described in {{sec-common-validity}}.

# Common Types {#sec-common-types}

The following CDDL types may be shared by CoRIM, CoMID, and CoTL.

## Non-Empty {#sec-non-empty}

The `non-empty` generic type is used to express that a map with only optional
members MUST at least include one of the members.

~~~~ cddl
{::include cddl/non-empty.cddl}
~~~~

## Entity {#sec-common-entity}

The `entity-map` is a generic type describing an organization responsible for
the contents of a manifest. It is instantiated by supplying two parameters:

* A `role-type-choice`, i.e., a selection of roles that entities of the
  instantiated type can claim

* An `extension-socket`, i.e., a CDDL socket that can be used to extend
  the attributes associated with entities of the instantiated type

~~~cddl
{::include cddl/entity-map.cddl}

{::include cddl/entity-name-type-choice.cddl}
~~~

The following describes each member of the `entity-map`.

* `entity-name` (index 0): The name of entity which is responsible for the action(s) as defined by the role.
  `$entity-name-type-choice` can only be text.
  Other specifications can extend the `$entity-name-type-choice`.
  See {{sec-iana-comid}}.

* `reg-id` (index 1): A URI associated with the organization that owns the entity name.

* `role` (index 2): A type choice defining the roles that the entity is claiming.
  The role is supplied as a parameter at the time the `entity-map` generic is instantiated.

* `extension-socket`: A CDDL socket used to add new information structures to the `entity-map`.

Examples of how the `entity-map` generic is instantiated can be found in
({{sec-corim-entity}}) and ({{sec-comid-entity}}).

## Validity {#sec-common-validity}

A `validity-map` represents the time interval during which the signer
warrants that it will maintain information about the status of the signed
object (e.g., a manifest).

In a `validity-map`, both ends of the interval are encoded as epoch-based
date/time as per {{Section 3.4.2 of -cbor}}.

~~~ cddl
{::include cddl/validity-map.cddl}
~~~

* `not-before` (index 0): the date on which the signed manifest validity period
  begins

* `not-after` (index 1): the date on which the signed manifest validity period
  ends

## UUID {#sec-common-uuid}

Used to tag a byte string as a binary UUID.
Defined in {{Section 4 of -uuid}}.

~~~ cddl
{::include cddl/uuid.cddl}
~~~

## UEID {#sec-common-ueid}

Used to tag a byte string as Universal Entity ID Claim (UEID).
Defined in {{Section 4.2.1 of -eat}}.

~~~ cddl
{::include cddl/ueid.cddl}
~~~

## OID {#sec-common-oid}

Used to tag a byte string as the BER encoding {{X.690}} of an absolute object
identifier {{-cbor-oids}}.

~~~ cddl
{::include cddl/oid.cddl}
~~~

## Digest {#sec-common-hash-entry}

A digest represents the value of a hashing operation together with the hash algorithm used.
This specification reuses the `digest` type defined in {{Section 4.2 of -eat-mc}}.
Only the CBOR serialization is used.

~~~ cddl
{::include cddl/digest.cddl}
~~~

A measurement can be obtained using different hash algorithms.
A `digests-type` can be used to collect multiple digest values obtained by applying different hash algorithms on the same input.
Each entry in the `digests-type` MUST have a unique `alg` value.

## Tagged Bytes Type {#sec-common-tagged-bytes}

An opaque, variable-length byte string.
It can be used in different contexts: as an instance, class or group identifier in an `environment-map`; as a raw value measurement in a `measurement-values-map`.
Its semantics are defined by the context in which it is found, and by the overarching CoRIM profile.
When used as an identifier the responsible allocator entity SHOULD ensure uniqueness within the context that it is used.

~~~ cddl
{::include cddl/tagged-bytes.cddl}
~~~

# Reference Verifier

This section outlines the behaviour of a "CoRIM processor" within the Evidence appraisal procedure carried out by the RATS Verifier ({{Section 7.4 of -rats-arch}}).

In the remainder of this section, the terms
Environment,
Claim,
Environment-Claim Tuple (ECT),
Authority,
Appraisal Claims Set (ACS),
and
Appraisal Policy
are used with the meanings defined in {{sec-glossary}}.

## Appraisal Logical Phases {#sec-appraisal-phases}

For clarity, the appraisal procedure is divided into several logical phases.

**Phase 1**: Input Validation and Transformation.

During this phase, all available Conceptual Messages are processed for validation.
This involves checking digital signatures to verify their integrity and authenticity, ensuring they are not outdated and confirming their relevance to the current appraisal.
If validation fails, the input Conceptual Message is discarded.
If validation succeeds, the Conceptual Message is transformed from its external representation into an internal one.
These internal representations are then collected in an implementation-specific "staging area", which acts as a database for subsequent appraisal processing.

**Phase 2**: Evidence Augmentation.

During this phase, Evidence Claims are added to a structure describing the Attester's actual state, known as the ACS.
These Claims are added to the ACS with Attester Authority.

**Phase 3**: Reference Values Corroboration and Augmentation.

During this phase, Reference Value Claims are compared with Evidence Claims from the ACS.
Reference Value Claims describe the possible states of the Attester.
If the Attester's actual state, as described in the ACS, is one of these possible states, the Attester's actual state is said to be "corroborated".
These Claims are added to the ACS with the Authority of the Reference Value Provider.

**Phase 4**: Endorsed Values Augmentation.

During this phase, Endorsed Values inputs containing conditions that describe the expected state of the Attester are processed.
If the conditions are met, additional Claims about the Attester are added to the ACS.
These Claims are added with the Endorser's Authority.

**Subsequent Phases**: Before producing an Attestation Result, a Verifier may undergo subsequent phases of the appraisal procedure.

For example, the Verifier may perform consistency, integrity or additional validity checks.
These checks may result in additional Claims about the Attester being added to the ACS.
These Claims are added with the Verifier's Authority.
Typically, a Verifier applies Appraisal Policy for Evidence on the ACS that describes desirable or undesirable Attester states.
If these conditions are met, the policy may add further Claims about the Attester to the ACS.
These Claims are added with the Authority of the Verifier's Owner.
Finally, the outcome of appraisal and the set of Attester Claims of interest to a Relying Party are copied from the Attester state to an output staging area.
The Claims in the output staging area and other Verifier-related metadata are then transformed into an external representation suitable for consumption by a Relying Party.
This external representation is the Attestation Result message (see {{Section 8.4 of -rats-arch}}).

Please note that a detailed description of subsequent phases is beyond the scope of this document.
They are mentioned here to provide an overview of the appraisal procedure.
The CoRIM processor described in {{sec-corim-processor}} describes the handoff interface between Phase 4 and the subsequent phases in terms of the computed ACS.

## The CoRIM Processor {#sec-corim-processor}

This document assumes that Verifier implementations will differ.
In order to describe normative Verifier behaviour, this section presents a reference Verifier and illustrates how the data is utilized within the appraisal phases detailed in {{sec-appraisal-phases}}.
If the Verifier operates on CoRIM documents, it is RECOMMENDED that it follows this algorithm.

### High-Level View

The RATS Verifier takes Evidence, Reference Values, Endorsements and an Appraisal Policy for Evidence as inputs, and produces Attestation Results as output.
{{fig-verifier-internal}} illustrates how the CoRIM processor fits into the wider RATS Verifier architecture.

~~~ aasvg
{::include pics/corim-verifier.txt}
~~~
{: #fig-verifier-internal artwork-align="center" title="CoRIM Processing Flow"}

The CoRIM processor accepts Reference Values and Endorsements in the form of CoRIM documents, as well as Evidence that has been converted into a CoRIM-compatible format using transforms such as those described in {{-rats-evidence-trans}}.
Before the appraisal can begin, all Conceptual Messages must be broken down and reshaped into a common internal representation.
The internal representations of Reference Values and Endorsements are stored in a staging area prior to appraisal initiation.
Instead, the internal representation of Evidence is used to initialize the ACS.
A Verifier can have multiple simultaneous sessions with different Attesters.
Each Attester has a different ACS.
The Verifier ensures that Evidence inputs are associated with the correct ACS.
All the internal representations are based on the Environment-Claim Tuple (ECT).
The ECT is the core data structure used to represent both Claims and matching conditions during appraisal by the CoRIM processor.
The CoRIM processor algorithm loads items from the staging area one by one and applies the required condition-matching rules against the ECTs in the ACS.
If the match is successful, the ACS is "augmented" with Claims from the matched item.
Once all the items in the staging area have been processed, the state of the Attester, as understood by the CoRIM processor, is reflected in the ACS.
The computed ACS can then be handed over to subsequent appraisal phases, such as Appraisal Policy evaluation and Attestation Results computation, repackaging and signing.

### Data Structures

This section describes the data structures used by the CoRIM processor.

#### ECT {#sec-ect}

The Environment-Claim Tuple is a core internal construct of the CoRIM Verifier.
It is used to describe a feature (or "Claim") of the appraised environment alongside relevant metadata.
All ECTs, except those containing Evidence Claims, are typically obtained from CoMID triples.

Claims in ECTs have a both name and a value.
The value represents the state associated with the Claim.
This specification does not assign any special meaning to Claim names; it only specifies the rules for determining whether two Claim names are the same.

An ECT ({{fig-ect}}) can be one of the following specializations:

* `E-ECT` (Element ECT): used to represent Evidence, Reference Value and Endorsement Claims, as detailed in {{sec-element-ect}};

* `D-ECT` (Domain ECT): used to represent domain membership and trust dependencies Claims, as detailed in {{sec-domain-ect}};

* `K-ECT` (Key ECT): used to represent Identity and Attestation keys, as detailed in {{sec-key-ect}}.

~~~ cddl
{::include cddl/intrep-ect.cddl}
~~~
{: #fig-ect title="ECT definition"}

While the internal representation of each specialization varies, all ECT specializations share the attributes captured in the `ECT-common` group ({{fig-ect-common}}).

~~~ cddl
{::include cddl/intrep-ect-common.cddl}
~~~
{: #fig-ect-common title="ECT common attributes"}

* `environment`: Identifies the Environment that is the subject of the stated Claims.
In an Element ECT, it is the target environment to which the elements belong.
In a Domain ECT, it is the parent environment to which the child domains are related.
In a Key ECT, it is the environment to which the keys belong.
In all cases, Environments are identified using instance, class, or group identifiers.

* `authority`: Identifies the entity that issued the tuple.
The authority of a given ECT is typically established through a digital signature on the Claim.
For instance, a signature of the authoritative supply chain entity over the CoRIM containing the triple from which the ECT was obtained, or the Attesting Environment that signed the Evidence from which the ECT is derived.
It is represented as the key material by which the authority (and corresponding provenance) of the tuple can be determined.
A typical example is the authority's PKIX certificate.
This is a mandatory attribute in an ECT.

* `profile`: The profile that defines the domain of interpretation of this tuple.
This is the `profile` attribute of the CoRIM that contained the original triple from which this ECT was obtained.
This is an optional attribute in an ECT.
If no profile is used, the attribute is omitted.
<cref>
[TBC]
What profile applies in such a case?
</cref>

##### Element ECT {#sec-element-ect}

An Element ECT (`E-ECT`) is used to represent Evidence, Reference Value and Endorsement Claims.

~~~ cddl
{::include cddl/intrep-e-ect.cddl}
~~~
{: #fig-e-ect title="Element ECT"}

The following describes the specialized members of the `E-ECT`.

* `element-list`: Identifies the set of elements contained within a Target Environment and their trustworthiness Claims, each described by an `element-map`.
An `element-map` is very similar to a `measurement-map`, with the `element-id` and `element-claims` corresponding to the `mkey` and `mval`, respectively.
The pseudocode in {{algo-mm-to-em}} describes the transformation from `measurement-map`(s) to `element-map`(s).

* `cmtype`: Identifies the type of Conceptual Message that originated the tuple (Reference Values, Endorsements or Evidence).

~~~ pseudocode
FUNC mm_to_em(mm: measurement-map) -> element-map {
    em := element-map::NEW()

    IF mm.mkey:
        em.element-id = mm.mkey

    em.element-claims = mm.mval

    RETURN em
}

FUNC mms_to_ems(mms: [ + measurement-map ]) -> [ + element-map ] {
    ems := [ + element-map ]::NEW()

    FOREACH mm IN mms:
        em := mm_to_em(mm)
        ems::APPEND(em)

    RETURN ems
}
~~~
{: #algo-mm-to-em title="Transform Measurement Map(s) into Element Map(s)"}

**Claim Names.**
The combination of `environment`, optional `element-id`, and map key within each `element-claims` encodes the name of an Element Claim.
The value of the corresponding map element represents an atom of actual state.
This specification does not assign special meanings to any Claim name, it only specifies rules for determining whether two Claim names are the same.

**Merge Rules.**
If two Element ECTs have the same `environment`, `cmtype`, `authority` and `profile` then their `element-list`s are merged.
Any duplicates MUST be pruned.

<cref>
[TBC]
Original text also states: "If two merged `measurement-values-map` contains duplicate codepoints and the measurement values are not equivalent, then the Verifier SHALL report an error and stop validation processing."
Are we sure this is the case?
Can't they be interpreted as alternative states?
</cref>

##### Domain ECT {#sec-domain-ect}

A Domain ECT (`D-ECT`) is used to represent domain membership and trust dependency Claims between environments.
It describes the direct relationship between a specific node in the membership or trust dependency graph (i.e., the parent `environment`) and the nodes to which it is connected (i.e., the `children`).

~~~ cddl
{::include cddl/intrep-d-ect.cddl}
~~~
{: #fig-d-ect title="Domain ECT"}

The following describes the specialized members of the `D-ECT`.

* `children`: Identifies the set of members of the domain rooted in the parent `environment`.

* `kind`: Identifies the type of Domain triple that originated the tuple: `member` stands for Domain Membership, `trustee` is for Domain Dependency.

**Claim Names.**

A Domain Claim specifies the type of relationship that the parent domain is expected to have with its child environments.
In a Domain ECT, the `environment` attribute encodes the name of the Claim.
The value of the Claim is encoded in the `kind` and `children` attributes.

**Merge Rules.**

No merge rules are specified for a Domain ECT.

##### Key ECT {#sec-key-ect}

A Key ECT (`K-ECT`) is used to represent Identity and Attestation keys.

~~~ cddl
{::include cddl/intrep-k-ect.cddl}
~~~
{: #fig-k-ect title="Key ECT"}

The following describes the specialized members of the `K-ECT`.

* `key-id`: Identifies a specific namespace within `environment` that the keys in `key-list` are associated with.
* `key-list`: Identifies the set of keys associated with `environment` and (optionally) `key-id`.
* `key-type`: Either `attest-key` or `identity-key`, depending on the triple that originated this `K-ECT` instance.

**Claim Names.**

A Key Claim specifies the type of key that an environment is expected to ...

In a Key ECT, the `environment`, `key-type` and optional `key-id` attributes encodes the name of the Claim.
The value of the Claim is encoded in the `key-list` attribute.

**Merge Rules.**

No merge rules are specified for a Key ECT.

#### Internal Representation {#sec-ir}

This section describes how the relevant RATS Conceptual Messages are represented within the CoRIM processor.
This internal representation is based on the concept of "relations", which in turn are based on ECTs.
Typically, a relation is structured as a "condition" ECT that specifies the matching criteria used to compare entries in the ACS, along with an "addition" ECT that is appended to the ACS if the specified condition are met.
While this is the common structure, some relations may differ slightly from the condition/addition pattern.
This is because they either do not require a condition (e.g., Evidence) or they require more sophisticated matching criteria that cannot be expressed solely via a condition (e.g., Conditional Endorsement Series).
<cref>
[TODO]
Merge §2.1 and §2.2. to explain the high-level principles before delving into the details.
</cref>

##### Evidence {#sec-ir-evidence}

The internal representation of Evidence uses the `ae` relation.

~~~ cddl
{::include cddl/intrep-ae.cddl}
~~~
{: #fig-ae title="Attestation Evidence Relation"}

The `addition` is a list of ECTs with Evidence Claims (`ae-item`s) to be appraised.
Note that there is no `condition` in the `ae` relation, meaning that the addition of Evidence Claims is unconditional once Evidence has been verified.

{{fig-ae-ect}} shows the profiled ECT for an `ae` item.

~~~ cddl
{::include cddl/intrep-ect-evidence-addition.cddl}
~~~
{: #fig-ae-ect title="Profiled ECT for Evidence"}

All `E-ECT` attributes are mandatory, except `profile`.

##### Reference Values {#sec-ir-refval}

The internal representation of Reference Values uses the `rv` relation where each `rv-item` corresponds to a `reference-triple-record`.

~~~ cddl
{::include cddl/intrep-rv.cddl}
~~~
{: #fig-rv title="Reference Values Relation"}

The `rv` relation is a list of condition-addition pairs, each of which is evaluated together.
If the `condition` containing the "reference" ECTs matches the Evidence ECTs, the Evidence ECTs are re-asserted with the RVP authority carried in the `addition` ECT and the `cmtype` set to `reference-values`.
The re-asserted ECTs are added to the ACS.
Refer to {{sec-proc-rv}} for how the `rv` entries are processed.

{{fig-rv-ect-cond}} shows the profiled Element ECT for a Reference Values condition.

~~~ cddl
{::include cddl/intrep-ect-refval-condition.cddl}
~~~
{: #fig-rv-ect-cond title="Profiled ECT for Reference Values (condition)"}

{{fig-rv-ect-add}} shows the profiled Element ECT for a Reference Values addition.

~~~ cddl
{::include cddl/intrep-ect-refval-addition.cddl}
~~~
{: #fig-rv-ect-add title="Profiled ECT for Reference Values (addition)"}

As this is used to corroborate an Evidence ECT, its layout is identical to that of an `Evidence-addition-ECT`.
The only differences are the values of the `authority` and `cmtype` attributes.
Here, the `authority` value is that of the RVP rather than the Attester, and the `cmtype` value is `reference-values` rather than `evidence`.

##### Endorsed Values {#sec-ir-endval}

The internal representation of Endorsed Values uses the `ev` and `evs` relations.
These are lists of ECTs that describe matching conditions and the additions that apply when these conditions are met.

The `ev` relation ({{fig-ev}}) applies to Endorsed Values (EV) and Conditional Endorsement (CE) triples.

~~~ cddl
{::include cddl/intrep-ev.cddl}
~~~
{: #fig-ev title="Endorsed Values Relation"}

The `ev` relation compares the condition ECTs with those in the ACS.
If all the ECTs are found in the ACS, the addition ECTs are added to it.
Note that when the `ev` relation is for an EV triple, the optional `element-list` inside the condition is not used; however, it is used for CE triples.

The `evs` relation ({{fig-evs}}) applies to Conditional Endorsement Series (CES) Triples.

~~~ cddl
{::include cddl/intrep-evs.cddl}
~~~
{: #fig-evs title="Endorsed Values Series Relation"}

The `evs` relation compares the condition ECTs with the ACS.
<cref>
[TBC]
There is only one ECT in the condition.
The description doesn't seem to match the data format.
</cref>
If all the ECTs are found in the ACS, each entry in the series list is evaluated.
The selection ECTs are then compared with the ACS.
If the selection criteria are met, the addition ECTs are added to the ACS and the series evaluation ends.
If the selection criteria are not satisfied, evaluation proceeds to the next series list entry.

{{fig-ev-cond}} shows the profiled Element ECT an Endorsed Value condition.

~~~ cddl
{::include cddl/intrep-ect-endval-condition.cddl}
~~~
{: #fig-ev-cond title="Profiled ECT for Endorsed Values and Endorsed Values Series tuples (condition)"}

{{fig-ev-sel}} shows the profiled Element ECT an Endorsed Value selection.

~~~ cddl
{::include cddl/intrep-ect-endval-selection.cddl}
~~~
{: #fig-ev-sel title="Profiled ECT for Endorsed Values and Endorsed Values Series tuples (selection)"}

{{fig-ev-add}} shows the profiled Element ECT an Endorsed Value addition.

~~~ cddl
{::include cddl/intrep-ect-endval-addition.cddl}
~~~
{: #fig-ev-add title="Profiled ECT for Endorsed Values and Endorsed Values Series tuples (addition)"}

##### Keys {#sec-ir-keys}

The internal representation of Attest Key and Device Identity triples uses the `keys` relation ({{fig-k}}), whereby each `key-item` corresponds to either an `attest-key-triple-record` or an `identity-triple-record`.

~~~ cddl
{::include cddl/intrep-key.cddl}
~~~
{: #fig-k title="Keys Relation"}

<cref>
[TODO]
Specialise condition/addition ECTs.
Define constraints.
</cref>

##### Domains {#sec-ir-domains}

The internal representation of domains uses a common `domain-item` structure:

~~~ cddl
{::include cddl/intrep-domain-item.cddl}
~~~
{: #fig-dm-item title="Domain Item"}

The internal representation of Domain Membership uses the `dm` relation ({{fig-dm}}), whereby each `domain-item` corresponds to a `domain-membership-triple-record`.

~~~ cddl
{::include cddl/intrep-domain-mem.cddl}
~~~
{: #fig-dm title="Domain Membership Relation"}

The internal representation of Domain Dependency uses the `dd` relation ({{fig-dd}}), whereby each `domain-item` corresponds to a `domain-dependency-triple-record`.

~~~ cddl
{::include cddl/intrep-domain-dep.cddl}
~~~
{: #fig-dd title="Domain Dependency Relation"}

{{fig-domain-ect-cond}} shows the profiled Domain ECT for both Domain Membership and Dependency conditions.

~~~ cddl
{::include cddl/intrep-ect-domain-condition.cddl}
~~~
{: #fig-domain-ect-cond title="Profiled ECT for Domain Membership and Dependency (condition)"}

Only the `children` are used for matching, not the `environment`.
Therefore, the `environment` attribute is excluded from the ECT condition.

{{fig-domain-ect-add}} shows the profiled Domain ECT for both Domain Membership and Dependency additions.

~~~ cddl
{::include cddl/intrep-ect-domain-addition.cddl}
~~~
{: #fig-domain-ect-add title="Profiled ECT for Domain Membership and Dependency (addition)"}

#### ACS

The ACS ({{fig-acs}}) is a list of ECTs that represent the Attester's actual state as determined by various authoritative sources (Reference Value Providers and Endorsers) collected by the Verifier.

~~~ cddl
{::include cddl/intrep-acs.cddl}
~~~
{: #fig-acs title="ACS"}

The `authority` attribute in each ECT represents one such source, while the Claims in the ECT are statements made by that source about the Attester.

The ACS is initialized with Evidence Claims and is then populated with Reference Values and Endorsement Claims via the "match and augment" algorithm (see {{sec-match-and-augment}}) implemented by the CoRIM processor.

Once the staging area has been drained by the CoRIM processor, processing stops and the computed ACS is handed over to subsequent phases.
In this way, the ACS represents the CoRIM processor's output interface.

The order of the ECTs in the ACS is not significant.
Logically, as the ACS represents the conjunction of all claims, adding an ECT entry to the existing ACS at the end has the same effect as inserting it anywhere else.

#### Staging Area

The staging area ({{fig-sa}}) is a list of the relations corresponding to the transformed triples.

~~~ cddl
{::include cddl/stagingarea.cddl}
~~~
{: #fig-sa title="Staging Area"}

All relations are optional.
Whether a given relation is present in the staging area depends on whether a triple exists and has been successfully transformed.

### Input Validation and Transformation (Phase 1)

This section provides a detailed description of Phase 1, which was outlined at a high level in {{sec-appraisal-phases}}, explaining how the relevant Conceptual Messages are ingested by the CoRIM processor.

During the initialization phase, various Conceptual Message inputs are collected: CoMID tags (see {{sec-comid}}); CoSWID tags (see {{-coswid}}); CoTL tags (see {{sec-cotl}}); cryptographic validation key material (including raw public keys, root certificates and intermediate CA certificate chains); and Concise Trust Anchor Stores (CoTS) (see {{-ta-store}}) are collected.
These objects will be utilized at various stages in the subsequent Evidence Appraisal phases that follow.
The primary goal of this phase is to ensure that all necessary information is available for subsequent processing.

Once initialization is complete, no further inputs are accepted until the appraisal processing is finished.

#### CoRIM Selection

All available CoRIMs tags are collected.

CoRIM tags MUST be discarded if they have expired, or if they are not associated with an authenticated and authorized source, or if they have been revoked by an authorized source.
Any CoRIM secured by a cryptographic mechanism that fails validation MUST be discarded.

Other selection criteria MAY be applied.
For example, if the Evidence format is known in advance, CoRIMs using a profile that is not understood by a Verifier can be readily discarded.

Further selection criteria may be applied to the CoRIM contents at later stages.

#### CoRIM Trust Anchors

If CoRIM tags are signed, the signatures MUST be validated using the appropriate trust anchors available to the Verifier.
The Verifier is expected to have a trust anchor store.
The way in which these trust anchors are provisioned in the Verifier is beyond the scope of this specification.
If the CoRIM is signed, it should include at least one certificate (e.g., as part of the `x5chain` in the COSE header) that corresponds to the key pair used for signing.
This certificate MUST have a valid certification path to one of the Verifier's trust anchors.

#### Tags Extraction and Validation

The Verifier extracts tags from the selected CoRIMs, including CoMID, CoSWID, CoTL, and CoTS.

The Verifier MUST discard any tags that are not syntactically or semantically valid.
Cross-referenced triples MUST be successfully resolved.
An example of a cross-referenced triple is a CoMID-CoSWID linking triple described in {{sec-comid-triple-coswid}}.

#### CoTL Extraction

(This section is not applicable if the Verifier appraisal policy does not require CoTLs.)

CoTLs that are outside their validity period MUST be discarded.

The Verifier processes all CoTLs that are valid at the time of Evidence appraisal and activates all referenced tags.

Depending on any locally configured authorization policies, the Verifier MAY decide to discard some of the available and valid CoTLs.
Such policies model the trust relationships between the Verifier Owner and the relevant suppliers, and are out of the scope of the present document.
For example, a composite device (see {{Section 3.3 of -rats-arch}}) is likely to be fully described by multiple CoRIMs, each signed by a different supplier.
In such a case, the Verifier Owner may instruct the Verifier to discard any tags activated by a supplier's CoTL that has not also been activated by the trusted integrator.

Once the Verifier has processed all CoTLs, it MUST discard any tags that have not been activated by a CoTL.

#### Evidence Collection {#sec-ev-coll}

The Verifier communicates with Attesters to gather Evidence.
Discovery of Evidence sources is untrusted.
Verifiers may rely on conveyance protocol-specific context to identify an Evidence source, which acts as the Evidence input oracle for appraisal.

The collected Evidence is then transformed into an internal representation (see {{sec-ir-evidence}}), making it suitable for appraisal processing.

The exact protocol used to collect Evidence is out of scope of this specification.

#### Cryptographic Validation of Evidence {#sec-crypto-validate-evidence}

If Evidence is cryptographically signed, it is validated before being transformed into an internal representation.

If Evidence is not cryptographically signed, the conveyance protocol used to collected it MUST provide the required security.
In such cases, the cryptographic validation of Evidence depends on the security offered by the conveyance protocol.

How cryptographic signature validation works depends on the specific Evidence collection method used.
For example, in DICE, a proof of liveness is carried out on the final key in the certificate chain (i.e., the "alias" certificate).
If this is successful, a suitable certification path is looked up in the Verifier trust anchor store based on the linking information obtained from the DeviceID certificate.
See Section 9.2.1 of {{DICE.Layer}}.
If a trusted root certificate is found, X.509 certificate validation is performed.

As a second example, the verification public key use to verify {{-psa-token}} Evidence is looked up in the appraisal context using the `ueid` claim found in the PSA claims-set.
If found, COSE Sign1 verification is performed.

Regardless of the specific integrity protection method used, the Verifier MUST NOT process Evidence that is not successfully validated.

#### Input Transformation {#sec-input-trans}

This section describes how the relevant RATS Conceptual Messages are transformed upon ingestion by the CoRIM processor.

##### Evidence {#sec-trans-evidence}

Evidence transformation involves mapping Evidence into one or more `Evidence-ECT`s (see {{sec-ir-evidence}}), and adding them to the `addition` list of an `ae` relation.
Evidence transformation algorithms may be well-known (e.g., {{-rats-evidence-trans}}), defined by a CoRIM profile (see {{sec-corim-profile-types}}), or supplied dynamically.
Evidence transformation algorithms are out of scope for this document.

For successful transformation, Evidence MUST contain a relevant value for all the mandatory `Evidence-ECT` attributes.
Otherwise, the CoRIM processor MUST reject the Evidence.

##### Reference Values

Reference Values transformation involves mapping Reference Value triples into into an `rv` relation (see {{sec-ir-refval}}).
Each `reference-triple-record` ({{triple-rv}}) is transformed into an `rv-item` ({{fig-rv}}) as described in {{algo-rv-transform}}.
(The code reuses the `mms_to_ems` function from {{algo-mm-to-em}}.)

~~~ pseudocode
FUNC transform(
    T: reference-triple-record,
    signer: [ + $crypto-key-type-choice ],
    profile: $profile-type-choice
) -> rv-item {
    item := rv-item::NEW()

    item.addition.cmtype = reference-values

    item.addition.environment = T.ref-env
    item.condition.environment = T.ref-env

    item.condition.element-list = mms_to_ems(T.ref-claims)

    item.addition.authority = signer

    IF profile:
        item.addition.profile = profile

    RETURN item
}
~~~
{: #algo-rv-transform title="Reference Value Triple Transformation"}

Note that the `ref-claims` are not copied to the addition ECT.
Since they may contain ranges rather than individual values (see, for example, {{sec-comid-int-range}}), we need to wait until the condition is satisfied by an Evidence ECT before we can copy the matched claims from the Evidence ECT to the addition ECT.

##### Endorsed Values

Endorsed Values transformation involves mapping EV, CE and CES triples into into `ev` or `evs` relations (see {{sec-ir-endval}}).

A `endorsed-triple-record` ({{triple-ev}}) is transformed into an `ev-item` ({{fig-ev}}) as described in {{algo-ev-transform}}.
(The code reuses the `mms_to_ems` function from {{algo-mm-to-em}}.)

~~~ pseudocode
FUNC transform(
    T: endorsed-triple-record,
    signer: [ + $crypto-key-type-choice ],
    profile: $profile-type-choice
) -> ev-item {
    item := ev-item::NEW()

    item.addition.cmtype = endorsements

    item.addition.environment = T.condition
    item.condition.environment = T.condition

    item.addition.element-list = mms_to_ems(T.endorsement)

    item.addition.authority = signer

    IF profile:
        item.addition.profile = profile

    RETURN item
}
~~~
{: #algo-ev-transform title="Endorsed Value Triple Transformation"}

A `conditional-endorsement-triple-record` ({{triple-ce}}) is transformed into an `ev-item` ({{fig-ev}}) as described in {{algo-ce-transform}}.
(The code reuses the `mms_to_ems` function from {{algo-mm-to-em}}.)

~~~ pseudocode
FUNC transform(
    T: conditional-endorsement-triple-record,
    signer: [ + $crypto-key-type-choice ],
    profile: $profile-type-choice
) -> ev-item {
    item := ev-item::NEW()

    item.addition.cmtype = endorsements

    FOREACH ser IN T.conditions:
        item.condition.environment = ser.environment
        item.condition.element-list = mms_to_ems(ser.claims-list)

    FOREACH etr IN T.endorsements:
        item.addition.environment = etr.condition
        item.addition.element-list = mms_to_ems(etr.endorsement)

    item.addition.authority = signer

    IF profile:
        item.addition.profile = profile

    RETURN item
}
~~~
{: #algo-ce-transform title="Conditional Endorsement Triple Transformation"}

A `conditional-endorsement-series-triple-record` ({{triple-ces}}) is transformed into an `evs-item` ({{fig-evs}}) as described in {{algo-ces-transform}}.
(The code reuses the `mm_to_em` and `mms_to_ems` functions from {{algo-mm-to-em}}.)

~~~ pseudocode
FUNC transform(
    T: conditional-endorsement-series-triple-record,
    signer: [ + $crypto-key-type-choice ],
    profile: $profile-type-choice
) -> evs-item {
    item := evs-item::NEW()

    item.addition.cmtype = endorsements

    item.condition.environment = T.condition.environment

    item.condition.element-list = mms_to_ems(T.condition.claims-list)

    IF T.condition.authorized-by:
        item.condition.authority = T.condition.authorized-by

    FOREACH s in T.series:
        item.series.selection.environment = T.condition.environment
        se := mm_to_em(s.selection)
        item.series.selection.element-list::APPEND(se)

        item.series.addition.environment = T.condition.environment
        ae := mm_to_em(s.addition)
        item.series.addition.element-list::APPEND(ae)

    item.series.addition.authority = signer

    IF profile:
        item.series.addition.profile = profile

    RETURN item
}
~~~
{: #algo-ces-transform title="Conditional Endorsement Series Triple Transformation"}

##### Keys

Keys transformation involves mapping Attest Key and Device Identity triples into into a `key` relation (see {{sec-ir-keys}}).

An `attest-key-triple-record` ({{triple-ak}}) or an `identity-triple-record` ({{triple-di}}) is transformed into a `key-item` ({{fig-k}}) as described in {{algo-key-transform}}.

~~~ pseudocode
FUNC transform(
    T: attest-key-triple-record / identity-triple-record,
    verifier: [ + $crypto-key-type-choice ],
    profile: $profile-type-choice
) -> key-item {
    item := key-item::NEW()

    IF TYPEOF(T) == attest-key-triple-record:
        item.addition.key-type = attest-key
        item.condition.key-type = attest-key
    ELIF TYPEOF(T) == identity-triple-record:
        item.addition.key-type = identity-key
        item.condition.key-type = identity-key

    item.condition.environment = T.environment
    item.addition.environment = T.environment

    item.condition.key-list = T.key-list

    IF T.conditions.mkey:
        item.condition.key-id = T.conditions.mkey
        item.addition.key-id = T.conditions.mkey

    IF T.conditions.authorized-by:
        item.condition.authority = T.conditions.authorized-by

    item.addition.authority = verifier

    IF profile:
        item.addition.profile = profile

    RETURN item
}
~~~
{: #algo-key-transform title="Key Triple Transformation"}

Note that keys are added under the authority of the verifier.

##### Domains

Domains transformation involves mapping Domain Membership and Domain Dependency triples into a `dm` or `dd` relation (see {{sec-ir-domains}}).

In any case, before being added to the respective relation, a `domain-membership-triple-record` ({{triple-dm}}) or a `domain-dependency-triple-record` ({{triple-dd}}) is transformed into a `domain-item` ({{fig-dm-item}}) as described in {{algo-domain-transform}}.

~~~ pseudocode
FUNC transform(
    T: domain-membership-triple-record / domain-dependency-triple-record
    signer: [ + $crypto-key-type-choice ],
    profile: $profile-type-choice
) -> domain-item {
    item := domain-item::NEW()

    IF TYPEOF(T) == domain-membership-triple-record:
        item.condition.kind = item.addition.kind = member
        item.condition.children = T.members
    ELIF TYPEOF(T) == domain-dependency-triple-record:
        item.condition.kind = item.addition.kind = trustee
        item.condition.children = T.trustees

    item.addition.environment = T.domain-id
    item.addition.authority = signer

    IF profile:
        item.addition.profile = profile

    RETURN item
}
~~~
{: #algo-domain-transform title="Domain Triple Transformation"}

#### Appraisal Context Initialization

At the end of Phase 1 all of the extracted and validated tags are loaded into an "appraisal context", consisting of the ACS and the staging area.
The ACS is initialized with all the addition ECTs in the `ev` relation:

~~~ pseudocode
FUNC init_acs(ae: ae) -> ACS {
    FOREACH item IN ae:
        acs::APPEND(item.addition)

    RETURN acs
}
~~~
{: #algo-init-acs title="ACS Initialization"}

The staging area is loaded with `rv`, `ev`, `evs`, `keys`, `dm` and `dd` relations, in that order.

~~~ pseudocode
FUNC init_staging_area(
    rv: rv,
    ev: ev,
    evs: evs,
    keys: keys,
    dm: dm,
    dd: dd,
) -> StagingArea {
    sa := StagingArea::NEW()

    IF rv    sa::APPEND(rv)
    IF ev:   sa::APPEND(ev)
    IF evs:  sa::APPEND(evs)
    IF keys: sa::APPEND(keys)
    IF dm:   sa::APPEND(dm)
    IF dd:   sa::APPEND(dd)

    RETURN sa
}
~~~
{: #algo-init-sa title="Staging Area Initialization"}

### ACS Augmentation (Phases 2, 3 and 4) {#sec-match-and-augment}

This section describes the "match and augment" algorithm, through which the ACS is updated incrementally to reflect the actual state of the Attester.

At a high level, the process involves pulling relations from the staging area one by one, in a specific order, and matching their conditions against the current state of the ACS according to the matching rules defined for each relation.
If there is a match, the additions in the matched relation are added to the ACS, thereby providing its "augmentation".
Otherwise, the algorithm moves on to the next relation.
Any augmentations to the ACS (i.e., the `acs::APPEND` operation in {{algo-match-and-augment}}) MUST be atomic.
Once all the relations in the staging area have been processed, the algorithm terminates and the computed ACS is handed over to the subsequent appraisal phases by the CoRIM processor.

~~~ pseudocode
FUNC match_and_augment(acs: ACS, sa: StagingArea) -> ACS {
    FOREACH rel IN sa:
        FOREACH item IN rel:
            IF acs::MATCH(item.condition):
                acs::APPEND(item.addition)

    RETURN acs
}
~~~
{: #algo-match-and-augment title="Match and Augment Algorithm"}

The `acs::MATCH` operation depends on the type of relation.
The matching logic for each type of relation is described in the following sections.
The `acs::APPEND` operation also depends on the type of relation.
This could involve simply appending the addition ECT, or it could be a more complex operation involving further manipulation of the addition ECT before appending (see {{sec-proc-rv}} for an example of the latter).

#### Ordering of Relations

The order in which items within relations are processed is important.
Processing a relation may result in ACS modifications that affect the matching behaviour of other relations.
The verifier MUST ensure that any relation including a matching condition is processed after any other relation that modifies or adds an ACS entry with an `environment` matching the condition.
This can be achieved by sorting the relations before processing, repeating the processing of some relations after ACS modifications, or using other algorithms.
The "match and augment" algorithm described in {{algo-match-and-augment}} assumes that relations have been topologically sorted prior to loading into the staging area ({{algo-init-sa}}).

#### Reference Values Corroboration and Augmentation (Phase 3) {#sec-proc-rv}

Corroboration is the process of determining whether actual Attester state (as contained in the ACS) can be satisfied by Reference Values.

##### Processing `rv` Relations

Reference Values are matched with ACS entries by iterating through the `rv` list.
For each `rv` entry, the condition ECT is compared against an ACS ECT with `cmtype` 2 (i.e., `evidence`).

If the two match, the following two steps are performed:

1. The `element-list` of the matched ACS ECT is copied to the `element-list` of the addition ECT.
1. The addition ECT is added to the ACS.

Note that this new ACS item is essentially a copy of the matched evidence ECT, which has been re-asserted under the authority of the Reference Value Provider.

#### Endorsed Values Augmentation (Phase 4)

Endorsed values augmentation is the process of adding Claims about the Attester's actual state with Endorser authority rather than Attester authority.
Augmentation is predicated on a certain condition matching the actual state currently encoded in the ACS.

##### Processing `ev` Relations

Endorsed Values and Conditional Endorsed Values are matched with ACS entries by iterating through the `ev` list.
For each `ev` entry, the condition ECT is compared with an ACS ECT with `cmtype` 0, 1 or 2 (i.e., reference-values, endorsements or evidence).
If the two match, the addition ECT is added to the ACS.

<cref>
[TBC]
Original text also states: "Some condition values can match against multiple ACS-ECTs, or sets of ACS-ECTs. If there are multiple matches, then each match is processed independently from the others."  Why should add exact copies of the same addition ECT?  Is there any specific semantics associated with clones?
</cref>

##### Processing `evs` Relations

Conditional Endorsement Series are matched with ACS entries by iterating through the `evs` list.
For each `evs` entry, the condition ECT is compared with an ACS ECT with `cmtype` 0, 1 or 2 (i.e. reference values, endorsements or evidence).
If they match, the `evs` series array is iterated.
For each series entry, if the selection ECT matches an ACS ECT, the addition ECT is added to the ACS.
Series iteration terminates either when the first matching series entry has been processed, or when no series entries match.

##### Processing `keys` Relations

Keys relations identify cryptographic keys that require additional key verification steps.

Keys are matched with ACS entries by iterating through the `keys` list.
For each `keys` entry, the condition ECT is compared with an ACS ECT with `cmtype` 1 or 2 (i.e., endorsements or evidence).
If they match, perform the following steps for each key in the condition ECT `key-list`:

1. Verify the certificate signatures for each certificate in the certification path.
1. Verify the revocation status for each certificate in the certification path.
1. Verify the key usage restrictions that are appropriate for `key-type`.

A key that successfully passes the above checks is said to be verified.

Add all the verified keys to the addition ECT's `key-list` and add the addition ECT to the ACS.

##### Processing `dm` Relations {#sec-proc-dm}

Domain Membership relations describe the expected topological arrangement of the Attester.

Domains are matched with ACS entries by iterating through the `dm` list.

The following algorithm assumes that the graph described by the condition ECTs in the `dm` relation is acyclic.
It also assumes that the `dm-item`s in the `dm` relation are topologically sorted (bottom up, from leaves to root).
This allows the algorithm to execute in one pass.

For each `dm` entry, the condition ECT is compared with either an ACS Element ECT with `cmtype` 2 (i.e., evidence) or a Domain ECT with `kind` 0 (i.e., member).
All other ECTs are ignored.

If all the `children` environments in the condition ECT have a matching ECT in the ACS, the ECT addition is added to the ACS.
Otherwise, processing moves to processing the next `dm` entry.

##### Processing `dd` Relations {#sec-proc-dd}

Essentially, the objective of processing a `dd` relation is to verify that each edge in a domain dependency graph (DDG) has a corresponding edge in a domain membership graph (DMG).
(Note that DDGs need not be isomorphs of DMGs; they can be a subset.)

The same assumptions regarding acyclicity and pre-sorting of the relation items as in {{sec-proc-dm}} apply.

The matching logic needs to ensure that all the `dd` items can be paired with an existing Domain Membership ECT.
Pairing is successful if the `environment` and all the `children` in the condition ECT are found in the  `environment` or in the `children` of at least one Domain ECT with `kind` 0 (i.e., member).
If pairing is successful for all the items in the `dd` relation, the all the addition ECTs are added to the ACS.

If, in a later processing phase, an appraisal policy for trust dependency exists, the DDG can be further evaluated.
For example, a trust dependency policy might specify a strength of function requirement for how Evidence about a TE is integrity protected by its AE.

The subsequent Verifier stages or Relying Party processing of the ACS may be affected if domain dependency ECTs are not added to the ACS.
For example, trust in an ACS entry that depends on `trustee` ACS entries may not be considered.

#### Rules of Comparison {#sec-comparison-rules}

The matching component of the "match and augment" algorithm (see {{sec-match-and-augment}}) relies on a standardized set of comparison rules for ECTs.
These rules depend on the type of elements being compared.
This section provides a normative description of the rules for comparing ECT elements found in relation conditions (referred to as C-ECTs for the remainder of this text) with ECTs in the ACS (referred to as ACS-ECTs for the remainder of this text).

When comparing a C-ECT against the ACS, the processor iterates over all ACS entries and attempts to match the C-ECT with each ACS entry.
Typically, the comparison is between ECTs of the same type (i.e., Element ECTs are compared with Element ECTs, Key ECTs with Key ECTs and Domain ECTs with Domain ECTs).
However, ECTs of different types can sometimes be compared if the comparison is based on common attributes ({{fig-ect-common}}).
See {{sec-proc-dm}} for an example of this, where the `environment`s of `D-ECT`s and `E-ECT`s are compared.

Conceptually, the processor creates a "matched entries" set and populates it with all ACS entries that match the C-ECT.
If, after visiting all the entries in the ACS, the matched entries set is not empty, the C-ECT matches the ACS.
Conversely, if the matched entries set is empty, the C-ECT does not match the ACS.

If the C-ECT contains a profile and the profile defines an algorithm for a given codepoint, the processor MUST use the algorithm defined by the profile in comparisons involving that codepoint.
If the condition ECT contains a profile, but the profile does not define an algorithm for a particular codepoint, the processor MUST use the standard algorithm described in this document for comparisons involving that codepoint.

The specific comparisons performed depend on the type of relation being processed.
In general, the processor will perform comparisons based on `environment` (see {{sec-compare-environment}} and `authority` (see {{sec-compare-authority}}), as well as more specialized comparisons based on the type of ECT matched.
Element ECTs will match on `element-list` (see {{sec-compare-element-list}}), Key ECTs will match on `key-list` (<cref>[TODO]</cref>), and Domain ECTs will typically match on `children` (see {{sec-compare-environment}}).

<cref>
[TBC]
Are authority checks always carried out?
</cref>

Each of these comparisons compares one attribute in the C-ECT against the same attribute in the ACS-ECT.
If all the attributes match, the C-ECT matches the ACS-ECT.
If any attributes do not match, the C-ECT does not match the ACS-ECT.

##### Environment Comparison {#sec-compare-environment}

The processor MUST compare each attribute which is present in the C-ECT's `environment` with the corresponding attribute in the ACS-ECT's `environment` using binary comparison.
Before performing the binary comparison, the processor SHOULD convert the attributes in both `environment`s into a form that meets the CBOR core deterministic encoding requirements described in {{Section 4.2 of -cbor}}.

If all the attributes which are present in the C-ECT `environment` (e.g., `instance-id` or `group-id`) are also present in the ACS-ECT and are binary identical, the two environments match.
Otherwise, the environments do not match.

Any attribute that is present in the ACS-ECT but not in the C-ECT is ignored in the comparison.

##### Authority Comparison {#sec-compare-authority}

The comparison between a C-ECT's `authority` value and an ACS-ECT's `authority` value is as follows: if every entry in the C-ECT `authority` matches byte-by-byte an entry in the ACS-ECT `authority`, the authorities match.
Otherwise, the authorities do not match.

The order of the items within each `authority` does not affect the result of the comparison.

When comparing two `$crypto-key-type-choice` items for equality, the processor MUST treat them as equal if their deterministic CBOR encoding is binary equal.

##### Element List Comparison {#sec-compare-element-list}

A C-ECT's `element-list` matches an ACS-ETC's `element-list` if all the `element-map`s in the C-ECT's `element-list` match the `element-map`s in the ACS-ECT's `element-list`.

Any `element-map` that is present in the ACS-ECT's `element-list` but not in the C-ECT's is ignored in the comparison.

The rules for matching `element-map`s are described in {{sec-compare-element-map}}.

##### Element Map Comparison {#sec-compare-element-map}

The C-ECT's `element-map` matches an ACS-ECT's `element-map` if both the `element-id` and `element-claims` match.

Two `element-id`s are considered the same if they are either both omitted, or both present with binary identical deterministic encodings.
Before performing the binary comparison, the processor SHOULD convert the `element-id` attributes into a form that meets the CBOR core deterministic encoding requirements described in {{Section 4.2 of -cbor}}.

The rules for matching `element-claims` are described in {{sec-compare-mvm}}.

##### Measurement Values Map Comparison {#sec-compare-mvm}

The C-ECT's `element-claims` match an ACS-ECT's `element-claims` if:

1. Each attribute in the C-ECT's `measurement-values-map` is also present in the ACS-ECT's `measurement-values-map`; and
1. The attribute values match.

Otherwise, the element claims do not match.

The rules for matching a single `measurement-values-map` attribute are described in {{sec-match-one-codepoint}}

###### Comparison of a Single Measurement Values Map Attribute {#sec-match-one-codepoint}

The algorithm used to compare two values of a `measurement-values-map` attribute depends on the attribute's type.

The processor needs to select the appropriate algorithm for the given attribute, including any extensions defined by a supported profile.

Non-negative codepoints represent standard data representations.
The comparison algorithms for these are defined in this document (in the sections below) or in other specifications.
Some attributes allow different types.
These are designated by a CBOR tag that allows clear type disambiguation.

Negative codepoints represent profile-defined data representations.
The processor MUST use the attribute name, the profile associated with the condition ECT, and, if present, the CBOR tag value to select the comparison algorithm.

If the processor is unable to determine the applicable comparison algorithm for an attribute, it MUST behave as though the C-ECT does not match the ACS-ECT.

Profile writers SHOULD use CBOR tags for widely applicable comparison methods to ease Verifier implementation compliance across profiles.
<cref>
[TBC]
Unclear what this recommendation aims to achieve.
</cref>

The following subsections define the comparison algorithms for the `measurement-values-map` attributes defined by this specification.

###### Comparison for version entries

The value stored under `measurement-values-map` codepoint 0 is of type `version-map`.

Since, in general - with the exception of `semver` - they are colloquial versions that cannot specify ordering, two `version-map` values can only be compared for equality.

###### Comparison for svn entries

The value stored under `measurement-values-map` codepoint 1 is a security version number of type `svn-type-choice`.

If the ACS-ECT's `svn-type-choice` is a `svn` or `tagged-svn` (i.e., `uint` or a `uint` wrapped in tag 552), comparison with the `uint` in the C-ECT is as follows:

* If the C-ECT value is of type `svn` or `tagged-svn`, an equality comparison is performed on the `uint` components.
The comparison MUST return true if the `uint` values are equal.

* If the C-ECT value is of type `tagged-min-svn`, a minimum comparison is performed.
The comparison MUST return true if the `uint` value in the C-ECT is less than or equal to the value in the ACS-ECT.

If the ACS-ECT's `svn-type-choice` is `tagged-min-svn` (i.e., `uint` wrapped in tag 553), then comparison with the `uint` in the C-ECT is as follows.

*  If the C-ECT value for `measurement-values-map` codepoint 1 is `svn` or `tagged-svn` (i.e., `uint` or a `uint` wrapped in tag 552), the comparison is not allowed and MUST return false.

*  If the condition ECT value for `measurement-values-map` codepoint 1 is a `tagged-min-svn` (i.e., `uint` wrapped in tag 553), an equality comparison is performed.
The comparison MUST return true if the `uint` values are equal.

A minimum SVN is only meaningful as an entry value when it is an endorsed value that has been added to the ACS.
The condition therefore treats the minimum SVN as an exact state, rather than as something to be compared with inequality.

The pseudocode for the above algorithm is shown in {{fig-comp-svn}}.

~~~ pseudocode
FUNC compare(
    c_ect: svn-type-choice,
    acs_ect: svn-type-choice
) -> bool {
    IF is_plain_svn(acs_ect):
        IF is_plain_svn(c_ect):
            RETURN get_svn_value(c_ect) == get_svn_value(acs_ect)
        ELSE:
            RETURN get_svn_value(c_ect) <= get_svn_value(acs_ect)
    ELSE:
        IF is_plain_svn(c_ect):
            RETURN false
        ELSE:
            RETURN get_svn_value(c_ect) == get_svn_value(acs_ect)
}

FUNC get_svn_value(v: svn-type-choice) -> uint {
    IF TYPEOF(v) == svn:
        RETURN v
    ELIF TYPEOF(v) == tagged-svn:
        RETURN ~v
    ELIF TYPEOF(v) == tagged-min-svn:
        RETURN ~v
}

FUNC is_plain_svn(v: svn-type-choice) -> bool {
    RETURN TYPEOF(v) == svn OR TYPEOF(v) == tagged-svn
}
~~~
{: #fig-comp-svn title="SVN Comparison"}

###### Comparison for digests entries {#sec-cmp-digests}

A `digests` entry contains one or more digests, each measuring the same object.
When multiple digests are provided, each represents a different acceptable algorithm to the C-ECT author.

In the simplest case, a C-ECT `digests` entry containing one digest matches an ACS-ECT entry containing a single entry with the same algorithm and value.

If there are multiple algorithms in common between the C-ECT and ACS-ECT, the bytes paired with common algorithms MUST be equal.
This is to prevent downgrade attacks.
The processor MUST treat two algorithm identifiers as equal if they have the same deterministic binary encoding.
If both an integer and a string representation are defined for an algorithm, then entities creating ECTs SHOULD use the integer representation.
If C-ECT and ACS-ECT use different names for the same algorithm, and the processor does not recognize that they are the same, then a downgrade attack is possible.

The comparison MUST return false if the CBOR encoding of the `digests` entry in the C-ECT or the ACS-ECT value with the same codepoint is incorrect.
For example, if fields are missing or if they are the wrong type.

The comparison MUST return false if the C-ECT `digests` entry does not contain any digests.

The comparison MUST return false if either `digests` entry contains multiple values for the same hash algorithm.

The processor iterates over the C-ECT `digests` array to locate the common hash algorithm identifiers which are present in both the C-ECT and in the ACS-ECT.
The comparison MUST return false if there are no hash algorithms in common between the C-ECT and the ACS-ECT.
The comparison MUST return false if the value associated with any common hash algorithm identifier in the C-ECT differs from the value for the same algorithm identifier in the ACS-ECT.
If all the values associated with the common hash algorithm identifiers match, the comparison returns true.

###### Comparison for raw-value entries

A `raw-value` entry contains binary data.

The value stored under `measurement-values-map` codepoint 4 in an ACS-ECT MUST be a `raw-value` entry, which MUST be `tagged-bytes`.

The value stored under the C-ECT `measurement-values-map` codepoint 4 may additionally be a `tagged-masked-raw-value` entry, which specifies an expected value and a mask.

If the C-ECT `measurement-value-map` codepoint 4 is of type `tagged-bytes`, and there is no value stored under codepoint 5, the processor treats it as if it were a `tagged-masked-raw-value` with the `value` field holding the same contents and a `mask` of the same length as the value, with all bits set.
The standard comparison function defined in this document removes the CBOR tag before performing the comparison.

For backwards compatibility, if the C-ECT `measurement-value-map` codepoint 4 is of type `tagged-bytes`, and there is a mask stored under codepoint 5, the processor treats it as a `tagged-masked-raw-value` with the `value` field holding the same contents and a `mask` holding the contents of codepoint 5.

The comparison MUST return false if the lengths of the ACS-ECT entry value and the C-ECT value are different.

The comparison MUST return false if the lengths of the C-ECT mask and value are different.

The comparison MUST use the mask to determine which bits to compare.
If a bit in the mask is 0 then this indicates that the corresponding bit in the ACS-ECT value is ignored.

The comparison returns true if, for every bit position in the mask whose value is 1, the corresponding bits in both values are equal.

###### Comparison for cryptokeys entries {#sec-cryptokeys-matching}

The CBOR tag of the first entry in the C-ECT `cryptokeys` array is compared with the CBOR tag of the first entry of the ACS-ECT `cryptokeys` value.
If the CBOR tags match, then the bytes following the CBOR tag from the C-ECT entry are compared byte-by-byte with the bytes following the CBOR tag from the ACS-ECT entry.
If the byte strings match and there are more array entries, the next C-ECT array entry is compared with the next ACS-ECT array entry.
If all the C-ECT array entries match their corresponding entries in the ACS-ECT array, the C-ECT `cryptokeys` match.
Otherwise, the C-ECT `cryptokeys` do not match.

###### Comparison for Integrity Registers {#sec-cmp-integrity-registers}

For each Integrity Register entry in the C-ECT, the processor will use the associated identifier (i.e., `integrity-register-id-type-choice`) to look up the matching Integrity Register entry in the ACS-ECT.
If no matching entry is found, the comparison MUST return false.
Instead, if an entry is found, the digest comparison proceeds as defined in {{sec-cmp-digests}} after equivalence has been established according to {{sec-comid-integrity-registers}}.
Note that it is not required for all the entries in the C-ECT to be used during matching: the C-ECT may represent only a subset of the device's register space.
In TPM parlance, a TPM "quote" may report all PCRs in Evidence, while a C-ECT could describe a subset of PCRs.

###### Comparison for int-range entries

The ACS-ECT value stored under `measurement-values-map` codepoint 15 is an int range value of `int-range-type-choice`.

Consider an `int` ACS-ECT value named ENTRY in a `measurement-values-map` codepoint (e.g., 15) that allows comparing `int` against a either another `int` or an `int-range` named CONDITION.

*  If CONDITION is an `int` then an equality comparison is performed with ENTRY.

*  If CONDITION is an `int-range` (CBOR tag 564), then a range inclusion comparison is performed.
The comparison MUST return true if and only if all the following conditions are true:
    + CONDITION.min is `null` or ENTRY is greater than or equal to CONDITION.min.
    + CONDITION.max is `null` or ENTRY is less than or equal to CONDITION.max.

Consider an `int-range` (CBOR tag 564) value named ENTRY in a `measurement-values-map` codepoint (e.g., 15) that allows comparing an `int-range` against either another `int-range` or an `int` named CONDITION.

*  If CONDITION is an `int`, then the comparison MUST return true if and only if ENTRY.min and ENTRY.max are both equal to CONDITION.

*  If CONDITION is an `int-range` (CBOR tag 564), then a range subsumption comparison is performed (i.e., the condition range includes all values of the entry range).
The comparison MUST return true if and only if all the following conditions are true:
    + CONDITION.min is `null` or ENTRY.min is an `int` that is greater than or equal to CONDITION.min
    + CONDITION.max is `null` or ENTRY.max is an `int` that is less than or equal to CONDITION.max.

##### Profile-directed Comparison {#sec-compare-profile}

A profile MUST specify comparison algorithms for its additions to `$`-prefixed CoRIM CDDL codepoints when this specification does not prescribe binary comparison.
The profile MUST specify how to compare the CBOR tagged value against the ACS.

Note that the processor may compare Reference Values in any order, so the comparison SHOULD NOT be stateful.

### Handoff

Once all the relations in the staging area have been processed, the computed ACS is ready to be handed over to the verifier for further processing in subsequent phases.
Typically, the ACS is passed to a policy engine that applies a policy to deduce high-level characteristics of the Attester from the low-level information contained in the ACS.
This information can then be encoded in an Attestation Result that can be understood by a Relying Party, which does not need to know all the details in order to make a trust decision.

### Example Appraisal

<cref>
[TODO] Simple example appraisal with input ae, rv and ev and expected ACS evolution through phases.
Use PSA evidence, ref values and certification endorsemnts.
</cref>

# Implementation Status

This section records the status of known implementations of the protocol
defined by this specification at the time of posting of this Internet-Draft,
and is based on a proposal described in {{RFC7942}}. The description of
implementations in this section is intended to assist the IETF in its decision
processes in progressing drafts to RFCs.  Please note that the listing of any
individual implementation here does not imply endorsement by the IETF.
Furthermore, no effort has been spent to verify the information presented here
that was supplied by IETF contributors.  This is not intended as, and must not
be construed to be, a catalogue of available implementations or their features.
Readers are advised to note that other implementations may exist.

According to {{RFC7942}}, "this will allow reviewers and working groups to
assign due consideration to documents that have the benefit of running code,
which may serve as Evidence of valuable experimentation and feedback that have
made the implemented protocols more mature.  It is up to the individual working
groups to use this information as they see fit".

## Veraison

* Organization responsible for the implementation: Veraison Project, Linux
  Foundation

* Implementation's web page:
  [https://github.com/veraison/corim/README.md](https://github.com/veraison/corim/blob/main/README.md)

* Brief general description: There are three CoRIM libraries under project Veraison.
  1. [CoRIM golang library](https://github.com/veraison/corim) The `corim/corim` and `corim/comid` packages
  provide a golang API for low-level manipulation of Concise Reference
  Integrity Manifest (CoRIM) and Concise Module Identifier (CoMID) tags
  respectively.
  2. [CoRIM rust library](https://github.com/veraison/corim-rs) provide a rust implementation of
  CoRIM specification.
  3. [CoRIM Processor](https://github.com/veraison/cover) provides a library for appraisal of Evidence by processing CoRIMs as outlined in {{sec-corim-processor}} of this specification.

  In addition to the base CoRIM Libraries, the [cocli package](https://github.com/veraison/cocli) uses the golang API above (as well as the
  API from the `veraison/swid` package) to provide a user command line
  interface for working with CoRIM, CoMID and CoSWID. Specifically, it allows
  creating, signing, verifying, displaying, uploading, and more. See
  [https://github.com/veraison/cocli/README.md](https://github.com/veraison/cocli/README.md) for further details.

* Implementation's level of maturity: alpha.

* Coverage: the whole protocol is implemented, including PSA-specific
  extensions {{-psa-endorsements}}.

* Version compatibility: Version -06 of the draft

* Licensing: Apache 2.0
  [https://github.com/veraison/corim/blob/main/LICENSE](https://github.com/veraison/corim/blob/main/LICENSE)

* Implementation experience: n/a

* Contact information:
  [https://veraison.zulipchat.com](https://veraison.zulipchat.com)

* Last updated:
  [https://github.com/veraison/corim/commits/main](https://github.com/veraison/corim/commits/main)
  [https://github.com/veraison/corim-rs/commits/master/](https://github.com/veraison/corim-rs/commits/master/)
  [https://github.com/veraison/cover/commits/main/](https://github.com/veraison/cover/commits/main/)


# Security and Privacy Considerations {#sec-sec}

Evidence appraisal is at the core of any RATS protocol flow, mediating all interactions between Attesters and their Relying Parties.
The Verifier is effectively part of the Attesters' and Relying Parties' trusted computing base (TCB).
Any mistake in the appraisal procedure conducted by the Verifier could have security implications.
For instance, it could lead to the subversion of an access control function, which creates a chance for privilege escalation.

Therefore, the Verifier’s code and configuration, especially those of the CoRIM processor, are primary security assets that must be built and maintained as securely as possible.

The protection of the Verifier system should be considered throughout its entire lifecycle, from design to operation.
This includes the following aspects:

- Minimizing implementation complexity (see also {{Section 6.1 of -rats-endorsements}});
- Using memory-safe programming languages;
- Using secure defaults;
- Minimizing the attack surface by avoiding unnecessary features that could be exploited by attackers;
- Applying the principle of least privilege to the system's users;
- Minimizing the potential impact of security breaches by implementing separation of duties in both the software and operational architecture;
- Conducting regular, automated audits and reviews of the system, such as ensuring that users' privileges are correctly configured and that any new code has been audited and approved by independent parties;
- Failing securely in the event of errors to avoid compromising the security of the system.

It is critical that appraisal procedures are auditable and reproducible.
The integrity of code and data during execution is an explicit objective, for example, ensuring that the appraisal functions are executed in an attestable trusted execution environment (TEE).

Please review the Security and Privacy Considerations in {{Sections 8 and 9 of -rats-endorsements}}; these considerations apply to this document as well.

# IANA Considerations {#sec-iana-cons}

## New COSE Header Parameters


## New CBOR Tags {#sec-iana-cbor-tags}

IANA is requested to allocate the following tags in the "CBOR Tags" registry {{!IANA.cbor-tags}}, preferably with the specific CBOR tag value requested:

|     Tag | Data Item           | Semantics                                                     | Reference |
|     --- | ---------           | ---------                                                     | --------- |
|     500 | `tag`               | Reserved for backward compatibility                   | {{&SELF}} |
|     501 | `map`               | A tagged-unsigned-corim-map, see {{sec-corim-map}}            | {{&SELF}} |
| 502-504 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |
|     505 | `bytes`             | A tagged-concise-swid-tag, see {{sec-corim-tags}}             | {{&SELF}} |
|     506 | `bytes`             | A tagged-concise-mid-tag, see {{sec-corim-tags}}              | {{&SELF}} |
|     507 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |
|     508 | `bytes`             | A tagged-concise-tl-tag, see {{sec-corim-tags}}              | {{&SELF}} |
| 509-549 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |
|     550 | `bytes .size (7..33)` | tagged-ueid-type, see {{sec-common-ueid}}                     | {{&SELF}} |
|     552 | `uint`              | tagged-svn, see {{sec-comid-svn}}                             | {{&SELF}} |
|     553 | `uint`              | tagged-min-svn, see {{sec-comid-svn}}                         | {{&SELF}} |
|     554 | `text`              | tagged-pkix-base64-key-type, see {{sec-crypto-keys}}          | {{&SELF}} |
|     555 | `text`              | tagged-pkix-base64-cert-type, see {{sec-crypto-keys}}         | {{&SELF}} |
|     556 | `text`              | tagged-pkix-base64-cert-path-type, see {{sec-crypto-keys}}    | {{&SELF}} |
|     557 | `[int/text, bytes]` | tagged-key-thumbprint-type, see {{sec-common-hash-entry}}     | {{&SELF}} |
|     558 | `COSE_Key`          | tagged-cose-key-type, see {{sec-crypto-keys}}                 | {{&SELF}} |
|     559 | `digest`            | tagged-cert-thumbprint-type, see {{sec-crypto-keys}}          | {{&SELF}} |
|     560 | `bytes`             | tagged-bytes, see {{sec-common-tagged-bytes}}                 | {{&SELF}} |
|     561 | `digest`            | tagged-cert-path-thumbprint-type, see {{sec-crypto-keys}}     | {{&SELF}} |
|     562 | `bytes`             | tagged-pkix-asn1der-cert-type, see {{sec-crypto-keys}}        | {{&SELF}} |
|     563 | `tagged-masked-raw-value` | tagged-masked-raw-value, see {{sec-comid-raw-value-types}} | {{&SELF}} |
|     564 | `array`             | tagged-int-range, see {{sec-comid-int-range}}                   | {{&SELF}} |
| 565-599 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |

Tags designated as "Earmarked for CoRIM" can be reassigned by IANA based on advice from the designated expert for the CBOR Tags registry.

## CoRIM Map Registry {#sec-iana-corim}

This document defines a new registry titled "CoRIM Map".
The registry uses integer values as index values for items in `corim-map` CBOR maps.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range             | Registration Procedures
|---
| 0-127    | Standards Action
| 128-255  | Specification Required
{: #tbl-iana-corim-map-items-reg-procedures title="CoRIM Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoRIM Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name | Specification
|---
| 0 | id | {{&SELF}}
| 1 | tags | {{&SELF}}
| 2 | dependent-rims | {{&SELF}}
| 3 | profile | {{&SELF}}
| 4 | rim-validity | {{&SELF}}
| 5 | entities | {{&SELF}}
| 3-255 | Unassigned
{: #tbl-iana-corim-map-items title="CoRIM Map Items Initial Registrations"}

## CoRIM Entity Map Registry {#sec-iana-corim-entity-map}

This document defines a new registry titled "CoRIM Entity Map".
The registry uses integer values as index values for items in `corim-entity-map` CBOR maps.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range             | Registration Procedures
|---
| 0-127    | Standards Action
| 128-255  | Specification Required
{: #tbl-iana-corim-entity-map-items-reg-procedures title="CoRIM Entity Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoRIM Entity Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name | Value Type | Specification
|---
| 0     | entity-name | `text` | Name of the entity responsible for the actions of the role. |
| 1     | reg-id      | `uri`  | A URI associated with the organization that owns the entity name. |
| 2     | role        | `[ + role-type-choice ]` | A type choice defining the roles that the entity is claiming. |
| 3-255 | Unassigned
{: #tbl-iana-corim-entity-map-items title="CoRIM Entity Map Items Initial Registrations"}

## CoRIM Signer Map Registry {#sec-iana-corim-signer-map}

This document defines a new registry titled "CoRIM Signer Map".
The registry uses integer values as index values for items in `corim-signer-map` CBOR maps.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range             | Registration Procedures
|---
| 0-127    | Standards Action
| 128-255  | Specification Required
{: #tbl-iana-corim-signer-map-items-reg-procedures title="CoRIM Signer Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoRIM Signer Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name | Specification
|---
| 0 | signer-name   | {{&SELF}}
| 1 | signer-uri    | {{&SELF}}
| 2-255             | Unassigned
{: #tbl-iana-corim-signer-map-items title="CoRIM Signer Map Items Initial Registrations"}


## CoMID Map Registry {#sec-iana-comid}

This document defines a new registry titled "CoMID Map".
The registry uses integer values as index values for items in `concise-mid-tag` CBOR maps.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range             | Registration Procedures
|---
| 0-127    | Standards Action
| 128-255  | Specification Required
{: #tbl-iana-comid-map-items-reg-procedures title="CoMID Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoMID Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name | Specification
|---
| 0 | language | {{&SELF}}
| 1 | tag-identity | {{&SELF}}
| 2 | entity | {{&SELF}}
| 3 | linked-tags | {{&SELF}}
| 4 | triples | {{&SELF}}
| 5-255 | Unassigned
{: #tbl-iana-comid-map-items title="CoMID Map Items Initial Registrations"}

## CoMID Entity Map Registry {#sec-iana-comid-entity-map}

This document defines a new registry titled "CoRIM Entity Map".
The registry uses integer values as index values for items in `corim-entity-map` CBOR maps.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range             | Registration Procedures
|---
| 0-127    | Standards Action
| 128-255  | Specification Required
{: #tbl-iana-comid-entity-map-items-reg-procedures title="CoMID Entity Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoMID Entity Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name | Value Type | Specification
|---
| 0     | entity-name | `text` | Name of the entity responsible for the actions of the role. |
| 1     | reg-id      | `uri`  | A URI associated with the organization that owns the entity name. |
| 2     | role        | `[ + role-type-choice ]` | A type choice defining the roles that the entity is claiming. |
| 3-255 | Unassigned
{: #tbl-iana-comid-entity-map-items title="CoMID Entity Map Items Initial Registrations"}

## CoMID Triples Map Registry {#sec-iana-triples-map}

This document defines a new registry titled "CoMID Triples Map".
The registry uses integer values as index values for items in the `triples-map` CBOR maps in `concise-mid-tag` codepoint 4.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range                      | Registration Procedures
| 0-1023                     | Standards Action
| 1024-65535                 | Specification Required
| 65536-18446744073709551616 | First come first served
{: #tbl-iana-comid-triples-map-items-reg-procedures title="CoMID Triples Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoMID Triples Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name                              | Specification |
|---
| 0     | reference-triples                      | {{&SELF}}     |
| 1     | endorsed-triples                       | {{&SELF}}     |
| 2     | identity-triples                       | {{&SELF}}     |
| 3     | attest-key-triples                     | {{&SELF}}     |
| 4     | dependency-triples                     | {{&SELF}}     |
| 5     | membership-triples                     | {{&SELF}}     |
| 6     | coswid-triples                         | {{&SELF}}     |
| 7     | (reserved)                             | {{&SELF}}     |
| 8     | conditional-endorsement-series-triples | {{&SELF}}     |
| 9     | (reserved)                             | {{&SELF}}     |
| 10    | conditional-endorsement-triples        | {{&SELF}}     |
| 11-18446744073709551616 | Unassigned | |
{: #tbl-iana-triples-map-items title="CoMID Triples Map Items Initial Registrations"}

## CoMID Measurement Values Map Registry {#sec-iana-comid-measurement-values-map}

This document defines a new registry titled "CoMID Measurement Values Map".
The registry uses integer values as index values for items in multiple triples' representations.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range                      | Registration Procedures
| 0-1023                     | Standards Action
| 1024-65535                 | Specification Required
| 65536-18446744073709551616 | First come first served
{: #tbl-iana-comid-measurement-values-map-items-reg-procedures title="CoMID Measurement Values Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoMID Measurement Values Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name                 | Specification |
|---
| 0     | version                   | {{&SELF}}     |
| 1     | svn                       | {{&SELF}}     |
| 2     | digests                   | {{&SELF}}     |
| 3     | flags                     | {{&SELF}}     |
| 4     | raw-value                 | {{&SELF}}     |
| 5     | raw-value-mask-DEPRECATED | {{&SELF}}     |
| 6     | mac-addr                  | {{&SELF}}     |
| 7     | ip-addr                   | {{&SELF}}     |
| 8     | serial-number             | {{&SELF}}     |
| 9     | ueid                      | {{&SELF}}     |
| 10    | uuid                      | {{&SELF}}     |
| 11    | name                      | {{&SELF}}     |
| 12    | (reserved)                | {{&SELF}}     |
| 13    | cryptokeys                | {{&SELF}}     |
| 14    | integrity-registers       | {{&SELF}}     |
| 15    | int-range                 | {{&SELF}}     |
| 16-18446744073709551616 | Unassigned | |
{: #tbl-iana-comid-measurement-values-map-items title="Measurement Values Map Items Initial Registrations"}

## CoMID Flags Map Registry {#sec-iana-comid-flags-map}

This document defines a new registry titled "CoMID Flags Map".
The registry uses integer values as index values for items in `measurement-values-map` codepoint 3.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range                      | Registration Procedures
| 0-1023                     | Standards Action
| 1024-65535                 | Specification Required
| 65536-18446744073709551616 | First come first served
{: #tbl-iana-comid-flags-map-items-reg-procedures title="CoMID Flags Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoMID Measurement Values Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name                    | Specification |
|---
| 0     | is-configured                | {{&SELF}}     |
| 1     | is-secure                    | {{&SELF}}     |
| 2     | is-recovery                  | {{&SELF}}     |
| 3     | is-debug                     | {{&SELF}}     |
| 4     | is-replay-protected          | {{&SELF}}     |
| 5     | is-integrity-protected       | {{&SELF}}     |
| 6     | is-runtime-meas              | {{&SELF}}     |
| 7     | is-immutable                 | {{&SELF}}     |
| 8     | is-tcb                       | {{&SELF}}     |
| 9     | is-confidentiality-protected | {{&SELF}}     |
| 10-18446744073709551616 | Unassigned | |
{: #tbl-iana-comid-flags-map-items title="Flags Map Items Initial Registrations"}

## CoTL Map Registry {#sec-iana-cotl}

This document defines a new registry titled "CoTL Map".
The registry uses integer values as index values for items in 'concise-tl-tag' CBOR maps.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range             | Registration Procedures
|---
| 0-127    | Standards Action
| 128-255  | Specification Required
{: #tbl-iana-cotl-map-items-reg-procedures title="CoTL Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoTL Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name | Specification
|---
| 0 | tag-identity | {{&SELF}}
| 1 | tags-list | {{&SELF}}
| 2 | tl-validity | {{&SELF}}
| 3-255 | Unassigned
{: #tbl-iana-tl-map-items title="CoTL Map Items Initial Registrations"}

## New Media Types {#sec-iana-media-types}

IANA is requested to add the following media types to the "Media Types"
registry {{!IANA.media-types}}.

| Name | Template | Reference |
| rim+cbor | application/rim+cbor | {{&SELF}}, ({{sec-mt-rim-cbor}}) |
| rim+cose | application/rim+cose | {{&SELF}}, ({{sec-mt-rim-cose}}) |
{: #tbl-media-type align="left" title="New Media Types"}

### rim+cbor {#sec-mt-rim-cbor}

{:compact}
Type name:
: `application`

Subtype name:
: `rim+cbor`

Required parameters:
: n/a

Optional parameters:
: "profile" (CoRIM profile in string format.  OIDs MUST use the dotted-decimal
  notation.)

Encoding considerations:
: binary

Security considerations:
: {{sec-sec}} of {{&SELF}}

Interoperability considerations:
: n/a

Published specification:
: {{&SELF}}

Applications that use this media type:
: Attestation Verifiers, Endorsers and Reference-Value providers that need to
  transfer unprotected CoRIM payloads over HTTP(S), CoAP(S), and other
  transports.

Fragment identifier considerations:
: n/a

Magic number(s):
: `D9 01 F5`

File extension(s):
: .corim

Macintosh file type code(s):
: n/a

Person and email address to contact for further information:
: RATS WG mailing list (rats@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration?
: Maybe

### rim+cose {#sec-mt-rim-cose}

{:compact}
Type name:
: `application`

Subtype name:
: `rim+cose`

Required parameters:
: n/a (cose-type is explicitly not supported, as it is understood to be "cose-sign1")

Optional parameters:
: "profile" (CoRIM profile in string format.  OIDs MUST use the dotted-decimal
  notation.)

Encoding considerations:
: binary

Security considerations:
: {{sec-sec}} of {{&SELF}}

Interoperability considerations:
: n/a

Published specification:
: {{&SELF}}

Applications that use this media type:
: Attestation Verifiers, Endorsers and Reference-Value providers that need to
  transfer CoRIM payloads protected using COSE Sign1 over HTTP(S), CoAP(S), and other
  transports.

Fragment identifier considerations:
: n/a

Magic number(s):
: `D2 84`

File extension(s):
: .corim

Macintosh file type code(s):
: n/a

Person and email address to contact for further information:
: RATS WG mailing list (rats@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration?
: Maybe

## CoAP Content-Formats Registration

IANA is requested to register the two following Content-Format numbers in the
"CoAP Content-Formats" sub-registry, within the "Constrained RESTful
Environments (CoRE) Parameters" Registry {{!IANA.core-parameters}}:

| Content-Type | Content Coding | ID | Reference |
|---
| application/rim+cbor | - | TBD1 | {{&SELF}} |
| application/rim+cose | - | TBD2 | {{&SELF}} |
{: align="left" title="New Content-Formats"}

--- back

# Base CoRIM CDDL {#sec-corim-cddl}

~~~ cddl
{::include-fold cddl/corim-autogen.cddl}
~~~

# Acknowledgments
{:unnumbered}

The authors would like to thank the following people for their review and comments on this document:
{{{Carl Wallace}}},
{{{Hannes Tschofenig}}},
{{{Steven Bellock}}},
{{{Jag Raman}}},
{{{Giri Mandyam}}},
{{{Jeremy O'Donoghue}}},
and
{{{Michael Richardson}}}.

[^revise]: (This content needs to be revised. Consider removing for now and
    replacing with an issue.)

[^todo]: (Needed content missing. Consider adding an issue into the tracker)

[^issue]: Content missing. Tracked at:

[^tracked-at]: Tracked at:


