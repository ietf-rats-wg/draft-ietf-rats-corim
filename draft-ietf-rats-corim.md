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
  - ins: A. Draper
    name: Andrew Draper
    org: Intel Corporation
    email: andrew.draper@intel.com
    contribution: >
      Andrew contributed the concept, description, and semantics of conditional endorsements as well as consistent contribution to weekly reviews of others' edits.
  - ins: D. Glaze
    name: Dionna Glaze
    org: Google LLC
    email: dionnaglaze@google.com
    contribution: >
      Dionna contributed many clarifying questions and disambiguations to the semantics of attestation appraisal as well as consistent contribution to weekly reviews of others' edits.

normative:
  RFC4122: uuid
  RFC5280: pkix-cert
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
  RFC9393: coswid
  RFC9334: rats-arch
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
  I-D.ietf-rats-endorsements: rats-endorsements
  DICE.Layer:
    title: DICE Layering Architecture
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.0, Revision 0.19
    date: July 2020
    target: https://trustedcomputinggroup.org/wp-content/uploads/DICE-Layering-Architecture-r19_pub.pdf
  IANA.coswid: coswid-reg
  I-D.ietf-rats-eat: eat
  I-D.ietf-rats-concise-ta-stores: ta-store
  I-D.ietf-rats-ar4si: ar4si
  I-D.ietf-rats-cobom: cobom

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

In order to conduct Evidence appraisal, a Verifier requires not only fresh Evidence from an Attester, but also trusted Endorsements (e.g., test results or certification data) and Reference Values (e.g., the version or digest of a firmware component) associated with the Attester.
Endorsements and Reference Values are obtained from relevant supply chain actors, such as manufacturers, distributors, or device owners.
In a complex supply chain, multiple actors will likely produce these values over several points in time.
As such, one supply chain actor will only provide the subset of characteristics that they know about the Attester. A proper subset is typical because a certain supply chain actor will be the responsible authority for only a system component/module that is measured amongst a long chain of measurements.
Attesters vary across vendors and even across products from a single vendor.
Not only Attesters can evolve and therefore new measurement types need to be expressed, but an Endorser may also want to provide new security relevant attributes about an Attester at a future point in time.

This document specifies Concise Reference Integrity Manifests (CoRIM) - a CBOR {{-cbor}} based data model addressing the above challenges by using an extensible format common to all supply chain actors and Verifiers.
CoRIM enables Verifiers to reconcile a complex distributed supply chain into a single homogeneous view.
See {{sec-verifier-rec}}.

## Terminology and Requirements Language

This document uses terms and concepts defined by the RATS architecture.
For a complete glossary, see {{Section 4 of -rats-arch}}.

In this document, the term CoRIM message and CoRIM documents are used as synonyms. A CoRIM data structure can be at rest (e.g., residing in a file system as a document) or can be in flight (e.g., conveyed as a message in a protocol exchange). The bytes composing the CoRIM data structure are the same either way.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}. Terms and concepts are always referenced as proper nouns, i.e., with Capital Letters.

{::boilerplate bcp14}

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
In essence, if Evidence is not corroborated by an RVP's Claims, then the RVP's Claims are not included in the ACS.

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
The internal representations used by this document are defined in {{sec-ir-cm}}.

## Interacting with an ACS {#sec-interact-acs}

Conceptual Messages interact with an ACS by specifying criteria that should be met by the ACS and by presenting the assertions that should be added to the ACS if the criteria are satisfied.
Internal representations of Conceptual Messages, ACS, and Attestation Results Set (ARS) should satisfy the following requirements for Verifier reconciliation and appraisal processing:

| CM Type | Structure | Description |
|---
| Evidence | List of Evidence claims | If the Attester is authenticated, add Evidence claims to the ACS with Attester authority |
| Reference Values | List of Reference Values claims | If a reference value in a CoRIM matches claims in the ACS, then the authority of the CoRIM issuer is added to those claims. |
| Endorsements | List of expected actual state claims, List of Endorsed Values claims | If the list of expected claims are in the ACS, then add the list of Endorsed Values claims to the ACS with Endorser authority |
| Series Endorsements | List of expected actual state claims and a series of selection-addition tuples | If the expected claims are in the ACS, and if the series selection condition is satisfied, then add the additional claims to the ACS with Endorser authority. See {{sec-ir-end-val}} |
| Verifier | List of expected actual state claims, List of Verifier-generated claims | If the list of expected claims are in the ACS, then add the list of Verifier-generated claims to the ACS with Verifier authority |
| Policy | List of expected actual state claims, List of Policy-generated claims | If the list of expected claims are in the ACS, then add the list of Policy-generated claims to the ACS with Policy Owner authority |
| Attestation Results | List of expected actual state claims, List of expected Attestation Results claims | If the list of expected claims are in the ACS, then copy the list of Attestation Results claims into the ARS. See {{sec-ir-ars}} |
{: #tbl-cmrr title="Conceptual Message Representation Requirements"}

## Quantizing Inputs {#sec-quantize}
[^tracked-at] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/242

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
A tag identifies and describes properties of modules or components of a system.

Tags can be of different types:

* Concise Module ID (CoMID) tags ({{sec-comid}}) contain metadata and claims about the hardware and firmware modules.

* Concise Software ID (CoSWID) tags ({{-coswid}}) describe software components.

* Concise Bill of Material (CoBOM) tags ({{sec-cobom}}) contain the list of CoMID and CoSWID tags that the Verifier should consider as "active" at a certain point in time.

The set of tags is extensible so that future specifications can add new kinds of information.
For example, Concise Trust Anchor Stores (CoTS) ({{-ta-store}}) is currently being defined as a standard CoRIM extension.

Each CoRIM contains a unique identifier to distinguish a CoRIM from other CoRIMs.
[^tracked-at] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/73

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
  in {{sec-corim-id}}.

* `tags` (index 1):  An array of one or more CoMID or CoSWID tags.  Described
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

~~~ cddl
{::include cddl/tagged-corim-map.cddl}
~~~

### Identity {#sec-corim-id}

A CoRIM Identifier uniquely identifies a CoRIM instance.
The base CDDL definition allows UUID and text identifiers.
Other types of identifiers could be defined as needed.

~~~ cddl
{::include cddl/corim-id-type-choice.cddl}
~~~

### Tags {#sec-corim-tags}

A `$concise-tag-type-choice` is a tagged CBOR payload that carries either a
CoMID ({{sec-comid}}), a CoSWID ({{-coswid}}), or a CoBOM ({{sec-cobom}}).

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
  See sec-common-hash-entry}}.

### Profile Types {#sec-corim-profile-types}

Profiling is the mechanism that allows the base CoRIM CDDL definition to be customized to fit a specific Attester.

A profile defines which of the optional parts of a CoRIM are required, which are prohibited and which extension points are exercised and how.
A profile MUST NOT alter the syntax or semantics of CoRIM types defined in this document.

A profile MAY constrain the values of a given CoRIM type to a subset of the values.
A profile MAY extend the set of a given CoRIM type using the defined extension points ({{sec-extensibility}}).
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

The CoRIM protected header map uses some common COSE header parameters plus an additional `corim-meta` parameter.
The following describes each child item of this map.

* `alg` (index 1): An integer that identifies a signature algorithm.

* `content-type` (index 3): A string that represents the "MIME Content type" carried in the CoRIM payload.

* `kid` (index 4): A bit string which is a key identity pertaining to the CoRIM Issuer.

* `corim-meta` (index 8): A map that contains metadata associated with a signed CoRIM.
  Described in {{sec-corim-meta}}.

Additional data can be included in the COSE header map as per ({{Section 3 of -cose}}).

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


# Concise Module Identifier (CoMID) {#sec-comid}

A CoMID tag contains information about hardware, firmware, or module composition.

Each CoMID has a unique ID that is used to unambiguously identify CoMID instances when cross referencing CoMID tags, for example in typed link relations, or in a CoBOM tag.

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

* `conditional-endorsement-series-triples` (index 8): Triples describing a series of
  conditional Endorsements based on the acceptance of a stateful environment.
  Described in {{sec-comid-triple-cond-series}}.

* `conditional-endorsement-triples` (index 10): Triples describing a series of
  Endorsement that are applicable based on the acceptance of a series of
  stateful environment records.
  Described in {{sec-comid-triple-cond-endors}}.

##### Environments

An `environment-map` may be used to represent a whole Attester, an Attesting
Environment, or a Target Environment.  The exact semantic depends on the
context (triple) in which the environment is used.

An environment is named after a class, instance or group identifier (or a
combination thereof).

An environment MUST be globally unique.
The combination of values within `class-map` must combine to form a globally unique identifier.

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

##### Environment Class {#sec-comid-class}

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

##### Environment Instance {#sec-comid-instance}

An instance carries a unique identifier that is reliably bound to a Target Environment
that is an instance of the Attester.

The types defined for an instance identifier are CBOR tagged expressions of
UEID, UUID, variable-length opaque byte string ({{sec-common-tagged-bytes}}), or cryptographic key identifier.

~~~ cddl
{::include cddl/instance-id-type-choice.cddl}
~~~

##### Environment Group {#sec-comid-group}

A group carries a unique identifier that is reliably bound to a group of
Attesters, for example when a number of Attester are hidden in the same
anonymity set.

The types defined for a group identified are UUID and variable-length opaque byte string ({{sec-common-tagged-bytes}}).

~~~ cddl
{::include cddl/group-id-type-choice.cddl}
~~~

##### Measurements {#sec-measurements}

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

###### Measurement Keys {#sec-comid-mkey}

Measurement keys are locally scoped extensible identifiers.
The initial types defined are OID, UUID, uint, and tstr.
`mkey` may be necessary to disambiguate multiple measurements of the same type or to distinguish multiple measured elements within the same environment.
A single anonymous `measurement-map` is allowed within the same environment.
Two or more measurement-map entries within the same environment MUST populate `mkey`.

~~~ cddl
{::include cddl/measured-element-type-choice.cddl}
~~~

###### Measurement Values {#sec-comid-mval}

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
  An optional `raw-value-mask` (index 5) indicates which bits in the
  `raw-value` field are relevant for verification. A mask of all ones ("1")
  means all bits in the `raw-value` field are relevant. Multiple values could
  be combined to create a single `raw-value` attribute. The vendor determines
  how to pack multiple values into a single `raw-value` structure. The same
  packing format is used when collecting Evidence so that Reference Values and
  collected values are bit-wise comparable. The vendor determines the encoding
  of `raw-value` and the corresponding `raw-value-mask`.

* `mac-addr` (index 6): A EUI-48 or EUI-64 MAC address associated with the measured environment.
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

###### Version {#sec-comid-version}

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

###### Security Version Number {#sec-comid-svn}

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

* `is-confidentiality-protected` (index 9): If the flag is true, the measured environment
is confidentiality protected. For example, if the measured environment consists of memory,
the sensitive values in memory are encrypted.

###### Raw Values Types {#sec-comid-raw-value-types}

Raw value measurements are typically vendor defined values that are checked by Verifiers
for consistency only, since the security relevance is opaque to Verifiers.

There are two parts to a `raw-value-group`, a measurement and an optional mask.
The default raw value measurement is of type `tagged-bytes` ({{sec-common-tagged-bytes}}).
Additional raw value types can be defined, but must be CBOR tagged so that parsers can distinguish
between the various semantics of type values.

The mask is applied by the Verifier as part of appraisal.
Only the raw value bits with corresponding TRUE mask bits are compared during appraisal.

When a new raw value type is defined, the convention for applying the mask is also defined.
Typically, a CoRIM profile is used to define new raw values and mask semantics.

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
  Defined in {{Section 7 of -cose}}.

* `tagged-pkix-asn1der-cert-type`: a `bstr` of ASN.1 DER encoded X.509 public key certificate.
  Defined in {{Section 4 of -pkix-cert}}.

A cryptographic key digest can be one of the following formats:

* `tagged-thumbprint-type`: a `digest` of a raw public key.
  The digest value may be used to find the public key if contained in a lookup table.

* `tagged-cert-thumbprint-type`: a `digest` of a certificate.
  The digest value may be used to find the certificate if contained in a lookup table.

* `tagged-cert-path-thumbprint-type`: a `digest` of a certification path.
  The digest value may be used to find the certificate path if contained in a lookup table.

* `tagged-bytes`: a key identifier with no prescribed construction method.

~~~ cddl
{::include cddl/crypto-key-type-choice.cddl}
~~~

##### Integrity Registers {#sec-comid-integrity-registers}

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


##### Domain Types {#sec-comid-domain-type}

A domain is a context for bundling a collection of related environments and their measurements.

The following CDDL describes domain type choices.

~~~ cddl
{::include cddl/domain-type-choice.cddl}
~~~

The `uint` and `text` types MUST NOT be interpreted in a global scope.

#### Reference Values Triple {#sec-comid-triple-refval}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/310

The Reference Values Triple has the following structure:

~~~ cddl
{::include cddl/reference-triple-record.cddl}
~~~

The `reference-triple-record` has the following parameters:

* `ref-env`: Search criterion that locates an Evidence environment that matches the reference environment.
* `ref-claims`: Search criteria that locates the Evidence measurements that match the reference Claims.

To process `reference-triple-record` both the `ref-env` and `ref-claims` criteria are compared with Evidence entries.
If the search criteria are satisfied, the matching entry is re-asserted, except with the Reference Value Provider's authority.
By re-asserting Evidence using the RVP's authority, the Verifier can avoid mixing Reference Values (reference state) with Evidence (actual state).
See {{-rats-endorsements}}.
Re-asserted Evidence using RVP authority is said to be "corroborated".

#### Endorsed Values Triple {#sec-comid-triple-endval}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/310

The Endorsed Values Triple has the following structure:

~~~ cddl
{::include cddl/endorsed-triple-record.cddl}
~~~

The `endorsed-triple-record` has the following parameters:

* `condition`: Search criterion that locates an Evidence, corroborated Evidence, or Endorsements environment.
* `endorsement`: Additional Endorsement Claims.

To process a `endorsed-triple-record` the `condition` is compared with existing Evidence, corroborated Evidence, and Endorsements.
If the search criterion is satisfied, the `endorsement` Claims are combined with the `condition` `environment-map` to form a new (actual state) entry.
The new entry is added to the existing set of entries using the Endorser's authority.

#### Conditional Endorsement Triple {#sec-comid-triple-cond-endors}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/310

The Conditional Endorsement Triple has the following structure:

~~~ cddl
{::include cddl/conditional-endorsement-triple-record.cddl}

{::include cddl/stateful-environment-record.cddl}
~~~

The `conditional-endorsement-triple-record` has the following parameters:

* `conditions`: Search criteria that locates Evidence, corroborated Evidence, or Endorsements.
* `endorsements`: Additional Endorsements.

To process a `conditional-endorsement-triple-record` the `conditions` are compared with existing Evidence, corroborated Evidence, and Endorsements.
If the search criteria are satisfied, the `endorsements` entries are asserted with the Endorser's authority as new Endorsements.

#### Conditional Endorsement Series Triple {#sec-comid-triple-cond-series}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/310

The Conditional Endorsement Series Triple has the following structure:

~~~ cddl
{::include cddl/conditional-endorsement-series-triple-record.cddl}

{::include cddl/conditional-series-record.cddl}
~~~

The `conditional-endorsement-series-triple-record` has the following parameters:

* `condition`: Search criteria that locates Evidence, corroborated Evidence, or Endorsements.
* `series`: A set of selection-addition tuples.

The `conditional-series-record` has the following parameters:

* `selection`: Search criteria that locates Evidence, corroborated Evidence, or Endorsements from the `condition` result.
* `addition`: Additional Endorsements if the `selection` criteria are satisfied.

To process a `conditional-endorsement-series-record` the `conditions` are compared with existing Evidence, corroborated Evidence, and Endorsements.
If the search criteria are satisfied, the `series` tuples are processed.

The `series` array contains a list of `conditional-series-record` entries.

For each `series` entry, if the `selection` criteria matches an entry found in the `condition` result, the `series` `addition` is combined with the `environment-map` from the `condition` result to form a new Endorsement entry.
The new entry is added to the existing set of Endorsements.

The first `series` entry that successfully matches the `selection` criteria terminates `series` processing.

#### Device Identity Triple {#sec-comid-triple-identity}

A Device Identity triple record relates one or more cryptographic keys to a device identity.
The cryptographic keys are bound to or associated with a Target Environment that is within the device.
The device identifier may be part of the Target Environment's `environment-map` or may be part of some other device identity credential, such as a certificate.
The cryptographic keys are expected to be used to authenticate the device.

Device Identity triples instruct a Verifier to perform key validation checks, such as revocation, certificate path construction & verification, or proof of possession.
The Verifier SHOULD verify keys contained in Device Identity triples.

A Device Identity triple endorses that the keys were securely provisioned to the named Target Environment.
Additional details about how a key was provisioned or is protected may be asserted using Endorsements such as `endorsed-triples`.

Depending on key formatting, as defined by `$crypto-key-type-choice`, the Verifier may take different steps to locate and verify the key.

If a key has usage restrictions that limit its use to device identity challenges, Verifiers SHOULD check for key use that violates usage restrictions.

Verification of a key, including its use restrictions, MAY produce Claims that are added to the ACS.
Alternatively, Verifiers MAY report key verification results as part of an error reporting function.

~~~ cddl
{::include cddl/identity-triple-record.cddl}
~~~

#### Attest Key Triple {#sec-comid-triple-attest-key}

An Attest Key triple record relates one or more cryptographic keys to an Attesting Environment.
The cryptographic keys are wielded by an Attesting Environment that collects measurements from a Target Environment.
The cryptographic keys sign Evidence.

Attest Key triples instruct a Verifier to perform key validation checks, such as revocation, certificate path construction & verification, or proof of possession.
The Verifier SHOULD verify keys contained in Attest Key triples.

Attest Key triples endorse that the keys were securely provisioned to the named (identified via an `environment-map`) Attesting Environment.
Additional details about how a key was provisioned or is protected may be asserted using Endorsements such as `endorsed-triples`.

Depending on key formatting, as defined by `$crypto-key-type-choice`, the Verifier may take different steps to locate and verify the key.
If a key has usage restrictions that limits its use to Evidence signing, Verifiers SHOULD check for key use that violates usage restrictions.

Verification of a key, including its use restrictions, MAY produce Claims that are added to the ACS.
Alternatively, Verifiers MAY report key verification results as part of an error reporting function.

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

# CoBOM {#sec-cobom}

A Concise Bill of Material (CoBOM) object represents the signal for the
Verifier to activate the listed tags. Verifier policy determines whether CoBOMs are required.

When CoBOMs are required, each tag MUST be activated by a CoBOM before being processed.
All the tags listed in the CoBOM MUST be activated atomically. If any tag activated by a CoBOM is not available to the Verifier, the entire CoBOM is rejected.

The number of CoBOMs required in a given supply chain ecosystem is dependent on
Verifier Owner's Appraisal Policy for Evidence. Corresponding policies are often driven by the complexity and nature of the use case.

If a Verifier Owner has a policy that does not require CoBOM, tags within a CoRIM received by a Verifier
are activated immediately and treated valid for appraisal.

There may be cases when Verifier receives CoRIMs from multiple
Reference Value providers and Endorsers. In such cases, a supplier (or other authorities, such as integrators)
may be designated to issue a single CoBOM to activate all the tags submitted to the Verifier
in these CoRIMs.

In a more complex case, there may be multiple authorities that issue CoBOMs at different points in time.
An Appraisal Policy for Evidence may dictate how multiple CoBOMs are to be processed within the Verifier.

## Structure

The CDDL specification for the `concise-bom-tag` map is as follows and this
rule and its constraints MUST be followed when creating or validating a CoBOM
tag:

~~~ cddl
{::include cddl/concise-bom-tag.cddl}
~~~

The following describes each member of the `concise-bom-tag` map.

* `tag-identity` (index 0): A `tag-identity-map` containing unique
  identification information for the CoBOM.
  Described in {{sec-comid-tag-id}}.

* `tags-list` (index 1): A list of one or more `tag-identity-maps` identifying
  the CoMID and CoSWID tags that constitute the "bill of material", i.e.,
  a complete set of verification-related information.  The `tags-list` behaves
  like a signaling mechanism from the supply chain (e.g., a product vendor) to
  a Verifier that activates the tags in `tags-list` for use in the Evidence
  appraisal process. The activation is atomic: all tags listed in `tags-list`
  MUST be activated or no tags are activated.

* `bom-validity` (index 2): Specifies the validity period of the CoBOM.
  Described in {{sec-common-validity}}.

* `$$concise-bom-tag-extension`: This CDDL socket is used to add new information structures to the `concise-bom-tag`.
  See {{sec-iana-cobom}}.
  The `$$concise-bom-tag-extension` extension socket is empty in this specification.

# Common Types {#sec-common-types}

The following CDDL types may be shared by CoRIM, CoMID, and CoBOM.

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
Defined in {{Section 4.1.2. of -uuid}}.

~~~ cddl
{::include cddl/uuid.cddl}
~~~

## UEID {#sec-common-ueid}

Used to tag a byte string as Universal Entity ID Claim (UUID).
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
The type of the digest algorithm identifier can be either `int` or `text` and is interpreted according to the {{-named-info}} registry.
Specifically, `int` values are matched against "ID" entries, `text` values are matched against "Hash Name String" entries.
Whenever possible, using the `int` encoding is RECOMMENDED.

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

# Appraisal of CoRIM-based Inputs {#sec-appr-corim-inputs}

Inputs to a Verifier are mapped from their external representation to an internal representation.
CoRIM defines CBOR structures and content media types for Conceptual Messages that include Endorsements and Reference Values.
CoRIM data structures may also be used by Evidence and Attestation Results that wish to describe overlapping structure.
CoRIM-based data structures define an external representation of Conceptual Messages that are mapped to an internal representation.
Appraisal processing describes both mapping transformations and Verifier reconciliation ({{sec-verifier-rec}}).
Non-CoRIM-based data structures require mapping transformation, but these are out of scope for this document.

If a CoRIM profile is specified, there are a few well-defined points in the procedure where Verifier behaviour depends on the profile.
The CoRIM profile MUST provide a description of the expected Verifier behavior for each of those well-defined points.

Verifier implementations MUST exhibit the same externally visible behavior as described in this specification.
They are not required to use the same internal representation or evaluation order described by this specification.

## Appraisal Procedure {#sec-appraisal-procedure}

The appraisal procedure is divided into several logical phases for clarity.

+ **Phase 1**: Input Validation and Transformation

During Phase 1, Conceptual Message inputs are cryptographically validated, such as checking digital signatures.
Inputs are transformed from their external representations to an internal representation.
Internal representations are staged for appraisal processing, such as populating an input queue.

+ **Phase 2**: Evidence Augmentation

During Phase 2, Evidence inputs are added to a list that describes the Attester's actual state.
These inputs are added with the Attester's authority.

+ **Phase 3**: Reference Values Corroboration and Augmentation

During Phase 3, Reference Values inputs are compared with Evidence inputs.
Reference Values inputs describe possible states of Attesters.
If the actual state of the Attester is described by the possible Attester states, then the overlapping (corroborated) actual states are added to the Attester's actual state.
These inputs are added with the Reference Value Provider's authority.

+ **Phase 4**: Endorsed Values Augmentation

During Phase 4, Endorsed Values inputs containing conditions that describe expected Attester state are processed.
If the comparison is satisfied, then additional Claims about the Attester are added to the ACS.
These inputs are added with the Endorser's authority.

+ **Phase 5**: Verifier Augmentation

During Phase 5, the Verifier may perform consistency, integrity, or additional validity checks.

These checks may result in additional Claims about the Attester that are added to the ACS.
These Claims are added with the Verifier's authority.

+ **Phase 6**: Policy Augmentation

During Phase 6, appraisal policies are processed that describe Attester states that are desirable or undesirable.
If these conditions exist, the policy may add additional Claims about the Attester, to the ACS.
These Claims are added with the policy author's authority.

+ **Phase 7**: Attestation Results Production and Transformation

During Phase 7, the outcome of Appraisal and the set of Attester Claims that are interesting to a Relying Party are copied from the Attester state to an output staging area.
The Claims in the output staging area and other Verifier related metadata are transformed into an external representation suitable for consumption by a Relying Party.

## Verifier Abstraction {#sec-verifier-abstraction}

This document assumes that Verifier implementations may differ.
To facilitate the description of normative Verifier behavior, this document uses an abstract representation of Verifier internals.

The following terms are used:

{: vspace="0"}
Claim:
: A piece of information, in the form of a key-value pair.

Environment-Claim Tuple (ECT):

: A structure containing a set of values that describe a Target Environment plus a set of measurement / Claim values that describe properties of the Target Environment.
The ECT also contains authority which identifies the entity that authored the ECT.

reference state:
: Claims that describe various alternative states of a Target Environment.  Reference Values Claims typically describe various possible states due to versioning, manufactruing practices, or supplier configuration options.  See also {{Section 2 of -rats-endorsements}}.

actual state:
: Claims that describe a Target Environment instance at a given point in time.  Endorsed Values and Evidence typically are Claims about actual state.  An Attester may be composed of multiple components, where each component may represent a scope of appraisal.
See also ({{Section 2 of -rats-endorsements}}).

Authority:
: The entity asserting that a claim is true.
Typically, a Claim is asserted using a cryptographic key to digitally sign the Claim. A cryptographic key can be a proxy for a human or organizational entity.

Appraisal Claims Set (ACS):
: A structure that holds ECTs that have been appraised.
The ACS contains Attester state that has been authorized by Verifier processing and Appraisal Policy.

Appraisal Policy:
: A description of the conditions that, if met, allow acceptance of Claims. Typically, the entity asserting a Claim should have knowledge, expertise, or context that gives credibility to the assertion. Appraisal Policy resolves which entities are credible and under what conditions.  See also "Appraisal Policy for Evidence" in {{-rats-arch}}.

Attestation Results Set (ARS):
: A structure that holds results of Appraisal and ECTs that are to be conveyed to a Relying Party.

### Internal Representation of Conceptual Messages {#sec-ir-cm}

Conceptual Messages are Verifier input and output values such as Evidence, Reference Values, Endorsed Values, Appraisal Policy, and Attestation Results.

The internal representation of Conceptual Messages, as well as the ACS ({{sec-ir-acs}}) and ARS ({{sec-ir-ars}}), are constructed from a common building block structure called Environment-Claims Tuple (ECT).

ECTs have five attributes:

{:ect-enum: style="format %d."}

{: ect-enum}
* Environment : Identifies the Target Environment. Environments are identified using instance, class, or group identifiers. Environments may be composed of elements, each having an element identifier.

* Elements : Identifies the set of elements contained within a Target Environment and their trustworthiness Claims.

* Authority : Identifies the entity that issued the tuple. A certain type of key material by which the authority (and corresponding provenance) of the tuple can be determined, such as the public key of an asymmetric key pair that is associated with an authority's PKIX certificate.

* Conceptual Message Type : Identifies the type of Conceptual Message that originated the tuple.

* Profile : The profile that defines this tuple. If no profile is used, this attribute is omitted.

The following CDDL describes the ECT structure in more detail.

~~~ cddl
{::include cddl/intrep-ect.cddl}
~~~

The Conceptual Message type determines which attributes are mandatory.

#### Internal Representation of Evidence {#sec-ir-evidence}

An internal representation of attestation Evidence uses the `ae` relation.

~~~ cddl
{::include cddl/intrep-ae.cddl}
~~~

The `addition` is a list of ECTs with Evidence to be appraised.

A Verifier may maintain multiple simultaneous sessions to different Attesters.
Each Attester has a different ACS. The Verifier ensures the Evidence inputs are associated with the correct ACS.
The `addition` is added to the ACS for a specific Attester.

{{tbl-ae-ect-optionality}} contains the requirements for the ECT fields of the Evidence tuple:

| ECT type  | ECT Field       | Requirement |
|---
| addition  | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
{: #tbl-ae-ect-optionality title="Evidence tuple requirements"}

#### Internal Representation of Reference Values {#sec-ir-ref-val}

An internal representation of Reference Values uses the `rv` relation, which is a list of ECTs that contains possible states and a list of ECTs that contain actual states asserted with RVP authority.

~~~ cddl
{::include cddl/intrep-rv.cddl}
~~~

The `rv` relation is a list of condition-addition pairings where each pairing is evaluated together.
If the `condition` containing reference ECTs overlaps Evidence ECTs then the Evidence ECTs are re-asserted, but with RVP authority as contained in the `addition`.

The reference ECTs define the matching conditions that are applied to Evidence ECTs.
If the matching condition is satisfied, then the re-asserted ECTs are added to the ACS.

{{tbl-rv-ect-optionality}} contains the requirements for the ECT fields of the Reference Values tuple:

| ECT type  | ECT Field       | Requirement |
|---
| condition | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Optional    |
|           | `cmtype`        | n/a         |
|           | `profile`       | n/a         |
| addition  | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
{: #tbl-rv-ect-optionality title="Reference Values tuple requirements"}

#### Internal Representation of Endorsed Values {#sec-ir-end-val}

An internal representation of Endorsed Values uses the `ev` and `evs` relations, which are lists of ECTs that describe matching conditions and the additions that are added if the conditions are satisfied.

~~~ cddl
{::include cddl/intrep-ev.cddl}
~~~

The `ev` relation compares the `condition` ECTs to the ACS and if all of the ECTs are found in the ACS then the `addition` ECTs are added to the ACS.

The `evs` relation compares the `condition` ECTs to the ACS and if all of the ECTs are found in the ACS then each entry in the series list is evaluated.
The `selection` ECTs are compared with the ACS and if the selection criteria is satisfied, then the `addition` ECTs are added to the ACS and evaluation of the series ends.
If the `selection` criteria is not satisfied, then evaluation procedes to the next series list entry.

{{tbl-ev-ect-optionality}} contains the requirements for the ECT fields of the Endorsed Values and Endorsed Values Series tuples:

| ECT type  | ECT Field       | Requirement |
|---
| condition | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Optional    |
|           | `cmtype`        | n/a         |
|           | `profile`       | n/a         |
| selection | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Optional    |
|           | `cmtype`        | n/a         |
|           | `profile`       | n/a         |
| addition  | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
{: #tbl-ev-ect-optionality title="Endorsed Values and Endorsed Values Series tuples requirements"}

#### Internal Representation of Policy Statements {#sec-ir-policy}

The `policy` relation compares the `condition` ECTs to the ACS.

~~~ cddl
{::include cddl/intrep-policy.cddl}
~~~

If all of the ECTs are found in the ACS then the `addition` ECTs are added to the ACS with the policy author's authority.

{{tbl-policy-ect-optionality}} contains the requirements for the ECT fields of the Policy tuple:

| ECT type  | ECT Field       | Requirement |
|---
| condition | `environment`   | Optional    |
|           | `element-list`  | Optional    |
|           | `authority`     | Optional    |
|           | `cmtype`        | n/a         |
|           | `profile`       | n/a         |
| addition  | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
{: #tbl-policy-ect-optionality title="Policy tuple requirements"}

#### Internal Representation of Attestation Results {#sec-ir-ar}

The `ar` relation compares the `acs-condition` to the ACS.

~~~ cddl
{::include cddl/intrep-ar.cddl}
~~~

If the condition is satisfied, the `ars-additions` are copied from the ACS to the ARS.
If any of the `ars-additions` are not found in the ACS then these ACS entries are not copied to the ARS.

{{tbl-ar-ect-optionality}} contains the requirements for the ECT fields of the Attestation Results tuple:

| ECT type      | ECT Field       | Requirement |
|---
| acs-condition | `environment`   | Optional    |
|               | `element-list`  | Optional    |
|               | `authority`     | Optional    |
|               | `cmtype`        | n/a         |
|               | `profile`       | n/a         |
| ars-addition  | `environment`   | Mandatory   |
|               | `element-list`  | Mandatory   |
|               | `authority`     | Mandatory   |
|               | `cmtype`        | Mandatory   |
|               | `profile`       | Optional    |
{: #tbl-ar-ect-optionality title="Attestation Results tuple requirements"}

### Internal Representation of Appraisal Claims Set (ACS) {#sec-ir-acs}

An ACS is a list of ECTs that describe an Attester's actual state.

~~~ cddl
{::include cddl/intrep-acs.cddl}
~~~

### Internal Representation of Attestation Results Set (ARS) {#sec-ir-ars}

An ARS is a list of ECTs that describe ACS entries that are selected for use as Attestation Results.

~~~ cddl
{::include cddl/intrep-ars.cddl}
~~~

## Input Validation and Transformation (Phase 1) {#sec-phase1}

During the initialization phase, the CoRIM Appraisal Context is loaded with various conceptual message inputs such as CoMID tags ({{sec-comid}}), CoSWID tags {{-coswid}}, CoBOM tags {{-cobom}}, and cryptographic validation key material (including raw public keys, root certificates, intermediate CA certificate chains), and Concise Trust Anchor Stores (CoTS) {{-ta-store}}.
These objects will be utilized in the Evidence Appraisal phase that follows.
The primary goal of this phase is to ensure that all necessary information is available for subsequent processing.

After context initialization, additional inputs are held back until appraisal processing has completed.

### Input Validation {#sec-phase1-valid}

#### CoRIM Selection

All available CoRIMs are collected.

CoRIMs that are not within their validity period, or that cannot be associated with an authenticated and authorized source MUST be discarded.

Any CoRIM that has been secured by a cryptographic mechanism, such as a signature, that fails validation MUST be discarded.

Other selection criteria MAY be applied.
For example, if the Evidence format is known in advance, CoRIMs using a profile that is not understood by a Verifier can be readily discarded.

The selection process MUST yield at least one usable tag.

Later stages will further select the CoRIMs appropriate to the Evidence Appraisal stage.

#### Tags Extraction and Validation

The Verifier chooses tags from the selected CoRIMs - including CoMID, CoSWID, CoBOM, and CoTS.

The Verifier MUST discard all tags which are not syntactically and semantically valid.
In particular, any cross-referenced triples (e.g., CoMID-CoSWID linking triples) MUST be successfully resolved.

#### CoBOM Extraction

This section is not applicable if the Verifier appraisal policy does not require CoBOMs.

CoBOMs which are not within their validity period are discarded.

The Verifier processes all CoBOMs that are valid at the point in time of Evidence Appraisal and activates all tags referenced therein.

A Verifier MAY decide to discard some of the available and valid CoBOMs depending on any locally configured authorization policies.
(Such policies model the trust relationships between the Verifier Owner and the relevant suppliers, and are out of the scope of the present document.)
For example, a composite device ({{Section 3.3 of -rats-arch}}) is likely to be fully described by multiple CoRIMs, each signed by a different supplier.
In such case, the Verifier Owner may instruct the Verifier to discard tags activated by supplier CoBOMs that are not also activated by the trusted integrator.

After the Verifier has processed all CoBOMs it MUST discard any tags which have not been activated by a CoBOM.

### Evidence Collection {#sec-ev-coll}

During the Evidence collection phase, the Verifier communicates with Attesters to gather Evidence.
The first part of this phase does not require any cryptographic validation.
This means that Verifiers can use untrusted code to discover Evidence sources.
Attesters are Evidence sources.

Verifiers may rely on conveyance protocol specific context to identify an Evidence source, which is the Evidence input oracle for appraisal.

The collected Evidence is then transformed to an internal representation, making it suitable for appraisal processing.

#### Cryptographic Validation of Evidence {#sec-crypto-validate-evidence}

If Evidence is cryptographically signed, its validation is applied before transforming Evidence to an internal representation.

If Evidence is not cryptographically signed, the security context of the conveyance protocol that collected it is used to cryptographically validate Evidence.

The way cryptographic signature validation works depends on the specific Evidence collection method used.
For example, in DICE, a proof of liveness is carried out on the final key in the certificate chain (a.k.a., the alias certificate).
If this is successful, a suitable certification path is looked up in the Appraisal Context, based on linking information obtained from the DeviceID certificate.
See Section 9.2.1 of {{DICE.Layer}}.
If a trusted root certificate is found, the usual X.509 certificate validation is performed.

As a second example, in PSA {{-psa-token}} the verification public key is looked up in the appraisal context using the `ueid` claim found in the PSA claims-set.
If found, COSE Sign1 verification is performed accordingly.

Regardless of the specific integrity protection method used, the Evidence's integrity MUST be validated successfully.

> If a CoRIM profile is supplied, it MUST describe:
>
> * How cryptographic verification key material is represented (e.g., using Attestation Keys triples, or CoTS tags)
> * How key material is associated with the Attesting Environment
> * How the Attesting Environment is identified in Evidence

### Input Transformation {#sec-phase1-trans}

Input Conceptual Messages, whether Endorsements, Reference Values, Evidence, or Policies, are transformed to an internal representation that is based on ECTs ({{sec-ir-cm}}).

The following mapping conventions apply to all forms of input transformation:

> * The `environment` field is populated with a Target Environment identifier.
> * The `element-list` field is populated with the measurements collected by an Attesting Environment.
> * The `authority` field is populated with the identity of the entity that asserted (e.g., signed) the Conceptual Message.
> * The `cmtype` field is set based on the type of Conceptual Message inputted or to be output.
> * The `profile` field is set based on the `corim-map` `profile` value.

#### Appraisal Context Construction

All of the extracted and validated tags are loaded into an *appraisal context*.
The Appraisal Context contains an internal representation of the inputted Conceptual Messages.
The selected tags are mapped to an internal representation, making them suitable for appraisal processing.

#### Reference Triples Transformation {#sec-ref-trans}

{:rtt-enum: counter="foo" style="format Step %d."}

{: rtt-enum}
* An `rv` list entry ({{sec-ir-ref-val}}) is allocated.

* The `cmtype` of the `addition` ECT in the `rv` entry is set to `reference-values`.

* The Reference Values Triple (RVT) ({{sec-comid-triple-refval}}) populates the `rv` ECTs.

{:rtt2-enum: counter="rtt2" style="format %i"}

{: rtt2-enum}
* RVT.`ref-env`

> > **copy**(`environment-map`, `rv`.`condition`.`environment`.`environment-map`)

> > **copy**(`environment-map`, `rv`.`addition`.`environment`.`environment-map`)

{: rtt2-enum}
* For each e in RVT.`ref-claims`:

> > **copy**(e.`measurement-map`, `rv`.`addition`.`element-list`.`element-map`)

{: rtt-enum}
* The signer of the Endorsement conceptual message is copied to the `rv`.`addition`.`authority` field.

* If the Endorsement conceptual message has a profile, the profile identifier is copied to the `rv`.`addition`.`profile` field.

#### Endorsement Triples Transformations {#sec-end-trans}

Endorsed Values Triple Transformation :

{:ett-enum: counter="ett" style="format Step %d."}

{: ett-enum}
* An `ev` entry ({{sec-ir-end-val}}) is allocated.

* The `cmtype` of the `ev` entry's `addition` ECT is set to `endorsements`.

* The Endorsed Values Triple (EVT) ({{sec-comid-triple-endval}}) populates the `ev` ECTs.

{:ett2-enum: counter="ett2" style="format %i"}

{: ett2-enum}
* EVT.`condition`

> > **copy**(`environment-map`, `ev`.`condition`.`environment`.`environment-map`)

> > **copy**(`environment-map`, `ev`.`addition`.`environment`.`environment-map`)

{: ett2-enum}
* For each e in EVT.`endorsement`:

> > **copy**(e.`endorsement`.`measurement-map`, `ev`.`addition`.`element-list`.`element-map`)

{: ett-enum}
* The signer of the Endorsement conceptual message is copied to the `ev`.`addition`.`authority` field.

* If the Endorsement conceptual message has a profile, the profile is copied to the `ev`.`addition`.`profile` field.

Conditional Endorsement Triple Transformation :

{:cett-enum: counter="cett" style="format Step %d."}

{: cett-enum}
* An `ev` entry ({{sec-ir-end-val}}) is allocated.

* The `cmtype` of the `ev` entry's `addition` ECT is set to `endorsements`.

* Entries in the Conditional Endorsement Triple (CET) ({{sec-comid-triple-cond-endors}}) `conditions` list are copied to a suitable ECT in the internal representation.

{:cett2-enum: counter="cett2" style="format %i"}

{: cett2-enum}

 * For each e in CET.`conditions`:

> > **copy**(e.`stateful-environment-record`.`environment`.`environment-map`, `ev`.`condition`.`environment`.`environment-map`)

> > **copy**(e.`stateful-environment-record`.`claims-list`.`measurement-map`, `ev`.`condition`.`element-list`.`element-map`)

{: cett2-enum}
* For each e in CET.`endorsements`:

> > **copy**(e.`endorsed-triple-record`.`condition`.`environment-map`, `ev`.`addition`.`environment`.`environment-map`)

> > **copy**(e.`endorsed-triple-record`.`endorsement`.`measurement-map`, `ev`.`addition`.`element-list`.`element-map`)

{: cett-enum}
* The signer of the Conditional Endorsement conceptual message is copied to the `ev`.`addition`.`authority` field.

* If the Endorsement conceptual message has a profile, the profile is copied to the `ev`.`addition`.`profile` field.

Conditional Endorsement Series Triple Transformation :

{:cestt-enum: counter="cestt" style="format Step %d."}

{: cestt-enum}
* An `evs` entry ({{sec-ir-end-val}}) is allocated.

* The `cmtype` of the `evs` entry's `addition` ECT is set to `endorsements`.

* Populate the `evs` ECTs using the Conditional Endorsement Series Triple (CEST) ({{sec-comid-triple-cond-series}}).

{:cestt2-enum: counter="cestt2" style="format %i."}

{: cestt2-enum}
* CEST.`condition`:

> > **copy**(`stateful-environment-record`.`environment`.`environment-map`, `evs`.`condition`.`environment`.`environment-map`)

> > **copy**(`stateful-environment-record`.`claims-list`.`measurement-map`, `evs`.`condition`.`element-list`.`element-map`)

{: cestt2-enum}
* For each e in CEST.`series`:

> > **copy**(`evs`.`condition`.`environment`.`environment-map`, `evs`.`series`.`selection`.`environment`.`environment-map`)

> > **copy**(e.`conditional-series-record`.`selection`.`measurement`.`measurement-map`, `evs`.`series`.`selection`.`element-list`.`element-map`)

> > **copy**(`evs`.`condition`.`environment`.`environment-map`, `evs`.`series`.`addition`.`environment`.`environment-map`)

> > **copy**(e.`conditional-series-record`.`addition`.`measurement-map`, `evs`.`series`.`addition`.`element-list`.`element-map`)

{: cestt-enum}
* The signer of the Conditional Endorsement conceptual message is copied to the `evs`.`series`.`addition`.`authority` field.

* If the Endorsement conceptual message has a profile, the profile is copied to the `evs`.`series`.`addition`.`profile` field.

#### Evidence Tranformation

Evidence is transformed from an external representation to an internal representation based on the `ae` relation ({{sec-ir-evidence}}).
The Evidence is mapped into one or more `addition` ECTs.
If the Evidence does not have a value for the mandatory `ae` fields, the Verifier MUST NOT process the Evidence.

Evidence transformation algorithms may be well-known, defined by a CoRIM profile ({{sec-corim-profile-types}}), or supplied dynamically.
The handling of dynamic Evidence transformation algorithms is out of scope for this document.

## Evidence Augmentation (Phase 2) {#sec-phase2}

### Appraisal Claims Set (ACS) Initialization {#sec-acs-initialization}

The ACS is initialized by copying the internal representation of Evidence claims to the ACS.
See {{sec-add-to-acs}}.

#### The authority field in the ACS {#sec-authority}

The `authority` field in an ACS ECT indicates the entity whose authority backs the Claims.

The Verifier keeps track of authority so that it can satisfy appraisal policy that specifies authority.

When adding an Evidence entry to the ACS, the Verifier SHALL set the `authority` field using a `$crypto-keys-type-choice` representation of the entity that signed the Evidence.

If multiple authorities approve the same Claim, for example if multiple key chains are available, then the `authority` field SHALL be set to include the `$crypto-keys-type-choice` representation for each key chain.

When adding Endorsement or Reference Values Claims to the ACS that resulted from CoRIM processing ({{sec-add-to-acs}}).
The Verifier SHALL set the `authority` field using a `$crypto-keys-type-choice` representation of the entity that signed the CoRIM.

When searching the ACS for an entry which matches a triple condition containing an `authorized-by` field, the Verifier SHALL ignore ACS entries if none of the entries present in the condition `authorized-by` field are present in the ACS `authority` field.
The Verifier SHALL match ACS entries if all of the entries present in the condition `authorized-by` field are present in the ACS `authority` field.

#### ACS augmentation using CoMID triples

In the ACS augmentation phase, a CoRIM Appraisal Context and an Evidence Appraisal Policy are used by the Verifier to find CoMID triples which match the ACS.
Triples that specify an ACS matching condition will augment the ACS with Endorsements if the condition is met.

Each triple is processed independently of other triples.
However, the ACS state may change as a result of processing a triple.
If a triple condition does not match, then the Verifier continues to process other triples.

#### Ordering of triple processing

Triples interface with the ACS by either adding new ACS entries or by matching existing ACS entries before updating the ACS.
Most triples use an `environment-map` field to select the ACS entries to match or modify.
This field may be contained in an explicit matching condition, such as `stateful-environment-record`.

The order of triples processing is important.
Processing a triple may result in ACS modifications that affect matching behavior of other triples.

The Verifier MUST ensure that a triple including a matching condition is processed after any other triple that modifies or adds an ACS entry with an `environment-map` that is in the matching condition.

This can be acheived by sorting the triples before processing, by repeating processing of some triples after ACS modifications or by other algorithms.

## Reference Values Corroboration and Augmentation (Phase 3) {#sec-phase3}

Reference Value Providers (RVP) publish Reference Values using the Reference Values Triple ({{sec-comid-triple-refval}}) which are transformed ({{sec-ref-trans}}) into an internal representation ({{sec-ir-ref-val}}).
Reference Values may describe multiple possible Attester states.

Corroboration is the process of determining whether actual Attester state (as contained in the ACS) can be satisfied by Reference Values.
If satisfied, the RVP authority is added to the matching ACS entry.

Reference Values are matched with ACS entries by iterating through the `rv` list.
For each `rv` entry, the `condition` ECT is compared with an ACS ECT, where the ACS ECT `cmtype` contains `evidence`.

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/302

If the ECTs match except for authority, the `rv` `addition` ECT authority is added to the ACS ECT authority.

## Endorsed Values Augmentation (Phase 4) {#sec-phase4}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/179

Endorsers publish Endorsements using endorsement triples (see {{sec-comid-triple-endval}}), {{sec-comid-triple-cond-endors}}, and {{sec-comid-triple-cond-series}}) which are transformed ({{sec-end-trans}}) into an internal representation ({{sec-ir-end-val}}).
Endorsements describe actual Attester state.
Endorsements are added to the ACS if the Endorsement condition is satisifed by the ACS.

### Processing Endorsements {#sec-process-end}

Endorsements are matched with ACS entries by iterating through the `ev` list.
For each `ev` entry, the `condition` ECT is compared with an ACS ECT, where the ACS ECT `cmtype` contains either `evidence` or `endorsements`.
If the ECTs match ({{sec-match-condition-ect}}), the `ev` `addition` ECT is added to the ACS.

### Processing Conditional Endorsements {#sec-process-cond-end}

Conditional Endorsement Triples are transformed into an internal representation based on `ev`.
Conditional endorsements have the same processing steps as shown in ({{sec-process-end}}).

### Processing Conditional Endorsement Series {#sec-process-series}

Conditional Endorsement Series Triples are transformed into an internal representation based on `evs`.
Conditional series endorsements are matched with ACS entries first by iterating through the `evs` list,
where for each `evs` entry, the `condition` ECT is compared with an ACS ECT, where the ACS ECT `cmtype` contains either `evidence` or `endorsements`.
If the ECTs match ({{sec-match-condition-ect}}), the `evs` `series` array is iterated,
where for each `series` entry, if the `selection` ECT matches an ACS ECT,
the `addition` ECT is added to the ACS.
Series processing terminates when the first series entry matches.

## Examples for optional phases 5, 6, and 7 {#sec-phases567}

Phases 5, 6, and 7 are optional depending on implementation design.
Verifier implementations that apply consistency, integrity, or validity checks could be represented as Claims that augment the ACS or could be handled by application specific interfaces.
Processing appraisal policies may result in augmentation or modification of the ACS, but techniques for tracking the application of policies during appraisal need not result in ACS augmentation.
Additionally, the creation of Attestation Results is out-of-scope for this document, nevertheless internal staging may facilitate processing of Attestation Results.

Phase 5: Verifier Augmentation

Claims related to Verifier-applied consistency checks are asserted under the authority of the Verifier.
For example, the `attest-key-triple-record` may contain a cryptographic key to which the Verifier applies certificate path construction and validation.
Validation may reveal an expired certificate.
The Verifier implementation might generate a certificate path validation exception that is handled externally, or it could generate a Claim that the certificate path is invalid.

Phase 6: Policy Augmentation

Appraisal policy inputs could result in Claims that augment the ACS.
For example, an Appraisal Policy for Evidence may specify that if all of a collection of subcomponents satisfy a particular quality metric, the top-level component also satisfies the quality metric.
The Verifier might generate an Endorsement ECT for the top-level component that asserts a quality metric.
Details about the policy applied may also augment the ACS.
An internal representation of policy details, based on the policy ECT, as described in {{sec-ir-policy}}, contains the environments affected by the policy with policy identifiers as Claims.

Phase 7: Attestation Results Production and Transformation

Attestation Results rely on input from the ACS, but may not bear any similarity to its content.
For example, Attestation Results processing may map the ACS state to a generalized trustworthiness state such as {{-ar4si}}.
Generated Attestation Results Claims may be specific to a particular Relying Party.
Hence, the Verifier may need to maintain multiple Attestation Results contexts.
An internal representation of Attestation Results as separate contexts ({{sec-ir-ars}}) ensures Relying Party–specific processing does not modify the ACS, which is common to all Relying Parties.
Attestation Results contexts are the inputs to Attestation Results procedures that produce external representations.

## Adding to the Appraisal Claims Set (ACS) {#sec-add-to-acs}

### ACS Processing Requirements {#sec-acs-reqs}

At the end of the Evidence collection process Evidence has been converted into an internal represenetation suitable for appraisal.
See {{sec-ir-cm}}.

Verifiers are not required to use this as their internal representation.
For the purposes of this document, appraisal is described in terms of the above cited internal representation.

ACS entries contain Evidence (from Attesters), corroborated Reference Values, and Endorsements.
The ACS SHALL contain the Attester's *actual state* as defined by its Target Environments (TEs).

Each ACS ECT entry SHALL contain `authority`.
See {{sec-authority}}.
There can be multiple entries in the ACS which have the same `environment-map` and a different authority.

Each ACS entry is an ECT Claim.
The ECT `environment` and `element-id` together define the Claim's name.
The ECT `element-claims` are the Claim's *actual state*.

This specification defines rules for determining when two Claim names are equivalent.
See {{sec-compare-environment}} and {{sec-compare-element-map}}.
Equivalence typically means values MUST be binary identical.

If two Claims have the same Claim name, the CoRIM triples instruct the Verifier on how these Claims are related.

If multiple Claims have the same name and the measurement values (i.e., `measurement-values-map` codepoints and values) are equivalent, they are considered *duplicates*.
Duplicate claims SHOULD be omitted.

If multiple Claims have the same name and `measurement-values-map` contains duplicate codepoints but the measurement values are not equivalent, then a Verifier SHALL report an error and stop validation processing.

### ACS Augmentation Requirements {#sec-acs-aug}

The ordering of ECTs in the ACS is not significant.
Logically, new ECT entries are appended to the existing ACS.
Nevertheless, implementations may optimize ECT order, to achieve better performance.
Additions to the ACS MUST be atomic.

## Comparing a condition ECT against the ACS {#sec-match-condition-ect}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71


A Verifier SHALL iterate over all ACS entries and SHALL attempt to match the condition ECT against each ACS entry. See {{sec-match-one-condition-ect}}.
A Verifier SHALL create a "matched entries" set, and SHALL populate it with all ACS entries which matched the condition ECT.

If the matched entries array is not empty, then the condition ECT matches the ACS.

If the matched entries array is empty, then the condition ECT does not match the ACS.

### Comparing a condition ECT against a single ACS entry {#sec-match-one-condition-ect}

If the condition ECT contains a profile and the profile defines an algorithm for a codepoint and `environment-map` then a Verifier MUST use the algorithm defined by the profile (or a standard algorithm if the profile defines that).
If the condition ECT contains a profile, but the profile does not define an algorithm for a particular codepoint and `environment-map` then the verifier MUST use the standard algorithm described in this document to compare the data at that codepoint.

A Verifier SHALL perform all of the comparisons defined in {{sec-compare-environment}}, {{sec-compare-authority}}, and {{sec-compare-element-list}}.

Each of these comparisons compares one field in the condition ECT against the same field in the ACS entry.

If all of the fields match, then the condition ECT matches the ACS entry.

If any of the fields does not match, then the condition ECT does not match the ACS entry.

### Environment Comparison {#sec-compare-environment}

A Verifier SHALL compare each field which is present in the condition ECT `environment-map` against the corresponding field in the ACS entry `environment-map` using binary comparison.
Before performing the binary comparison, a Verifier SHOULD convert both `environment-map` fields into a form which meets CBOR Core Deterministic Encoding Requirements {{-cbor}}.

If all fields which are present in the condition ECT `environment-map` are present in the ACS entry and are binary identical, then the environments match.

If any field which is present in the condition ECT `environment-map` is not present in the ACS entry, then the environments do not match.

If any field which is present in the condition ECT `environment-map` is not binary identical to the corresponding ACS entry field, then the environments do not match.

If a field is not present in the condition ECT `environment-map` then the presence of, and value of, the corresponding ACS entry field SHALL NOT affect whether the environments match.

### Authority comparison {#sec-compare-authority}

A Verifier SHALL compare the condition ECT's `authority` value to the candidate entry's `authority` value.

If every entry in the condition ECT `authority` has a matching entry in the ACS entry `authority` field, then the authorities match.
The order of the fields in each `authority` field do not affect the result of the comparison.

If any entry in the condition ECT `authority` does not have a matching entry in the ACS entry `authority` field then the authorities do not match.

When comparing two `$crypto-key-type-choice` fields for equality, a Verifier SHALL treat them as equal if their deterministic CBOR encoding is binary equal.

### Element list comparison {#sec-compare-element-list}

A Verifier SHALL iterate over all the entries in the condition ECT `element-list` and compare each one against the corresponding entry in the ACS entry `element-list`.

If every entry in the condition ECT `element-list` has a matching entry in the ACS entry `element-list` field then the element lists match.

The order of the fields in each `element-list` field do not affect the result of the comparison.

If any entry in the condition ECT `element-list` does not have a matching entry in the ACS entry `element-list` field then the `element-list` do not match.

### Element map comparison {#sec-compare-element-map}

A Verifier shall compare each `element-map` within the condition ECT `element-list` against the ACS entry `element-list`.

First, a Verifier SHALL locate the entries in the ACS entry `element-list` which have a matching `element-id` as the condition ECT `element-map`.
Two `element-id` fields are the same if they are either both omitted, or both present with binary identical deterministic encodings.

Before performing the binary comparison, a Verifier SHOULD convert both fields into a form which meets CBOR Core Deterministic Encoding Requirements {{-cbor}}.

If any condition ECT entry `element-id` does not have a corresponding `element-id` in the ACS entry then the element map does not match.

If any condition ECT entry has multiple corresponding `element-id`s then the element map does not match.

Second, a Verifier SHALL compare the `element-claims` field within the condition ECT `element-list` and the corresponding field from the ACS entry.
See {{sec-compare-mvm}}.

### Measurement values map map Comparison {#sec-compare-mvm}

A Verifier SHALL iterate over the codepoints which are present in the condition ECT element's `measurement-values-map`.
Each of the codepoints present in the condition ECT `measurement-values-map` is compared against the same codepoint in the candidate entry `measurement-values-map`.

If any codepoint present in the condition ECT `measurement-values-map` does not have a corresponding codepoint within the candidate entry `measurement-values-map` then Verifier SHALL remove that candidate entry from the candidate entries array.

If any codepoint present in the condition ECT `measurement-values-map` does not match the same codepoint within the candidate entry `measurement-values-map` then Verifier SHALL remove that candidate entry from the candidate entries array.

#### Comparison of a single measurement-values-map codepoint {#sec-match-one-codepoint}

A Verifier SHALL compare each condition ECT `measurement-values-map` value against the corresponding ACS entry value using the appropriate algorithm.

Non-negative codepoints represent standard data representations.
The comparison algorithms for these are defined in this document (in the sections below) or in other specifications.
For some non-negative codepoints their behavior is modified by the CBOR tag at the start of the condition ECT `measurement-values-map` value.

Negative codepoints represent profile defined data representations.
A Verifier SHALL use the codepoint number, the profile associated with the condition ECT, and the tag value (if present) to select the comparison algorithm.

If a Verifier is unable to determine the comparison algorithm which applies to a codepoint then it SHALL behave as though the candidate entry does not match the condition ECT.

Profile writers SHOULD use CBOR tags for widely applicable comparison methods to ease Verifier implementation compliance across profiles.

The following subsections define the comparison algorithms for the `measurement-values-map` codepoints defined by this specification.

##### Comparison for version entries

The value stored under `measurement-values-map` codepoint 0 is an version label, which must have type `version-map`.
Two `version-map` values can only be compared for equality, as they are colloquial versions that cannot specify ordering.

##### Comparison for svn entries

The ACS entry value stored under `measurement-values-map` codepoint 1 is a security version number, which must have type `svn-type`.

If the entry `svn-type` is a `uint` or a `uint` tagged with #6.552, then comparison with the `uint` named as SVN is as follows.

*  If the condition ECT value for `measurement-values-map` codepoint 1 is an untagged `uint` or a `uint` tagged with #6.552 then an equality comparison is performed on the `uint` components.
The comparison MUST return true if the value of SVN is equal to the `uint` value in the condition ECT.

*  If the condition ECT value for `measurement-values-map` codepoint 1 is a `uint` tagged with #6.553 then a minimum comparison is performed.
The comparison MUST return true if the value of SVN is less or equal to than the `uint` value in the condition ECT.

If the entry `svn-type` is a `uint` tagged with #6.553, then comparison with the `uint` named as MINSVN is as follows.

*  If the condition ECT value for `measurement-values-map` codepoint 1 is an untagged `uint` or a `uint` tagged with #6.552 then the comparison MUST return false.

*  If the condition ECT value for `measurement-values-map` codepoint 1 is a `uint` tagged with #6.553 then an equality comparison is performed.
The comparison MUST return true if the value of MINSVN is equal to the `uint` value in the condition ECT.

The meaning of a minimum SVN as an entry value is only meaningful as an endorsed value that has been added to the ACS.
The condition therefore treats the minimum SVN as an exact state and not one to compare with inequality.

##### Comparison for digests entries {#sec-cmp-digests}

A `digests` entry contains one or more digests, each measuring the same object.
When multiple digests are provided, each represents a different algorithm acceptable to the condition ECT author.

In the simple case, a condition ECT digests entry containing one digest matches matches a candidate entry containing a single entry with the same algorithm and value.

To prevent downgrade attacks, if there are multiple algorithms in common between the condition ECT and candidate entry, then the bytes paired with common algorithms must be equal.
A Verifier SHALL treat two algorithm identifiers as equal if they have the same deterministic binary encoding.
If both an integer and a string representation are defined for an algorithm then entities creating ECTs SHOULD use the integer representation.
If condition ECT and ACS entry use different names for the same algorithm, and the Verifier does not recognize that they are the same, then a downgrade attack is possible.

The comparison MUST return false if the CBOR encoding of the `digests` entry in the condition ECT or the ACS value with the same codepoint is incorrect (for example if fields are missing or the wrong type).

The comparison MUST return false if the condition ECT digests entry does not contain any digests.

The comparison MUST return false if either digests entry contains multiple values for the same hash algorithm.

The Verifier MUST iterate over the condition ECT `digests` array, locating common hash algorithm identifiers (which are present in the condition ECT and in the candidate entry).
If the value associated with any common hash algorithm identifier in the condition ECT differs from the value for the same algorithm identifier in the candidate entry then the comparison MUST return false.

The comparison MUST return false if there are no hash algorithms from the condition ECT in common with the hash algorithms from the candidate entry ECT.

##### Comparison for raw-value entries


[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71

##### Comparison for cryptokeys entries {#sec-cryptokeys-matching}


The CBOR tag of the first entry of the condition ECT `cryptokeys` array is compared with the CBOR tag of the first entry of the candidate entry `cryptokeys` value.
If the CBOR tags match, then the bytes following the CBOR tag from the condition ECT entry are compared with the bytes following the CBOR tag from the candidate entry.
If the byte strings match, and there is another array entry, then the next entry from the condition ECTs array is likewise compared with the next entry of the ACS array.
If all entries of the condition ECTs array match a corresponding entry in the ACS array, then the `cryptokeys` condition ECT matches.
Otherwise, `cryptokeys` does not match.

##### Comparison for Integrity Registers {#sec-cmp-integrity-registers}

For each Integrity Register entry in the condition ECT, the Verifier will use the associated identifier (i.e., `integrity-register-id-type-choice`) to look up the matching Integrity Register entry in the candidate entry.
If no entry is found, the comparison MUST return false.
Instead, if an entry is found, the digest comparison proceeds as defined in {{sec-cmp-digests}} after equivalence has been found according to {{sec-comid-integrity-registers}}.
Note that it is not required for all the entries in the candidate entry to be used during matching: the condition ECT could consist of a subset of the device's register space. In TPM parlance, a TPM "quote" may report all PCRs in Evidence, while a condition ECT could describe a subset of PCRs.

### Profile-directed Comparison {#sec-compare-profile}

A profile MUST specify comparison algorithms for its additions to `$`-prefixed CoRIM CDDL codepoints when this specification does not prescribe binary comparison.
The profile must specify how to compare the CBOR tagged Reference Value against the ACS.

Note that a Verifier may compare Reference Values in any order, so the comparison should not be stateful.

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

* Brief general description: The `corim/corim` and `corim/comid` packages
  provide a golang API for low-level manipulation of Concise Reference
  Integrity Manifest (CoRIM) and Concise Module Identifier (CoMID) tags
  respectively.  The `corim/cocli` package uses the API above (as well as the
  API from the `veraison/swid` package) to provide a user command line
  interface for working with CoRIM, CoMID and CoSWID. Specifically, it allows
  creating, signing, verifying, displaying, uploading, and more. See
  [https://github.com/cocli/README.md](https://github.com/veraison/corim/blob/main/cocli/README.md) for
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

Evidence appraisal is at the core of any RATS protocol flow, mediating all interactions between Attesters and their Relying Parties.
The Verifier is effectively part of the Attesters' and Relying Parties' trusted computing base (TCB).
Any mistake in the appraisal process could have security implications.
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

The appraisal process should be auditable and reproducible.
The integrity of the code and data during execution should be made an explicit objective, for example ensuring that the appraisal functions are computed in an attestable trusted execution environment (TEE).

The integrity of public and private key material and the secrecy of private key material must be ensured at all times.
This includes key material carried in attestation key triples and key material used to verify the authority of triples (such as public keys that identify trusted supply chain actors).
For more detailed information on protecting Trust Anchors, refer to {{Section 12.4 of -rats-arch}}.

The Verifier should use cryptographically protected, mutually authenticated secure channels to all its trusted input sources (Endorsers, RVPs, Verifier Owners).
These links must reach as deep as possible - possibly terminating within the appraisal session context - to avoid man-in-the-middle attacks.
Also consider minimizing the use of intermediaries: each intermediary becomes another party that needs to be trusted and therefore factored in the Attesters and Relying Parties' TCBs.
Refer to {{Section 12.2 of -rats-arch}} for information on Conceptual Messages protection.

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/11

# IANA Considerations {#sec-iana-cons}

## New COSE Header Parameters

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/12

## New CBOR Tags {#sec-iana-cbor-tags}

IANA is requested to allocate the following tags in the "CBOR Tags" registry {{!IANA.cbor-tags}}, preferably with the specific CBOR tag value requested:

|     Tag | Data Item           | Semantics                                                     | Reference |
|     --- | ---------           | ---------                                                     | --------- |
|     500 | `tag`               | A tagged-concise-rim-type-choice, see {{sec-corim-tags}}      | {{&SELF}} |
|     501 | `map`               | A tagged-corim-map, see {{sec-corim-map}}                     | {{&SELF}} |
|     502 | `tag`               | A tagged-signed-corim, see {{sec-corim-signed}}               | {{&SELF}} |
| 503-504 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |
|     505 | `bytes`             | A tagged-concise-swid-tag, see {{sec-corim-tags}}             | {{&SELF}} |
|     506 | `bytes`             | A tagged-concise-mid-tag, see {{sec-corim-tags}}              | {{&SELF}} |
|     507 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |
|     508 | `bytes`             | A tagged-concise-bom-tag, see {{sec-corim-tags}}              | {{&SELF}} |
| 509-549 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |
|     550 | `bytes .size 33`    | tagged-ueid-type, see {{sec-common-ueid}}                     | {{&SELF}} |
|     552 | `uint`              | tagged-svn, see {{sec-comid-svn}}                             | {{&SELF}} |
|     553 | `uint`              | tagged-min-svn, see {{sec-comid-svn}}                         | {{&SELF}} |
|     554 | `text`              | tagged-pkix-base64-key-type, see {{sec-crypto-keys}}          | {{&SELF}} |
|     555 | `text`              | tagged-pkix-base64-cert-type, see {{sec-crypto-keys}}         | {{&SELF}} |
|     556 | `text`              | tagged-pkix-base64-cert-path-type, see {{sec-crypto-keys}}    | {{&SELF}} |
|     557 | `[int/text, bytes]` | tagged-thumbprint-type, see {{sec-common-hash-entry}}         | {{&SELF}} |
|     558 | `COSE_Key/ COSE_KeySet`   | tagged-cose-key-type, see {{sec-crypto-keys}}           | {{&SELF}} |
|     559 | `digest`            | tagged-cert-thumbprint-type, see {{sec-crypto-keys}}          | {{&SELF}} |
|     560 | `bytes`             | tagged-bytes, see {{sec-common-tagged-bytes}}                 | {{&SELF}} |
|     561 | `digest`            | tagged-cert-path-thumbprint-type, see {{sec-crypto-keys}}     | {{&SELF}} |
|     562 | `bytes`             | tagged-pkix-asn1der-cert-type, see {{sec-crypto-keys}}        | {{&SELF}} |
| 563-599 | `any`               | Earmarked for CoRIM                                           | {{&SELF}} |

Tags designated as "Earmarked for CoRIM" can be reassigned by IANA based on advice from the designated expert for the CBOR Tags registry.

## CoRIM Map Registry {#sec-iana-corim}

This document defines a new registry titled "CoRIM Map".
The registry uses integer values as index values for items in 'unsigned-corim-map' CBOR maps.

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

## CoMID Map Registry {#sec-iana-comid}

This document defines a new registry titled "CoMID Map".
The registry uses integer values as index values for items in 'concise-mid-tag' CBOR maps.

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

## CoBOM Map Registry {#sec-iana-cobom}

This document defines a new registry titled "CoBOM Map".
The registry uses integer values as index values for items in 'concise-bom-tag' CBOR maps.

Future registrations for this registry are to be made based on {{?RFC8126}} as follows:

| Range             | Registration Procedures
|---
| 0-127    | Standards Action
| 128-255  | Specification Required
{: #tbl-iana-cobom-map-items-reg-procedures title="CoBOM Map Items Registration Procedures"}

All negative values are reserved for Private Use.

Initial registrations for the "CoBOM Map" registry are provided below.
Assignments consist of an integer index value, the item name, and a reference to the defining specification.

| Index | Item Name | Specification
|---
| 0 | tag-identity | {{&SELF}}
| 1 | tags-list | {{&SELF}}
| 2 | bom-validity | {{&SELF}}
| 5-255 | Unassigned
{: #tbl-iana-cobom-map-items title="CoBOM Map Items Initial Registrations"}

## New Media Types {#sec-iana-media-types}

IANA is requested to add the following media types to the "Media Types"
registry {{!IANA.media-types}}.

| Name | Template | Reference |
| corim-signed+cbor | application/corim-signed+cbor | {{&SELF}}, ({{sec-mt-corim-signed}}) |
| corim-unsigned+cbor | application/corim-unsigned+cbor | {{&SELF}}, ({{sec-mt-corim-unsigned}}) |
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
: ({{sec-sec}}) of {{&SELF}}

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
| application/corim-signed+cbor | - | TBD1 | {{&SELF}} |
| application/corim-unsigned+cbor | - | TBD2 | {{&SELF}} |
{: align="left" title="New Content-Formats"}

--- back

# Base CoRIM CDDL {#sec-corim-cddl}

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
