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
  tocdepth: 6

author:
- ins: H. Birkholz
  name: Henk Birkholz
  org: Fraunhofer SIT
  email: henk.birkholz@sit.fraunhofer.de
- ins: T. Fossati
  name: Thomas Fossati
  organization: arm
  email: Thomas.Fossati@arm.com
- ins: Y. Deshpande
  name: Yogesh Deshpande
  organization: arm
  email: yogesh.deshpande@arm.com
- ins: N. Smith
  name: Ned Smith
  org: Intel
  email: ned.smith@intel.com
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

normative:
  RFC4122: uuid
  RFC7468: pkix-text
  RFC8610: cddl
  RFC9090: cbor-oids
  STD96:
    -: cose
    =: RFC9052
  STD94:
    -: cbor
    =: RFC8949
  STD66:
    -: uri
    =: RFC3986
  I-D.ietf-sacm-coswid: coswid
  RFC9334: rats-arch
  I-D.ietf-rats-eat: eat
  I-D.ietf-rats-concise-ta-stores: ta-store
  IANA.language-subtag-registry: language-subtag
  X.690:
    title: >
      Information technology — ASN.1 encoding rules:
      Specification of Basic Encoding Rules (BER), Canonical Encoding
      Rules (CER) and Distinguished Encoding Rules (DER)
    author:
      org: International Telecommunications Union
    date: 2015-08
    seriesinfo:
      ITU-T: Recommendation X.690
    target: https://www.itu.int/rec/T-REC-X.690
  IANA.named-information: named-info


informative:
  RFC7942:
  I-D.fdb-rats-psa-endorsements: psa-endorsements
  I-D.tschofenig-rats-psa-token: psa-token
  DICE.Layer:
    title: DICE Layering Architecture
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.0, Revision 0.19
    date: July 2020
    target: https://trustedcomputinggroup.org/wp-content/uploads/DICE-Layering-Architecture-r19_pub.pdf

entity:
  SELF: "RFCthis"

--- abstract

Remote Attestation Procedures (RATS) enable Relying Parties to assess the
trustworthiness of a remote Attester and therefore to decide whether to engage
in secure interactions with it. Evidence about trustworthiness can be rather
complex and it is deemed unrealistic that every Relying Party is capable of the
appraisal of Evidence. Therefore that burden is typically offloaded to a
Verifier. In order to conduct Evidence appraisal, a Verifier requires not only
fresh Evidence from an Attester, but also trusted Endorsements and Reference
Values from Endorsers and Reference Value Providers, such as manufacturers,
distributors, or device owners. This document specifies the information elements for
representing Endorsements and Reference Values in CBOR format.

--- middle

# Introduction

In order to conduct Evidence appraisal, a Verifier requires not only fresh Evidence from an Attester, but also trusted Endorsements (e.g., test results or certification data) and Reference Values (e.g., the version or digest of a firmware component) associated with the Attester.
Such Endorsements and Reference Values are obtained from the relevant supply chain actors, such as manufacturers, distributors, or device owners.
In a complex supply chain, it is likely that multiple actors will produce these values at different points in time.
Besides, one supply chain actor will only provide the subset of characteristics that they know about the Attester.
Attesters vary from one vendor to another, and for a given vendor from one product to another.
Not only Attesters can evolve and therefore new measurement types need to be expressed, but an Endorser may also want to provide new security relevant attributes about an Attester at a future point in time.

This document specifies Concise Reference Integrity Manifests (CoRIM) a CBOR {{-cbor}} based data model addressing the above challanges by using an extensible format common to all supply chain actors and Verifiers.
CoRIM enables Verifiers to reconcile a complex and scattered supply chain into a single homogeneous view.

## Terminology and Requirements Language

This document uses terms and concepts defined by the RATS architecture.
For a complete glossary see {{Section 4 of -rats-arch}}.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}.

{::boilerplate bcp14}

## CDDL Typographical Conventions

The CDDL definitions in this document follow the naming conventions illustrated
in {{tbl-typography}}.

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
{: #tbl-typography title="Type Traits & Typographical Conventions"}

## Common Types

The following CDDL types are used in both CoRIM and CoMID.

### Non-Empty

The `non-empty` generic type is used to express that a map with only optional
members MUST at least include one of the members.

~~~~ cddl
{::include cddl/non-empty.cddl}
~~~~

### Entity {#sec-common-entity}

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

* `entity-name` (index 0): The name of entity which is responsible for the
  action(s) as defined by the role. `$entity-name-type-choice` can only be
  text.  Other specifications can extend the `$entity-name-type-choice` (see
  {{sec-iana-comid}}).

* `reg-id` (index 1): A URI associated with the organization that owns the
  entity name

* `role` (index 2): A type choice defining the roles that the entity is
  claiming.  The role is supplied as a parameter at the time the `entity-map`
  generic is instantiated.

* `extension-socket`: A CDDL socket used to add new information structures to
  the `entity-map`.

Examples of how the `entity-map` generic is instantiated can be found in
{{sec-corim-entity}} and {{sec-comid-entity}}.

### Validity {#sec-common-validity}

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

### UUID {#sec-common-uuid}

Used to tag a byte string as a binary UUID defined in {{Section 4.1.2. of
-uuid}}.

~~~ cddl
{::include cddl/uuid.cddl}
~~~

### UEID {#sec-common-ueid}

Used to tag a byte string as Universal Entity ID Claim (UUID) defined in
{{Section 4.2.1 of -eat}}.

~~~ cddl
{::include cddl/ueid.cddl}
~~~

### OID {#sec-common-oid}

Used to tag a byte string as the BER encoding {{X.690}} of an absolute object
identifier {{-cbor-oids}}.

~~~ cddl
{::include cddl/oid.cddl}
~~~

### Tagged Integer Type {#sec-common-tagged-int}

Used as a class identifier for the environment.  It is expected that the
integer value is vendor specific rather than globally meaningful.  Therefore,
the sibling `vendor` field in the `class-map` MUST be populated to define the
namespace under which the value must be understood.

~~~ cddl
{::include cddl/tagged-int.cddl}
~~~

### Digest {#sec-common-hash-entry}

A digest represents the value of a hashing operation together with the hash
algorithm used.  The type of the digest algorithm identifier can be either
`int` or `text`.  When carried as an integer value, it is interpreted according
to the "Named Information Hash Algorithm Registry" {{-named-info}}.
When it is carried as `text`, there are no requirements with regards to its
format.  In general, the `int` encoding is RECOMMENDED.  The `text` encoding
should only be used when the `digest` type conveys reference value
measurements that are matched verbatim with Evidence that uses the same
convention - e.g., {{Section 4.4.1.5 of -psa-token}}).

~~~ cddl
{::include cddl/digest.cddl}
~~~

# Concise Reference Integrity Manifest (CoRIM) {#sec-corim}

A CoRIM is a collection of tags and related metadata as described below.

Tags can be of different types:

* Concise Module ID (CoMID) tags ({{sec-comid}}) contain metadata and claims about the hardware and firmware modules.

* Concise Software ID (CoSWID) tags {{-coswid}} describe software components.

* Concise Bill of Material (CoBOM) tags ({{sec-cobom}}) contain the list of CoMID and CoSWID tags that the Verifier should consider as "active" at a certain point in time.

The set of tags is extensible so that future specifications can add new kinds of information.
For example, Concise Trust Anchor Stores (CoTS) {{-ta-store}} is currently being defined as a standard CoRIM extension.

Each CoRIM contains a unique identifier to distinguish a CoRIM from other CoRIMs.
[^tracked-at] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/73

CoRIM can also carry the following optional metadata:

* A locator, which allows discovery of possibly related RIMs

* A profile identifier, which is used to interpret the information contained in the enclosed tags. A profile allows the base CoRIM schema to be customised to fit a specific Attester.  For example, see {{-psa-endorsements}}.

* A validity period, which indicates the time period for which the CoRIM contents are valid.

* Information about the supply chain entities responsible for the contents of the CoRIM and their associated roles.

A CoRIM can be signed ({{sec-corim-signed}}) using COSE Sign1 to provide end-to-end security to the CoRIM contents.
When CoRIM is signed, the protected header carries further identifying information about the CoRIM signer.
Alternatively, CoRIM can be encoded as a CBOR-tagged payload ({{sec-corim-map}}) and transported over a secure channel.

The following CDDL describes the top-level CoRIM.

~~~ cddl
{::include cddl/corim.cddl}
~~~

## CoRIM Map {#sec-corim-map}

The CDDL specification for the `corim-map` is as follows and this rule and its
constraints must be followed when creating or validating a CoRIM map.

~~~ cddl
{::include cddl/corim-map.cddl}
~~~

The following describes each child item of this map.

* `id` (index 0): A globally unique identifier to identify a CoRIM. Described
  in {{sec-corim-id}}

* `tags` (index 1):  An array of one or more CoMID or CoSWID tags.  Described
  in {{sec-corim-tags}}

* `dependent-rims` (index 2): One or more services supplying additional,
  possibly dependent, manifests or related files. Described in
  {{sec-corim-locator-map}}

* `profile` (index 3): An optional profile identifier for the tags contained in
  this CoRIM.  The profile MUST be understood by the CoRIM processor.  Failure
  to recognize the profile identifier MUST result in the rejection of the
  entire CoRIM.  If missing, the profile defaults to DICE.
  Described in {{sec-corim-profile-types}}

* `rim-validity` (index 4): Specifies the validity period of the CoRIM.
  Described in {{sec-common-validity}}

* `entities` (index 5): A list of entities involved in a CoRIM life-cycle.
  Described in {{sec-corim-entity}}

* `$$corim-map-extension`: This CDDL socket is used to add new information
  structures to the `corim-map`.  See {{sec-iana-corim}}.

~~~ cddl
{::include cddl/tagged-corim-map.cddl}
~~~

### Identity {#sec-corim-id}

A CoRIM Identifier uniquely identifies a CoRIM instance. The base schema allows UUID and text
identifiers. Other types of identifiers could be defined as needed.

~~~ cddl
{::include cddl/corim-id-type-choice.cddl}
~~~

### Tags {#sec-corim-tags}

A `$concise-tag-type-choice` is a tagged CBOR payload that carries either a
CoMID ({{sec-comid}}), a CoSWID {{-coswid}}, or a CoBOM {{sec-cobom}}.

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

* `href` (index 0): URI identifying the additional resource that can be fetched

* `thumbprint` (index 1): expected digest of the resource referenced by `href`.
  See {{sec-common-hash-entry}}.

### Profile Types {#sec-corim-profile-types}

Profiling is the mechanism that allows the base CoRIM schema to be customised to fit a specific Attester.

A profile defines which of the optional parts of a CoRIM are required,
which are prohibited and which extension points are exercised and how.
A profile MUST NOT alter the syntax or semantics of a standard CoRIM type.
A profile MAY constrain the values of a given CoRIM type to a subset of the values.
A profile MAY extend the set of a given CoRIM type using the defined extension points (see {{sec-extensibility}}).
Exercised extension points should preserve the intent of the original semantics.

CoRIM profiles SHOULD be specified in a publicly available document.

A CoRIM profile can use one of the base CoRIM media types defined in {{sec-mt-corim-signed}} and
{{sec-mt-corim-unsigned}} with the `profile` parameter set to the appropriate value.
Alternatively, it MAY define and register its own media type.

A profile identifier is either an OID {{-cbor-oids}} or a URL {{-uri}}.

The profile identifier uniquely identifies a documented profile.  Any changes
to the profile, even the slightest deviation, is considered a different profile
that MUST have a different identifier.

~~~ cddl
{::include cddl/profile-type-choice.cddl}
~~~

### Entities {#sec-corim-entity}

The CoRIM Entity is an instantiation of the Entity generic
({{sec-common-entity}}) using a `$corim-role-type-choice`.

The only role defined in this specification for a CoRIM Entity is
`manifest-creator`.

The `$$corim-entity-map-extension` extension socket is empty in this
specification.

~~~ cddl
{::include cddl/corim-entity-map.cddl}

{::include cddl/corim-role-type-choice.cddl}
~~~

## Signed CoRIM {#sec-corim-signed}

~~~ cddl
{::include cddl/signed-corim.cddl}
~~~

Signing a CoRIM follows the procedures defined in CBOR Object Signing and
Encryption {{-cose}}. A CoRIM tag MUST be wrapped in a COSE_Sign1 structure.
The CoRIM MUST be signed by the CoRIM creator.

The following CDDL specification defines a restrictive subset of COSE header
parameters that MUST be used in the protected header alongside additional
information about the CoRIM encoded in a `corim-meta-map` ({{sec-corim-meta}}).

~~~ cddl
{::include cddl/cose-sign1-corim.cddl}
~~~

The following describes each child element of this type.

* `protected`: A CBOR Encoded protected header which is protected by the COSE
  signature. Contains information as given by Protected Header Map below.

* `unprotected`: A COSE header that is not protected by COSE signature.

* `payload`: A CBOR encoded tagged CoRIM.

* `signature`: A COSE signature block which is the signature over the protected
  and payload components of the signed CoRIM.

### Protected Header Map

~~~ cddl
{::include cddl/protected-corim-header-map.cddl}
~~~

The following describes each child item of this map.

* `alg-id` (index 1): An integer that identifies a signature algorithm.

* `content-type` (index 3): A string that represents the "MIME Content type"
  carried in the CoRIM payload.

* `issuer-key-id` (index 4): A bit string which is a key identity pertaining to
  the CoRIM Issuer.

* `corim-meta` (index 8): A map that contains metadata associated with a
  signed CoRIM. Described in {{sec-corim-meta}}.

Additional data can be included in the COSE header map as per {{Section 3 of
-cose}}.

### Meta Map {#sec-corim-meta}

The CoRIM meta map identifies the entity or entities that create and sign the
CoRIM. This ensures the consumer is able to identify credentials used to
authenticate its signer.

~~~ cddl
{::include cddl/corim-meta-map.cddl}
~~~

The following describes each child item of this group.

* `signer` (index 0): Information about the entity that signs the CoRIM.
  Described in {{sec-corim-signer}}

* `signature-validity` (index 1): Validity period for the CoRIM. Described in
  {{sec-common-validity}}

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


# Concise Module Identifier (CoMID) {#sec-comid}

A CoMID tag contains information about hardware, firmware, or module composition.

Each CoMID has a unique ID that is used to unambigously identify CoMID instances when cross referencing CoMID tags, for example in typed link relations, or in a CoBOM tag.

A CoMID defines several types of Claims, using "triples" semantics.

At a high level, a triple is a statement that links a subject to an object via a predicate.
CoMID triples typically encode assertions made by the CoRIM author about Attesting or Target Environments and their security features, for example measurements, cryptographic key material, etc.

The set of triples is extensible.
The following triples are currently defined:

* Reference Values triples: containing Reference Values that are expected to match Evidence for a given Target Environment ({{sec-comid-triple-refval}}).
* Endorsed Values triples: containing "Endorsed Values", i.e., features about an Environment that do not appear in Evidence. Specific examples include testing or certification data pertaining to a module ({{sec-comid-triple-endval}}).
* Device Identity triples: containing cryptographic credentials - for example, an IDevID - uniquely identifying a device ({{sec-comid-triple-identity}}).
* Attestation Key triples: containing cryptographic keys that are used to verify the integrity protection on the Evidence received from the Attester ({{sec-comid-triple-attest-key}}).
* Domain dependency triples: describing trust relationships between domains, i.e., collection of related environments and their measurements ({{sec-comid-triple-domain-dependency}}).
* Domain membership triples: describing topological relationships between (sub-)modules. For example, in a composite Attester comprising multiple sub-Attesters (sub-modules), this triple can be used to define the topological relationship between lead- and sub- Attester environments ({{sec-comid-triple-domain-membership}}).
* CoMID-CoSWID linking triples: associating a Target Environment with existing CoSWID tags ({{sec-comid-triple-coswid}}).

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
  identification information for the CoMID. Described in {{sec-comid-tag-id}}.

* `entities` (index 2): Provides information about one or more organizations
  responsible for producing the CoMID tag. Described in {{sec-comid-entity}}.

* `linked-tags` (index 3): A list of one or more `linked-tag-map` (described in
  {{sec-comid-linked-tag}}), providing typed relationships between this and
  other CoMIDs.

* `triples` (index 4): One or more triples providing information specific to
  the described module, e.g.: reference or endorsed values, cryptographic
  material, or structural relationship between the described module and other
  modules.  Described in ({{sec-comid-triples}}).

### Tag Identity {#sec-comid-tag-id}

~~~ cddl
{::include cddl/tag-identity-map.cddl}
~~~

The following describes each member of the `tag-identity-map`.

* `tag-id` (index 0): A universally unique identifier for the CoMID. Described
  in {{sec-tag-id}}.

* `tag-version` (index 1): Optional versioning information for the `tag-id` .
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

The CoMID Entity is an instantiation of the Entity generic
({{sec-common-entity}}) using a `$comid-role-type-choice`.

The `$$comid-entity-map-extension` extension socket is empty in this
specification.

~~~ cddl
{::include cddl/comid-role-type-choice.cddl}
~~~

The roles defined for a CoMID entity are:

* `tag-creator` (value 0): creator of the CoMID tag.

* `creator` (value 1): original maker of the module described by the CoMID tag.

* `maintainer` (value 2): an entity making changes to the module described by
  the CoMID tag.

### Linked Tag {#sec-comid-linked-tag}

The linked tag map represents a typed relationship between the embedding CoMID
tag (the source) and another CoMID tag (the target).

~~~ cddl
{::include cddl/linked-tag-map.cddl}
~~~

The following describes each member of the `tag-identity-map`.

* `linked-tag-id` (index 0): Unique identifier for the target tag.  For the
  definition see {{sec-tag-id}}.

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

~~~ cddl
{::include cddl/triples-map.cddl}
~~~

The following describes each member of the `triples-map`:

* `reference-triples` (index 0): Triples containing reference values. Described
  in {{sec-comid-triple-refval}}.

* `endorsed-triples` (index 1): Triples containing endorsed values. Described
  in {{sec-comid-triple-endval}}.

* `identity-triples` (index 2): Triples containing identity credentials.
  Described in {{sec-comid-triple-identity}}.

* `attest-key-triples` (index 3): Triples containing verification keys
  associated with attesting environments. Described in
  {{sec-comid-triple-attest-key}}.

* `dependency-triples` (index 4): Triples describing trust relationships
  between domains.  Described in {{sec-comid-triple-domain-dependency}}.

* `membership-triples` (index 5): Triples describing topological relationships
  between (sub-)modules.  Described in {{sec-comid-triple-domain-membership}}.

* `coswid-triples` (index 6): Triples associating modules with existing CoSWID
  tags. Described in {{sec-comid-triple-coswid}}.

* `conditional-endorsement-series-triples` (index 8) Triples describing a series of
  conditional Endorsements based on the acceptance of a stateful environment. Described
  in {{sec-comid-triple-cond-series}}.

* `conditional-endorsement-triples` (index 9) Triples describing conditional
  Endorsement based on the acceptance of a stateful environment. Described
  in {{sec-comid-triple-cond-end}}.

#### Common Types

##### Environment

An `environment-map` may be used to represent a whole Attester, an Attesting
Environment, or a Target Environment.  The exact semantic depends on the
context (triple) in which the environment is used.

An environment is named after a class, instance or group identifier (or a
combination thereof).

~~~ cddl
{::include cddl/environment-map.cddl}
~~~

The following describes each member of the `environment-map`:

* `class` (index 0): Contains "class" attributes associated with the module.
  Described in {{sec-comid-class}}.

* `instance` (index 1): Contains a unique identifier of a module's instance.
  See {{sec-comid-instance}}.

* `group` (index 2): identifier for a group of instances, e.g., if an
  anonymization scheme is used.

##### Class {#sec-comid-class}

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
  Typically, `class-id` is an object identifier (OID) or universally unique
  identifier (UUID). Use of this attribute is preferred.

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

##### Instance {#sec-comid-instance}

An instance carries a unique identifier that is reliably bound to an instance
of the Attester.

The types defined for an instance identifier are UEID or UUID.

~~~ cddl
{::include cddl/instance-id-type-choice.cddl}
~~~

##### Group

A group carries a unique identifier that is reliably bound to a group of
Attesters, for example when a number of Attester are hidden in the same
anonymity set.

The type defined for a group identified is UUID.

~~~ cddl
{::include cddl/group-id-type-choice.cddl}
~~~

##### Measurements

Measurements can be of a variety of things including software, firmware,
configuration files, read-only memory, fuses, IO ring configuration, partial
reconfiguration regions, etc. Measurements comprise raw values, digests, or
status information.

An environment has one or more measurable elements. Each element can have a
dedicated measurement or multiple elements could be combined into a single
measurement. Measurements can have class, instance or group scope.  This is
typically determined by the triple's environment.

Class measurements apply generally to all the Attesters in the given class.
Instance measurements apply to a specific Attester instances.  Environments
identified by a class identifier have measurements that are common to the
class. Environments identified by an instance identifier have measurements that
are specific to that instance.

~~~ cddl
{::include cddl/measurement-map.cddl}
~~~

The following describes each member of the `measurement-map`:

* `mkey` (index 0): An optional unique identifier of the measured
  (sub-)environment.  See {{sec-comid-mkey}}.

* `mval` (index 1): The measurements associated with the (sub-)environment.
  Described in {{sec-comid-mval}}.

###### Measurement Keys {#sec-comid-mkey}

The types defined for a measurement identifier are OID, UUID or uint.

~~~ cddl
{::include cddl/measured-element-type-choice.cddl}
~~~

###### Measurement Values {#sec-comid-mval}

A `measurement-values-map` contains measurements associated with a certain
environment. Depending on the context (triple) in which they are found,
elements in a `measurement-values-map` can represent class or instance
measurements. Note that some of the elements have instance scope only.

~~~ cddl
{::include cddl/measurement-values-map.cddl}
~~~

The following describes each member of the `measurement-values-map`.

* `version` (index 0): Typically changes whenever the measured environment is
  updated. Described in {{sec-comid-version}}.

* `svn` (index 1): The security version number typically changes only when a
  security relevant change is made to the measured environment.  Described in
  {{sec-comid-svn}}.

* `digests` (index 2): Contains the digest(s) of the measured environment
  together with the respective hash algorithm used in the process.  See
  {{sec-common-hash-entry}}.

* `flags` (index 3): Describes security relevant operational modes. For
  example, whether the environment is in a debug mode, recovery mode, not fully
  configured, not secure, not replay protected or not integrity protected. The
  `flags` field indicates which operational modes are currently associated with
  measured environment.  Described in {{sec-comid-flags}}.

* `raw-value` (index 4): Contains the actual (not hashed) value of the element.
  An optional `raw-value-mask` (index 5) indicates which bits in the
  `raw-value` field are relevant for verification. A mask of all ones ("1")
  means all bits in the `raw-value` field are relevant. Multiple values could
  be combined to create a single `raw-value` attribute. The vendor determines
  how to pack multiple values into a single `raw-value` structure. The same
  packing format is used when collecting Evidence so that Reference Values and
  collected values are bit-wise comparable. The vendor determines the encoding
  of `raw-value` and the corresponding `raw-value-mask`.

* `mac-addr` (index 6): A EUI-48 or EUI-64 MAC address associated with the
  measured environment.  Described in {{sec-comid-address-types}}.

* `ip-addr` (index 7): An IPv4 or IPv6 address associated with the measured
  environment.  Described in {{sec-comid-address-types}}.

* `serial-number` (index 8): A text string representing the product serial
  number.

* `ueid` (index 9): UEID associated with the measured environment.  See
  {{sec-common-ueid}}.

* `uuid` (index 10): UUID associated with the measured environment.  See
  {{sec-common-uuid}}.

* `name` (index 11): a name associated with the measured environment.

###### Version {#sec-comid-version}

A `version-map` contains details about the versioning of a measured
environment.

~~~ cddl
{::include cddl/version-map.cddl}
~~~

The following describes each member of the `version-map`:

* `version` (index 0): the version string

* `version-scheme` (index 1): an optional indicator of the versioning
  convention used in the `version` attribute.  Defined in {{Section 4.1 of
  -coswid}}.  The CDDL is copied below for convenience.

~~~ cddl
$version-scheme /= &(multipartnumeric: 1)
$version-scheme /= &(multipartnumeric-suffix: 2)
$version-scheme /= &(alphanumeric: 3)
$version-scheme /= &(decimal: 4)
$version-scheme /= &(semver: 16384)
$version-scheme /= int / text
~~~

###### Security Version Number {#sec-comid-svn}

The following details the security version number (`svn`) and the minimum security version number (`min-svn`) statements.
A security version number is used to track changes to an object (e.g., a secure enclave, a boot loader executable, a configuration file, etc.) that are security relevant.
Rollback of a security relevant change is considered to be an attack vector, as such, security version numbers can't be decremented.
If a security relevant flaw is discovered in the Target Environment and subsequently fiexed, the `svn` value is typically incremented.

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

###### Flags {#sec-comid-flags}

The `flags-map` measurement describes a number of boolean operational modes.
If a `flags-map` value is not specified, then the operational mode is unknown.

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
protected from replay by a previous image that differs from the current image.

* `is-integrity-protected` (index 5): If the flag is true, the measured environment is
protected from unauthorized update.

* `is-runtime-meas` (index 6): If the flag is true, the measured environment is measured
after being loaded into memory.

* `is-immutable` (index 7): If the flag is true, the measured environment is immutable.

* `is-tcb` (index 8): If the flag is true, the measured environment is a trusted
computing base.

###### Raw Values Types {#sec-comid-raw-value-types}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/9

~~~ cddl
{::include cddl/raw-value.cddl}
~~~

###### Address Types {#sec-comid-address-types}

The types or associating addressing information to a measured environment are:

~~~ cddl
{::include cddl/ip-addr-type-choice.cddl}

{::include cddl/mac-addr-type-choice.cddl}
~~~

##### Crypto Keys {#sec-crypto-keys}

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
  Defined in {{Section 7 of -cose}}

A cryptographic key digest can be one of the following formats:

* `tagged-thumbprint-type`: a `digest` of a raw public key. The digest value may
  be used to find the public key if contained in a lookup table.

* `tagged-cert-thumbprint-type`: a `digest` of a certificate.
  The digest value may be used to find the certificate if contained in a lookup table.

* `tagged-cert-path-thumbprint-type`: a `digest` of a certification path.
  The digest value may be used to find the certificate path if contained in a lookup table.

In a split Verifier scenario, a first Verifier may verify the signature of a cryptographic key
then compute a digest of the key that is forwarded to a second Verifier. The second Verifier
completes the signature verification by performing certificate path validation, revocation
checks, and trust anchor checks.

~~~ cddl
{::include cddl/crypto-key-type-choice.cddl}
~~~

##### Domain Types {#sec-comid-domain-type}

A domain is a context for bundling a collection of related environments and
their measurements.

Three types are defined: uint and text for local scope, UUID for global scope.

~~~ cddl
{::include cddl/domain-type-choice.cddl}
~~~

#### Reference Values Triple {#sec-comid-triple-refval}

A Reference Values triple relates reference measurements to a Target
Environment. For Reference Value Claims, the subject identifies a Target
Environment, the object contains measurements, and the predicate asserts that
these are the expected (i.e., reference) measurements for the Target
Environment.

~~~ cddl
{::include cddl/reference-triple-record.cddl}
~~~

#### Endorsed Values Triple {#sec-comid-triple-endval}

An Endorsed Values triple declares additional measurements that are valid when
a Target Environment has been verified against reference measurements. For
Endorsed Value Claims, the subject is either a Target or Attesting Environment,
the object contains measurements, and the predicate defines semantics for how
the object relates to the subject.

~~~ cddl
{::include cddl/endorsed-triple-record.cddl}
~~~

#### Device Identity Triple {#sec-comid-triple-identity}

A Device Identity triple relates one or more cryptographic keys to a device.
The subject of an Identity triple uses an instance or class identifier to refer
to a device, and a cryptographic key is the object. The predicate asserts that
the identity is authenticated by the key. A common application for this triple
is device identity.

~~~ cddl
{::include cddl/identity-triple-record.cddl}
~~~

#### Attestation Keys Triple {#sec-comid-triple-attest-key}

An Attestation Keys triple relates one or more cryptographic keys to an
Attesting Environment. The Attestation Key triple subject is an Attesting
Environment whose object is a cryptographic key. The predicate asserts that the
Attesting Environment signs Evidence that can be verified using the key.

~~~ cddl
{::include cddl/attest-key-triple-record.cddl}
~~~

#### Domain Dependency Triple {#sec-comid-triple-domain-dependency}

A Domain Dependency triple defines trust dependencies between measurement
sources.  The subject identifies a domain ({{sec-comid-domain-type}}) that has
a predicate relationship to the object containing one or more dependent
domains.  Dependency means the subject domain’s trustworthiness properties rely
on the object domain(s) trustworthiness having been established before the
trustworthiness properties of the subject domain exists.

~~~ cddl
{::include cddl/domain-dependency-triple-record.cddl}
~~~

#### Domain Membership Triple {#sec-comid-triple-domain-membership}

A Domain Membership triple assigns domain membership to environments.  The
subject identifies a domain ({{sec-comid-domain-type}}) that has a predicate
relationship to the object containing one or more environments.  Endorsed
environments ({{sec-comid-triple-endval}}) membership is conditional upon
successful matching of Reference Values ({{sec-comid-triple-refval}}) to
Evidence.

~~~ cddl
{::include cddl/domain-membership-triple-record.cddl}
~~~

#### CoMID-CoSWID Linking Triple {#sec-comid-triple-coswid}

A CoSWID triple relates reference measurements contained in one or more CoSWIDs
to a Target Environment. The subject identifies a Target Environment, the
object one or more unique tag identifiers of existing CoSWIDs, and the
predicate asserts that these contain the expected (i.e., reference)
measurements for the Target Environment.

~~~ cddl
{::include cddl/coswid-triple-record.cddl}
~~~

#### Conditional Endorsement Series Triple {#sec-comid-triple-cond-series}

A Conditional Endorsement Series triple uses a stateful environment, (i.e., `stateful-environment-record`),
that identifies a Target Environment based on an `environment-map` plus the `measurement-map` measurements
that have matching Evidence.

The stateful Target Environment is a triple subject that MUST be satisfied before the series triple object is
matched.

~~~ cddl
{::include cddl/stateful-environment-record.cddl}
~~~

The series object is an array of `conditional-series-record` that has both Reference and Endorsed Values.
Each `conditional-series-record` record is evaluated in the order it appears in the series array.
The Endorsed Values are accepted if the Reference Values in a `conditional-series-record` matches Evidence.
The first `conditional-series-record` that sucessfully matches Evidence terminates the series and
the matching Reference Values as well as the Endorsed Values are accepted.
If none of the Reference Values in the series match Evidence, the triple is not matched,
and no Claims are accepted.

The `authorized-by` value in `measurement-map` in the stateful environment, if present,
applies to all measurements in the triple, including `conditional-series-record` records.

~~~ cddl
{::include cddl/conditional-endorsement-series-triple-record.cddl}
~~~

~~~ cddl
{::include cddl/conditional-series-record.cddl}
~~~

#### Conditional Endorsement Triple {#sec-comid-triple-cond-end}

A Conditional Endorsement triple uses a stateful environment, (i.e., `stateful-environment-record`),
that identifies a Target Environment based on an `environment-map` plus the `measurement-map` measurements
that have matching Evidence.

The stateful Target Environment is a triple subject that MUST be satisfied before the Endorsed Values in the triple object are accepted.

~~~ cddl
{::include cddl/stateful-environment-record.cddl}
~~~

The `authorized-by` value in `measurement-map` in the stateful environment, if present,
applies to all measurements in the triple, including those in `measurement-values-map`.

~~~ cddl
{::include cddl/conditional-endorsement-triple-record.cddl}
~~~

## Extensibility {#sec-extensibility}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/10

# CoBOM {#sec-cobom}

A Concise Bill of Material (CoBOM) object represents the signal for the
Verifier to activate the listed tags. Data contained in a tag MUST NOT be used
for appraisal until a CoBOM which activates that tag has been received and
successfully processed. All the tags listed in the CoBOM must be activated in
the same transaction, i.e., either all or none.

## Structure

The CDDL specification for the `concise-bom-tag` map is as follows and this
rule and its constraints MUST be followed when creating or validating a CoBOM
tag:

~~~ cddl
{::include cddl/concise-bom-tag.cddl}
~~~

The following describes each member of the `concise-bom-tag` map.

* `tag-identity` (index 0): A `tag-identity-map` containing unique
  identification information for the CoBOM. Described in {{sec-comid-tag-id}}.

* `tags-list` (index 1): A list of one or more `tag-identity-maps` identifying
  the CoMID and CoSWID tags that constitute the "bill of material", i.e.,
  a complete set of verification-related information.  The `tags-list` behaves
  like a signaling mechanism from the supply chain (e.g., a product vendor) to
  a Verifier that activates the tags in `tags-list` for use in the Evidence
  appraisal process. The activation is atomic: all tags listed in `tags-list`
  MUST be activated or no tags are activated.

* `bom-validity` (index 2): Specifies the validity period of the CoBOM.
  Described in {{sec-common-validity}}

* `$$concise-bom-tag-extension`: This CDDL socket is used to add new
  information structures to the `concise-bom-tag`.  See {{sec-iana-cobom}}.
  The `$$concise-bom-tag-extension` extension socket is empty in this
  specification.

# CoRIM-based Evidence Verification

The verification procedure is divided into three separate phases:

* Appraisal Context initialisation
* Evidence collection
* Evidence appraisal

At a few well-defined points in the procedure, the Verifier behaviour will
depend on the specific CoRIM profile.
Each CoRIM profile MUST provide a description of the expected Verifier behavior
for each of those well-defined points.

Note that what follows describes a simplified and standard algorithm.
Verifiers claiming compliance with this specification MUST exhibit the same
externally visible behavior as described here,
they are not required to use the same internal data structures.
For example, it is expected that the resources used during the initialisation
phase can be amortised across multiple appraisals.

## Appraisal Context initialisation

The goal of the initialisation phase is to load the CoRIM Appraisal Context
with objects such as tags (CoMID, CoSWID, etc.) from CoRIM files,
cryptographic validation key material (e.g., raw public keys, root certificates,
intermediate CA certificate chains), etc. that will be used in the subsequent
Evidence Appraisal phase.

### CoRIM Selection

All available CoRIMs are collected.
A Verifier may be pre-configured with a large number of CoRIMs describing many
types of device.
All CoRIMs are loaded at this stage, later stages will select the CoRIMs
appropriate to the Evidence Appraisal step.

CoRIMs that are not within their validity period, or that cannot be associated
with an authenticated and authorised source MUST be discarded.

CoRIM that are secured by a cryptographic mechanism such as a signature which
does not pass validation MUST be discarded.

Other selection criteria MAY be applied.

For example, if the Evidence format is known in advance, CoRIMs using a
profile that is not understood by a Verifier can be readily discarded.

The selection process MUST yield at least one usable tag.

### CoBOM Extraction

All the available Concise Bill Of Material (CoBOMs) tags are then collected
from the selected CoRIMs.

CoBOMs which are not within their validity period, or which reference tags
not available to the verifier, are discarded.

The Verifier MUST activate all tags referenced by a CoBOM.

ISSUE: What does the verifier do if there are multiple CoBOMs available

After the Verifier has processed all CoBOMs it MUST discard any tags which have
not been activated by a CoBOM.

### Tags Identification and Validation

The Verifier chooses tags -- including Concise Module ID Tags (CoMID, {{sec-comid}}),
Concise Software ID Tags (CoSWID, {{-coswid}}),
and/or Concise Trust Anchor Stores (CoTS, {{-ta-store}}) --
from the selected CoRIMs.

The Verifier MUST discard all tags which are not syntactically and semantically
valid.
In particular, any cross-referenced triples (e.g., CoMID-CoSWID linking triples)
MUST be successfully resolved.

### Appraisal Context Construction

All of the validated and potentially useful tags are loaded into the Appraisal Context.

[^issue]: Content missing. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/96

This concludes the initialisation phase.

## Evidence Collection

In the evidence collection phase the Verifier communicates with attesters to
collect evidence.

The first part of the Evidence collection phase does not perform any
cryptographic validation.
This allows Verifiers to use untrusted code for their initial Evidence collection.

The results of the evidence collection are protocol specific data and transcripts
which are used as input to appraisal by the Verifier.

### Cryptographic validation of Evidence

If the authenticity of Evidence is secured by a cryptographic mechanism such as
a signature, the first step in the Evidence Appraisal is to perform
cryptographic validation of the Evidence.

The exact cryptographic signature validation mechanics depend on the specific
Evidence collection protocol.

For example:
In DICE, a proof of liveness is performed on the final key in the certificate
chain.
If this passes then a suitable certification path anchored on a trusted root
certificate is looked up -- e.g., based on linking information obtained from
the DeviceID certificate (see Section 9.2.1 of {{DICE.Layer}}) --
in the Appraisal Context.  If found, then usual X.509 certificate validation
is performed.
In PSA, the verification public key is looked up in the appraisal context using
the `ueid` claim found in the PSA claims-set (see {{Section 4.2.1 of -psa-token}}).
If found, COSE Sign1 verification is performed accordingly.

Independent of the specific integrity protection method used, the integrity of
Evidence MUST be successfully verified.

> A CoRIM profile MUST describe:
>
> * How cryptographic verification key material is represented (e.g., using Attestation Keys triples, or CoTS tags)
> * How key material is associated with the Attesting Environment
> * How the Attesting Environment is identified in Evidence

### The Accepted Claims Set

At the end of the Evidence collection process evidence has been converted into
a format suitable for appraisal. To this end, this document describes an `accepted-claims-set`
format and the algorithms used to compare it against CoMID reference values.

~~~ cddl
{::include cddl/accepted-claims-set.cddl}
~~~

Verifiers are not required to use this as their internal state, but for the
purposes of this document a sample Verifier is discussed which uses this format.

The Accepted Claims Set will be matched against CoMID reference values, as per
the appraisal policy of the Verifier.
This document describes an example evidence structure which can be easily
matched against these reference values.

Each set of evidence contains an `environment-map` providing a namespace, and
a non empty `measurement-values-map`.

Each entry in the `measurement-values-map` is a separate piece of evidence
describing a measurement associated with the environment identified in
the `environment-map`.

An Attester can provide multiple `environment-map`s each containing a
`measurement-values-map` with one entry;  a single `environment-map` containing
multiple entries in its `measurement-values-map`; or a combination of
 these approaches.

If evidence from different sources has the same `environment-map` then the
`measurement-values-map`s are merged.

If the merged measurement-value-map contains duplicate codepoints and the
measurement values are equivalent, then duplicate claims SHOULD be omitted.
Equivalence typically means values MUST be binary identical.

If the merged measurement-value-map contains duplicate codepoints and the
measurement values are not equivalent then the verifier SHALL report
an error and stop validation processing.

### Accepted Claims Set Initialisation

The Accepted Claims Set is initialised with cryptographically verified Evidence
from the Attestation Environments.

> A CoRIM profile MUST describe:
>
> * How evidence is converted to a format suitable for appraisal

{{sec-dice-spdm}} provides information on how evidence collected using
DICE and SPDM is added to the Accepted Claims Map.

## Accepted Claims Map extension using CoMID tags

In the Accepted Claims Map extension phase, a CoRIM Appraisal Context and
an Evidence Appraisal Policy are used by the Verifier to find CoMID tags which
match the Attester. Tags which match are accepted, and the Accepted Claims Map
is extended using Endorsements etc. from the accepted tags.

[^issue]: Content missing. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71

### Comparing and processing CoMID tags

[^issue]: Content missing. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71

### Matching Evidence against Reference Values

An Endorser may use CoMID tags to publish Conditional Endorsements, which
are added to the Accepted Claims Set only if specified conditions apply.
This section describes the process performed by the Verifier to determine
which Conditional Endorsements from the candidate CoMIDs should be added
to the Accepted Claims Set.

The verifier checks whether Conditional Endorsements are applicable by
comparing Evidence in the Accepted Claims Set against Reference Values
from the CoMID. These Reference Values may be provided as Reference Value
Triples or may be combined with the Endorsements, for example as the
Conditional Endorsement Series Triple.

The following subsections describe how the CoRIM tells the verifier which
Reference Values and Endorsed Values are grouped together ({{sec-grouping-ref-vals}})
and how the verifier matches a Reference Value against the Accepted Claims Set
({{sec-match-all-ref-vals}}).

#### Grouping Reference Values and Endorsements {#sec-grouping-ref-vals}

> This paragraph will be replaced by a description of how the CoRIM tells the
verifier which Reference Values and Endorsements are grouped together.

[^issue]: Content missing. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/110

[^issue]: Need to describe how to match conditional endorsements. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/80

#### Matching all reference values in a group against the Accepted Claims Set {#sec-match-all-ref-vals}

If all Reference Values in a group match entries in the Accepted Claims Set
then all Endorsements in the group are added to the Accepted Claims Set
(see {{sec-add-to-acs}}). {{sec-match-one-ref-val}} describes how one
Reference Value is matched against the Accepted Claims Set.

If any Reference Value in a group does not match the Accepted Claims Set then
all Endorsements in the group are silently ignored.

Each group is processed independently of other groups. If a group fails to match
the Accepted Claims Set then this does not affect the processing of other groups.

#### Matching a Reference Value against the Accepted Claims Set {#sec-match-one-ref-val}

This section describes how a Reference Value is matched against Evidence in the Accepted
Claims Set.
If any part of the processing indicates that the Reference Value does not match then the remaining steps in this section are skipped for that group.

A Reference Value consists of an `environment-map` plus a `measurement-map`. In the
`reference-values-triple-record` these are packaged together. In other triples multiple
Reference Values are represented more compactly by letting one `environment-map`
apply to multiple `measurement-map`s.

The Verifier first looks for entries in the Accepted Claims Set with the same
`environment-map` as the Reference Value. If there are no such entries then
the Reference Value does not match.

A Verifier SHALL compare two `environment-map`s using a binary comparison of the CBOR
encoded objects.

A Verifier SHOULD convert `environment-map` into a form which meets CBOR Core
Deterministic Encoding Requirements before performing the binary comparison.

The Verifier SHALL iterate over the entries in the `measurement-values-map`
entry within the reference value `measurement-map`. Each entry is compared
against the `measurement-map` from the Accepted Claims Set. If any entry
does not match then the Reference Value does not match.

The algorithm used to match the `measurement-values-map` entries
is described below. It depends on whether the reference value is tagged with a
CBOR tag {{-cbor}},
and on the `measurement-values-map` key which identifies the entry.

If the Reference Value `measurement-values-map` value starts with a CBOR tag
then the Verifier MUST use the algorithm associated with that tag to match
the entries.

This specification defines the matching algorithm for some CBOR tagged reference
values, which is described in sub-sections below.

A CoRIM profile may define additional tags and their matching algorithms.

If the Verifier does not recognize the Reference Value CBOR tag value then
the Reference Value does not match.

If the Reference Value is not tagged and the measurement-value-map key is a
value with handling described in the sub-sections below,
then the algorithm appropriate to that key is used to match the entries.

If the Reference Value is not tagged, and the `measurement-values-map` key
is not a value described below, then the entries are compared
using binary comparison of their CBOR encoded values. If the values
are not binary identical then the Reference Value does not match.

Note that while specifications may extend the matching semantics using CBOR tags,
there is no way to extend the matching semantics of keys.
Any new keys requiring non-default comparison must add a CBOR tag to the
reference value describing the desired behaviour.

If the Reference Value contains an `authorized-by` field then the Verifier
SHALL check for an `authorized-by` field in the Accepted Claims Set entry
compared in the steps above. If the Accepted Claims Set key is not one of
the keys from the reference value `authorized-by` field then the
reference value does not match.

If all checks above have been performed successfully then the Reference Value
matches.

##### Comparison for svn entries

The value stored under `measurement-values-map` key 1 is an SVN, which must
have type UINT.

If the Reference value for `measurement-values-map` key 1 is an untagged UINT or
a UINT tagged with #6.552 then an equality comparison is performed. If the value
of the SVN in Accepted Claims Set is not equal to the value in the Reference
Value then the Reference Value does not match.

If the Reference value for `measurement-values-map` key 1 is a UINT tagged with
#6.553 then a minimum comparison is performed. If the value of the SVN in
Accepted Claims Set less than the value in the Reference Value then the
Reference Value does not match.

##### Comparison for digests entries

The value stored under `measurement-values-map` key 2, or a value tagged with
#6.TBD is a digest entry. It contains one or more digests, each measuring the
same object. A Reference Value may contain multiple digests, each with a
different algorithm acceptable to the Reference Value provider. If the
digest in Evidence contains a single value with an algorithm and value
matching one of the algorithms and values in the Reference Value then it
matches.

To prevent downgrade attacks, if there are multiple algorithms which are in
both the Evidence and Reference Value then the digests calculated using all
shared algorithms must match.

If the CBOR structure of the digest entry in the Reference Value or the
Accepted Claim Set value with the same key is incorrect then the Reference
Value does not match.

The Verifier MUST iterate over the reference value `digests` array, locating
algorithms which are present in the reference value and the Accepted Claims
Set entry.

If the hash algorithm identifier which is present in the Reference Value
and the Accepted Claims Set entry then the Reference Value does not match.

If a hash algorithm identifier is present in both the Reference Value and
the Accepted Claims Set, but the value of the hash is not binary identical
between the reference value and the Accepted Claims Set entry then the
Reference Value does not match.

##### Comparison for raw-value entries

> I think this comparison method only works if the entry is at key 4 (because
there needs to be a mask at key 5). Should we have a reference value of this
which stores [expect-raw-value raw-value-mask] in an array?

[^issue]: Content missing. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71

##### Handling of new tags

A profile may specify handling for new CBOR tagged Reference Values. The
profile must specify how to compare the CBOR tagged Reference Value against
the Accepted Claims Set.

Note that the verifier may compare Reference Values in any order, so the
comparison should not be stateful.

### Adding CoMID Endorsed Values to the Accepted Claims Set {#sec-add-to-acs}

[^issue]: Content missing. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71

## Adding DICE/SPDM evidence to the Accepted Claims Set {#sec-dice-spdm}

[^issue]: Add references. Tracked at https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/98

This section defines how evidence from DICE and/or SPDM is transformed into a
format where it can be added to an accepted claims set.
A Verifier supporting DICE/SPDM format evidence should implement this section.

### Transforming SPDM Evidence to a format usable for matching

[Evidence Binding For SPDM](TCG_SPDM-TBD) describes the process by which
measurements in an SPDM Measurement Block are converted to Evidence suitable for
matching using the rules below.
The converted evidence is held in evidence triples which have a similar format
to reference-triples (their semantics follows the matching rules described above).

### Transforming DICE Evidence to a format usable for matching

DICE Evidence appears in certificates in the TcbInfo or MultiTcbInfo extension.
Each TcbInfo, and each entry in the MultiTcbInfo, is converted to an evidence
triple using the rules in this section.
In a MultiTcbInfo each entry in the sequence is treated as independent and
translated into a separate evidence object.

The Verifier SHALL translate each field in the TcbInfo into a field in the
created endorsed-triple-record

- The TcbInfo `type` field SHALL be copied to the field named `environment-map / class / class-id` and tagged with tag #6.111
- The TcbInfo `vendor` field SHALL be copied to the field named `environment-map / class / vendor`
- The TcbInfo `model` field SHALL be copied to the field named `environment-map / class / model`
- The TcbInfo `layer` field SHALL be copied to the field named `environment-map / class / layer`
- The TcbInfo `index` field SHALL be copied to the field named `environment-map / class / index`

- The TcbInfo `version` field SHALL be translated to the field named `measurement-map / mval / version / version`
- The TcbInfo `svn` field SHALL be copied to the field named `measurement-map / mval / svn`
- The TcbInfo `fwids` field SHALL be translated to the field named `measurement-map / mval / digests`
  - Each digest within fwids is translated to a CoMID digest object, with an appropriate algorithm identifier
- The TcbInfo `flags` field SHALL be translated to the field named `measurement-map / mval / flags`
  - Each flag is translated independently
- The TcbInfo `vendorInfo` SHALL shall be copied to the field named `measurement-map / mval / raw-value`

If there are multiple evidence triples with the same `environment-map` then
they MUST be merged into a single entry.
If the `measurement-values-map` fields in evidence triples have conflicting
values then the Verifier MUST fail validation.

# Implementation Status

This section records the status of known implementations of the protocol
defined by this specification at the time of posting of this Internet-Draft,
and is based on a proposal described in {{RFC7942}}. The description of
implementations in this section is intended to assist the IETF in its decision
processes in progressing drafts to RFCs.  Please note that the listing of any
individual implementation here does not imply endorsement by the IETF.
Furthermore, no effort has been spent to verify the information presented here
that was supplied by IETF contributors.  This is not intended as, and must not
be construed to be, a catalog of available implementations or their features.
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
  [https://github.com/veraison/corim/README.md](https://github.com/veraison/corim/README.md)

* Brief general description: The `corim/corim` and `corim/comid` packages
  provide a golang API for low-level manipulation of Concise Reference
  Integrity Manifest (CoRIM) and Concise Module Identifier (CoMID) tags
  respectively.  The `corim/cocli` package uses the API above (as well as the
  API from the `veraison/swid` package) to provide a user command line
  interface for working with CoRIM, CoMID and CoSWID. Specifically, it allows
  creating, signing, verifying, displaying, uploading, and more. See
  [https://github.com/cocli/README.md](https://github.com/cocli/README.md) for
  further details.

* Implementation's level of maturity: alpha.

* Coverage: the whole protocol is implemented, including PSA-specific
  extensions {{-psa-endorsements}}.

* Version compatibility: Version -02 of the draft

* Licensing: Apache 2.0
  [https://github.com/veraison/corim/blob/main/LICENSE](https://github.com/veraison/corim/blob/main/LICENSE)

* Implementation experience: n/a

* Contact information:
  [https://veraison.zulipchat.com](https://veraison.zulipchat.com)

* Last updated:
  [https://github.com/veraison/corim/commits/main](https://github.com/veraison/corim/commits/main)

# Security and Privacy Considerations {#sec-sec}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/11

# IANA Considerations {#sec-iana-cons}

## New COSE Header Parameters

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/12

## New CBOR Tags {#sec-iana-cbor-tags}

IANA is requested to allocate the following tags in the "CBOR Tags" registry {{!IANA.cbor-tags}}, preferably with the specific CBOR tag value requested:

|     Tag | Data Item           | Semantics                                                            | Reference |
|     --- | ---------           | ---------                                                            | --------- |
|     500 | `tag`               | A tagged-concise-rim-type-choice, see {{sec-corim-tags}} | {{&SELF}} |
|     501 | `map`               | A tagged-corim-map, see {{sec-corim-map}}                                   | {{&SELF}} |
|     502 | `tag`               | A tagged-signed-corim, see {{sec-corim-signed}}                             | {{&SELF}} |
| 503-504 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |
|     505 | `bytes`             | A tagged-concise-swid-tag, see {{sec-corim-tags}}                  | {{&SELF}} |
|     506 | `bytes`             | A tagged-concise-mid-tag, see {{sec-corim-tags}}                   | {{&SELF}} |
|     507 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |
|     508 | `bytes`             | A tagged-concise-bom-tag, see {{sec-corim-tags}}         | {{&SELF}} |
| 509-549 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |
|     550 | `bytes .size 33`    | tagged-ueid-type, see {{sec-common-ueid}}                            | {{&SELF}} |
|     551 | `int`               | tagged-int-type, see {{sec-common-tagged-int}}                       | {{&SELF}} |
|     552 | `uint`              | tagged-svn, see {{sec-comid-svn}}                                    | {{&SELF}} |
|     553 | `uint`              | tagged-min-svn, see {{sec-comid-svn}}                                | {{&SELF}} |
|     554 | `text`              | tagged-pkix-base64-key-type, see {{sec-crypto-keys}}                 | {{&SELF}} |
|     555 | `text`              | tagged-pkix-base64-cert-type, see {{sec-crypto-keys}}                | {{&SELF}} |
|     556 | `text`              | tagged-pkix-base64-cert-path-type, see {{sec-crypto-keys}}           | {{&SELF}} |
|     557 | `[int/text, bytes]` | tagged-thumbprint-type, see {{sec-common-hash-entry}}                | {{&SELF}} |
| 558-559 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |
|     560 | `bytes`             | tagged-bytes, see {{sec-comid-raw-value-types}}          | {{&SELF}} |
| 561-599 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |

Tags designated as "Earmarked for CoRIM" can be reassigned by IANA based on advice from the designated expert for the CBOR Tags registry.

## New CoRIM Registries {#sec-iana-corim}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/14

## New CoMID Registries {#sec-iana-comid}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/15

## New CoBOM Registries {#sec-iana-cobom}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/45

## New Media Types {#sec-iana-media-types}

IANA is requested to add the following media types to the "Media Types"
registry {{!IANA.media-types}}.

| Name | Template | Reference |
| corim-signed+cbor | application/corim-signed+cbor | {{&SELF}}, {{sec-mt-corim-signed}} |
| corim-unsigned+cbor | application/corim-unsigned+cbor | {{&SELF}}, {{sec-mt-corim-unsigned}} |
{: #tbl-media-type align="left" title="New Media Types"}

### corim-signed+cbor {#sec-mt-corim-signed}

{:compact}
Type name:
: `application`

Subtype name:
: `corim-signed+cbor`

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
  transfer COSE Sign1 wrapped CoRIM payloads over HTTP(S), CoAP(S), and other
  transports.

Fragment identifier considerations:
: n/a

Magic number(s):
: `D9 01 F6 D2`, `D9 01 F4 D9 01 F6 D2`

File extension(s):
: n/a

Macintosh file type code(s):
: n/a

Person & email address to contact for further information:
: RATS WG mailing list (rats@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration?
: Maybe

### corim-unsigned+cbor {#sec-mt-corim-unsigned}

{:compact}
Type name:
: `application`

Subtype name:
: `corim-unsigned+cbor`

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
: `D9 01 F5`, `D9 01 F4 D9 01 F5`

File extension(s):
: n/a

Macintosh file type code(s):
: n/a

Person & email address to contact for further information:
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
| application/corim-signed+cbor | - | TBD1 | {{&SELF}} |
| application/corim-unsigned+cbor | - | TBD2 | {{&SELF}} |
{: align="left" title="New Content-Formats"}

--- back

# Full CoRIM CDDL

~~~ cddl
{::include cddl/corim-autogen.cddl}
~~~

# Acknowledgments
{:unnumbered}

{{{Carl Wallace}}} for review and comments on this document.


[^revise]: (This content needs to be revised. Consider removing for now and
    replacing with an issue.)

[^todo]: (Needed content missing. Consider adding an issue into the tracker)

[^issue]: Content missing. Tracked at:

[^tracked-at]: Tracked at:
