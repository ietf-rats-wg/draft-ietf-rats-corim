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
  I-D.ietf-rats-architecture: rats-arch
  I-D.ietf-rats-eat: eat
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
  DICE-Layering-Architecture:
    target: https://trustedcomputinggroup.org/wp-content/uploads/DICE-Layering-Architecture-r19_pub.pdf
  IANA.named-information: named-info

informative:
  RFC7942:
  I-D.fdb-rats-psa-endorsements: psa-endorsements
  I-D.tschofenig-rats-psa-token: psa-token

entity:
  SELF: "RFCthis"

--- abstract

Remote Attestation Procedures (RATS) enable Relying Parties to assess the
trustworthiness of a remote Attester and therefore to decide whether to engage
in secure interactions with it. Evidence about trustworthiness can be rather
complex and it is deemed unrealistic that every Relying Party is capable of the
appraisal of Evidence. Therefore that burden is typically offloaded to a
Verifier.  In order to conduct Evidence appraisal, a Verifier requires not only
fresh Evidence from an Attester, but also trusted Endorsements and Reference
Values from Endorsers and Reference Value Providers, such as manufacturers,
distributors, or device owners.  This document specifies Concise Reference
Integrity Manifests (CoRIM) that represent Endorsements and Reference Values in
CBOR format.  Composite devices or systems are represented by a collection of
Concise Module Identifiers (CoMID) and Concise Software Identifiers (CoSWID)
bundled in a CoRIM document.

--- middle

# Introduction

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/4

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
  Other specifications can extend the `$entity-name-type-choice` (see
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

# CoRIM {#sec-corim}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/6

At the top-level, a CoRIM can either be a CBOR-tagged `corim-map`
({{sec-corim-map}}) or a COSE signed `corim-map` ({{sec-corim-signed}}).

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
  possibly dependent, manifests or related files.  Described in
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

A CoRIM id can be either a text string or a UUID type that uniquely identifies
a CoRIM.

~~~ cddl
{::include cddl/corim-id-type-choice.cddl}
~~~

### Tags {#sec-corim-tags}

A `$concise-tag-type-choice` is a tagged CBOR payload that carries either a
CoMID ({{sec-comid}}) or a CoSWID {{-coswid}}.

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

A profile specifies which of the optional parts of a CoRIM are required, which
are prohibited and which extension points are exercised and how.

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


# CoMID {#sec-comid}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/7

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

#### Common Types

##### Environment

An `environment-map` may be used to represent a whole attester, an attesting
environment, or a target environment.  The exact semantic depends on the
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
of the attester.

The types defined for an instance identifier are UEID or UUID.

~~~ cddl
{::include cddl/instance-id-type-choice.cddl}
~~~

##### Group

A group carries a unique identifier that is reliably bound to a group of
attesters, for example when a number of attester are hidden in the same
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

Class measurements apply generally to all the attesters in the given class.
Instance measurements apply to a specific attester instances.  Environments
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

* `configured` (index 0): The measured environment is fully configured for
  normal operation if the flag is true.

* `secure` (index 1): The measured environment's configurable security settings
  are fully enabled if the flag is true.

* `recovery` (index 2): The measured environment is NOT in a recovery state if
  the flag is true.

* `debug` (index 3): The measured environment is in a debug enabled state if
  the flag is true.

* `replay-protected` (index 4): The measured environment is protected from
  replay by a previous image that differs from the current image if the flag is
  true.

* `integrity-protected` (index 5): The measured environment is protected from
  unauthorized update if the flag is true.

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

##### Crypto Keys

A cryptographic key can be one of the following formats:

* `tagged-pkix-base64-key-type`: PEM encoded SubjectPublicKeyInfo.
  Defined in {{Section 13 of -pkix-text}}.

* `tagged-pkix-base64-cert-type`: PEM encoded X.509 public key certificate.
  Defined in {{Section 5 of -pkix-text}}.

* `tagged-pkix-base64-cert-path-type`: X.509 certificate chain created by the
  concatenation of as many PEM encoded X.509 certificates as needed.  The
  certificates MUST be concatenated in order so that each directly certifies
  the one preceding.

A fourth format is used to represent thumbprints of raw keys or certificated
keys:

* `tagged-thumbprint-type`: hash of a certificate or raw public key.

~~~ cddl
{:include cddl/crypto-key-type-choice.cddl}
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

## Extensibility

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/10

# CoBOM {#sec-cobom}

A Concise Bill of Material (CoBOM) object represents the signal for the
verifier to activate the listed tags. Data contained in a tag MUST NOT be used
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

At a few well-defined points in the procedure, the Verifier behaviour will depend on the specific CoRIM profile.
Each CoRIM profile MUST provide a description of the expected Verifier behavior for each of those well-defined points.

In particular, it is expected that the resources used during the initialisation phase can be amortised across multiple appraisals.
Verifiers claiming compliance with this specification must exhibit the same externally visible behavior as described here, they are not required to use the same internal data structures.

In the following, if a MUST-level requirement is violated, the entire procedure is aborted.

## Appraisal Context initialisation

The goal of the initialisation phase is to load the CoRIM Appraisal Context with objects such as CoRIM tags, cryptographic validation key material (e.g., raw public keys, root certificates, intermediate CA certificate chains), etc. that will be used in the subsequent Evidence Appraisal phase.

### CoRIM Selection

All available CoRIMs are collected. A Verifier may be pre-configured with a large number of tags describing many types of device. All CoRIMs are loaded at this stage, later stages will select the CoRIMs appropriate to the Evidence Appraisal step.

CoRIMs that are not within their validity period, or that cannot be associated with an authenticated and authorised source MUST be discarded.

CoRIM that are secured by a cryptographic mechanism such as a signature MUST be discarded if the signature chain does not validate successfully.

Other selection criteria MAY be applied.

For example, if the Evidence format is known in advance, tags that do not match the expected profile can be readily discarded.

The selection process MUST yield at least one usable tag.

### CoBOM Extraction

CoBOMs are processed after all tags have been loaded from CoRIMs. All the available Concise Bill Of Material tags (CoBOMs) are collected from the selected CoRIMs.

The verifier MUST check each CoBOM to see whether it can be activated. The verifier MUST activate all tags referenced by an activated CoBOM.

After the verifier has processed all CoBOMs it MUST discard any tags which have not been activated by a CoBOM.

### Tags Identification and Validation

The verifier chooses tags -- including Concise Module ID Tags ([CoMID]({sec-comid})), Concise Software ID Tags ([CoSWID]), and/or Concise Trust Anchor Stores ([CoTS](I-D.ietf-rats-concise-ta-stores)) -- from the selected CoRIMs.

The verifier MUST discard all tags which are not syntactically and semantically valid.
In particular, any internal cross-reference (e.g., CoMID-CoSWID linking triples) MUST be successfully resolved.

### Appraisal Context Construction

All of the potential tags are loaded into the Appraisal Context. The complete contents of each tag are loaded together, including Reference Values, Endorsed Values and cryptographic verification key material.

This concludes the initialisation phase.

## Evidence Collection

In the evidence collection phase the verifier communicates with attesters to collect evidence.

The first part of the Evidence collection phase does not perform any cryptographic validation. This allows verifiers to use untrusted code for their initial Evidence collection.

The results of the evidence collection are protocol specific data and transcripts which can be used as input to appraisal by a trusted Verifier.

### Cryptographic validation of Evidence

If the authenticity of Evidence is secured by a cryptographic mechanism such as a signature, the first step in the Evidence Appraisal is to perform cryptographic validation of the Evidence.

The exact cryptographic signature validation mechanics depend on the specific Evidence collection protocol.

For example:
In DICE, a proof of liveness is performed on the final key in the certificate chain. If this passes then a suitable certification path anchored on a trusted root certificate is looked up -- e.g., based on linking information obtained from the DeviceID certificate (see Section 9.2.1 of {{DICE-Layering-Architecture}})-- in the Appraisal Context.  If found, then usual X.509 certificate validation is performed.
In PSA, the verification public key is looked up in the appraisal context using the `euid` claim found in the PSA claims-set (see {{Section 4.2.1 of -psa-token}}).  If found, COSE Sign1 verification is performed accordingly.

Independent of the specific method, the cryptographic integrity of Evidence MUST be successfully verified.

> A CoRIM profile MUST describe:
>
> * How cryptographic verification key material is represented (e.g., using Attestation Keys triples, or CoTS tags)
> * How key material is associated with the Attesting Environment
> * How the Attesting Environment is identified in Evidence

### The Accepted Claims Set

At the end of the Evidence collection process evidence has been converted into a format suitable for appraisal. Verifiers are not required to use this as their internal state, but for the purposes of this document a sample verifier is discussed which uses this format.

The Accepted Claims Set will be matched against CoMID reference values, as per the appraisal policy of the verifier. This document describes an example evidence structure which can be easily matched against these reference values. Each set of evidence contains an `environment-map` providing a namespace, and a `measurement-values-map` containing one or more entries.

Each entry in the `measurement-values-map` is a separate piece of evidence describing the environment named by the `environment-map`. An attestor can provide multiple `environment-map`s each containing a single values measurement-values map, a single `environment-map` containing multiple entries in its `measurement-values-map`, or a combination of these approaches.

If evidence from different sources has the same `environment-map` then the `measurement-values-map`s are merged. If both measurement-value-maps being merged contain the same key then the values associated with that key MUST be binary identical.

> A CoRIM profile MUST describe:
>
> * How evidence is converted to a format suitable for appraisal

Section {sec-dice-spdm} provides information on how evidence collected using DICE and SPDM protocols is added to the Accepted Claims Map.


## Evidence appraisal

In the Evidence Appraisal phase, a CoRIM Appraisal Context and an Evidence Appraisal Policy are used to convert the received Evidence from its raw form into a more usable form. This phase may be repeated multiple times.
The outcome of the appraisal process is summarised in an Attestation Result.
The Relying Party application uses the content of the Attestation Result to make its own policy decisions.

We make no assumptions on the specific shape of the Attestation Result, except for its optional ability to include Evidence from the attestor and Endorsed Values that the Verifier has been able to infer from Evidence and the Appraisal Context.

> A CoRIM profile MUST describe:
>
> * How Reference Values are conveyed (e.g., using Reference Value triples, or CoSWID tags)
> * How Reference Values are associated with the Target Environment
> * How the Target Environment is identified in Evidence
> * How measurements from Evidence are matched against Reference Values

> A CoRIM profile MUST describe:
>
> * How Endorsed Values are conveyed (e.g., using Endorsed Value triples, or Device Identity triples)
> * How Endorsed Values are added to the Accepted Claims Map

The sections below describe the algorithm used to compare CoMID tags.

### Comparing and processing CoMID tags

There can be multiple passes of the CoMID evidence appraisal process.

In each pass, each potential CoMID tag in the Appraisal Context is compared against the accepted claims set (which has been initialised with Evidence from the attestor(s) ). If the reference values in the CoMID tag match the Accepted Claims Set then Endorsements and other values from the tag are added to the Accepted Claims Set.

If any tags matched in a pass through the CoMID appraisal process then another pass is performed. Tags which matched in a previous pass are ignored in later passes of the same appraisal.

A later pass may match Reference Values from the CoMID against Endorsements from matched tags in an earlier pass, this allows CoRIM authors to create hierarchical descriptions of a system.

### Matching Evidence against Reference Values

This section describes the process performed by the verifier to determine whether a candidate CoMID tag matches the Accepted Claims Set. If a tag does not match the Accepted Claims Set then it is silently ignored for this pass, processing continues with the remaining candidate tags.

The Verifier iterates over the Reference Values in the CoMID tag. If the Accepted Claims Set does not contain an entry with the same `environment-map` as the Reference Value then the tag does not match. Comparison of `environment-map` is performed using a binary comparison. A Verifier SHOULD convert `environment-map` to the canonical format before performing the binary comparison.

The Verifer locates the `measurement-values-map` corresponding to the `environment-map` in the Reference Value and the Accepted Claims Set. The Verifier enumerates over the key-value pairs in the Reference Value `measurement-values-map`. If the Accepted Claims Set `measurement-values-map` does not have an entry with the same key as the Reference Value `measurement-values-map`, or if the entries do not match, then the tag does not match.

The algorithm used to match the `measurement-values-map` entries together depends on whether the reference value is tagged, and on the `measurement-values-map` key which identifies the entry.

If the Reference Value `measurement-values-map` value starts with a CBOR tag then the verifier MUST use the algorithm described by the tag to match the entries. Handling for initial tags is described in sub-sections below. If the verifier does not recognise the tag value then the tag does not match.

If the Reference Value is not tagged and the measurement-value-map key is a special value described in the sub-sections below, then the algorithm appropriate to that key is used to match the entries.

If the Reference Value is not tagged, and the `measurement-values-map` key is not a special value described below, then the entries are compared using binary comparison of their CBOR values.

Note that while specifications may extend the matching semantics using tags, there is no way to extend the matching semantics of special key values. Any new keys requiring special handling must have an appropriate tag in the reference value.

#### Comparing raw-value entries

#### Comparing svn entries

#### Comparing digest entries

#### Defining handling for new tags

### Adding CoMID Endorsed Values to the Accepted Claims Set

If a CoMID tag matches the Accepted Claims Set then the verifier must attempt to add Endorsed values from that tag to the Accepted Claims Set.

If any of the Endorsed values being added have the same `environment-map` and `measurement-values-map` key, but a different`measurement-values-map` value from the value in the Accepted Claims Map then the verifier MUST NOT add any part of the tag to the Accepted Claims Map.

## Adding DICE/SPDM evidence to the Accepted Claims Set {#sec-dice-spdm}

This section defines how evidence from DICE and/or SPDM is transformed into a format where it can be added to an accepted claims set. A verifier supporting DICE/SPDM format evidence should implement this section.

### Transforming SPDM Evidence to a format usable for matching

[Evidence Binding For SPDM](TCG_SPDM-TBD) describes the process by which evidence in a SPDM MEASUREMENTS response is converted to Evidence suitable for matching using the rules below. The converted evidence is held in evidence triples which have a similar format to reference-triples (their semantics is described below).

### Transforming DICE Evidence to a format usable for matching

DICE Evidence appears in certificates in the TcbInfo or MultiTcbInfo extension. Each TcbInfo, and each entry in the MultiTcbInfo, is converted to an evidence triple using the rules in this section. In a MultiTcbInfo each entry in the sequence is treated as independent and translated into a separate evidence object.

The verifier SHALL translate each field in the TcbInfo into a field in the created endorsed-triple-record

- The TcbInfo `type` field SHALL be copied to the field named `environment-map / class / class-id`
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

If there are multiple evidence triples with the same `environment-map` then they MUST be merged into a single entry.
If the `measurement-values-map` fields in evidence triples have conflicting values then the Verifier MUST fail validation.

# Implementation Status

This section records the status of known implementations of the protocol
defined by this specification at the time of posting of this Internet-Draft,
and is based on a proposal described in {{RFC7942}}.  The description of
implementations in this section is intended to assist the IETF in its decision
processes in progressing drafts to RFCs.  Please note that the listing of any
individual implementation here does not imply endorsement by the IETF.
Furthermore, no effort has been spent to verify the information presented here
that was supplied by IETF contributors.  This is not intended as, and must not
be construed to be, a catalog of available implementations or their features.
Readers are advised to note that other implementations may exist.

According to {{RFC7942}}, "this will allow reviewers and working groups to
assign due consideration to documents that have the benefit of running code,
which may serve as evidence of valuable experimentation and feedback that have
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

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/13

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
