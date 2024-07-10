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
  SPDM:
    title: Security Protocol and Data Model (SPDM)
    author:
      org: Distributed Management Task Force
    seriesinfo: Version 1.3.0
    date: May 2023
    target: https://www.dmtf.org/sites/default/files/standards/documents/DSP0274_1.3.0.pdf
  CE.SPDM:
    title: TCG DICE Concise Evidence Binding for SPDM
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.00, Revision 0.54
    date: January 2024
    target: https://trustedcomputinggroup.org/wp-content/uploads/TCG-DICE-Concise-Evidence-Binding-for-SPDM-Version-1.0-Revision-54_pub.pdf
  DICE.AA:
    title: DICE Attestation Architecture
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.1, Revision 0.17, public review
    date: May 2023
    target: https://trustedcomputinggroup.org/wp-content/uploads/DICE-Attestation-Architecture-Version-1.1-Revision-17_1August2023.pdf
  I-D.ietf-rats-eat: eat
  I-D.ietf-rats-concise-ta-stores: ta-store

entity:
  SELF: "RFCthis"

--- abstract

Remote Attestation Procedures (RATS) enable Relying Parties to assess the trustworthiness of a remote Attester and therefore to decide whether to engage in secure interactions with it - or not.
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
CoRIM enables Verifiers to reconcile a complex distributed supply chain into a single homogeneous view. See {{sec-verifier-rec}}.

## Terminology and Requirements Language

This document uses terms and concepts defined by the RATS architecture.
For a complete glossary see {{Section 4 of -rats-arch}}.

In this document, the term CoRIM message and CoRIM documents are used as synonyms. A CoRIM data structure can be at rest (e.g., residing in a file system as a document) or can be in flight (e.g., conveyed as a message in a protocol exchange). The bytes composing the CoRIM data structure are the same either way.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}. Terms and concepts are always referenced as proper nouns, i.e., with Capital Letters.

{::boilerplate bcp14}

# Verifier Reconciliation {#sec-verifier-rec}

This specification describes the CoRIM format and documents how a Verifier should process the CoRIM to enable CoRIM authors to convey their intended meaning.
A Verifier needs to reconcile its various inputs, with CoRIM being one of them.
In addition to the external CoRIM documents, the Verifier is expected to create an internal representation for each input and map each external representation to an internal one.
By using the internal representation, the Verifier processes inputs as if they are part of a conversation, keeping track of who said what.
The origin of the inputs is tracked as *authority*.
The authority for the Claims in a CoRIM is the CoRIM issuer.

Effectively, Attesters, Reference Value Providers, Endorsers, Verifier Owners, Relying Parties, and even the Verifier potentially all contribute to the conversation.
Each producer of corresponding RATS Conceptual Messages can assert Claims about an Attester's actual or allowed state.
The Verifier's objective is to produce a list of Claims that describe the Attester's presumed actual state.
Producers of RATS Conceptual Messages can assert contradictory assertions.
For example, a compromised Attester may produce false claims that conflict with the Reference Values provided by a Reference Value Provider (RVP).
In essence, if Evidence is not corroborated by an RVP's Claims, then the RVP's Claims are not included in the internal representation of an Attester's actual state, a.k.a., Appraisal Claims Set (ACS).

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

# Concise Reference Integrity Manifest (CoRIM) {#sec-corim}

A CoRIM is a collection of tags and related metadata in a concise CBOR {{-cbor}} encoding.
A CoRIM can be digitally signed with a COSE {{-cose}} signature.
A tag identifies and describes properties of modules or components of a system.

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

* A profile identifier, which is used to interpret the information contained in the enclosed tags.
A profile allows the base CoRIM CDDL definition to be customized to fit a specific Attester by augmenting the base CDDL data definition via the specified extension points or by constraining types defined.
A profile MUST NOT change the base CoRIM CDDL definition's semantics, which includes not changing or overloading names and numbers registered at IANA registries used by this document.
For more detail, see {{sec-corim-profile-types}},

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

A profile defines which of the optional parts of a CoRIM are required, which are prohibited and which extension points are exercised and how.
A profile MUST NOT alter the syntax or semantics of CoRIM types defined in this document.

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

For an example profile definition, see {{-psa-endorsements}}.

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

The CoRIM protected header map uses some common COSE header parameters plus an additional `corim-meta` parameter.
The following describes each child item of this map.

* `alg` (index 1): An integer that identifies a signature algorithm.

* `content-type` (index 3): A string that represents the "MIME Content type" carried in the CoRIM payload.

* `kid` (index 4): A bit string which is a key identity pertaining to the CoRIM Issuer.

* `corim-meta` (index 8): A map that contains metadata associated with a signed CoRIM.
  Described in {{sec-corim-meta}}.

Additional data can be included in the COSE header map as per {{Section 3 of -cose}}.

### Meta Map {#sec-corim-meta}

The CoRIM meta map identifies the entity or entities that create and sign the CoRIM.
This ensures the consumer is able to identify credentials used to authenticate its signer.

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

* `conditional-endorsement-triples` (index 9) Triples describing a series of
  Endorsement that are applicable based on the acceptance of a series of
  stateful environment records. Described in
  {{sec-comid-triple-cond-endors}}.

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
  See {{sec-comid-instance}}.

* `group` (index 2): identifier for a group of instances, e.g., if an
  anonymization scheme is used.

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
  Typically, `class-id` is an object identifier (OID) variable-length opaque byte string ({{sec-common-tagged-bytes}}) or universally unique
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

##### Environment Instance {#sec-comid-instance}

An instance carries a unique identifier that is reliably bound to a Target Environment
that is an instance of the Attester.

The types defined for an instance identifier are CBOR tagged expressions of
UEID, UUID, variable-length opaque byte string ({{sec-common-tagged-bytes}}), or cryptographic key identifier.

~~~ cddl
{::include cddl/instance-id-type-choice.cddl}
~~~

##### Environment Group

A group carries a unique identifier that is reliably bound to a group of
Attesters, for example when a number of Attester are hidden in the same
anonymity set.

The types defined for a group identified are UUID and variable-length opaque byte string ({{sec-common-tagged-bytes}}).

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
Instance measurements apply to a specific Attester instance.  Environments
identified by a class identifier have measurements that are common to the
class. Environments identified by an instance identifier have measurements that
are specific to that instance.

The supply chain entity that is responsible for providing the the measurements (i.e. Reference Values or Endorsed Values)
is by default the CoRIM signer. If a different entity is authorized to provide measurement values,
the `authorized-by` statement can be supplied in the `measurement-map`.


~~~ cddl
{::include cddl/measurement-map.cddl}
~~~

The following describes each member of the `measurement-map`:

* `mkey` (index 0): An optional unique identifier of the measured
  (sub-)environment.  See {{sec-comid-mkey}}.

* `mval` (index 1): The measurements associated with the (sub-)environment.
  Described in {{sec-comid-mval}}.

* `authorized-by` (index 2): The cryptographic identity of the individual or organization that is
 the designated authority for this measurement. For example, producer of the measurement or a delegated supplier.

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

Measurement values may support use cases beyond Verifier appraisal.
Typically, a Relying Party determines if additional processing is desirable
and whether the processing is applied by the Verifier or the Relying Party.

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
  together with the respective hash algorithm used in the process.
  It uses the `digests-type` described in {{sec-common-hash-entry}}.

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
  Defined in {{Section 7 of -cose}}

A cryptographic key digest can be one of the following formats:

* `tagged-thumbprint-type`: a `digest` of a raw public key. The digest value may
  be used to find the public key if contained in a lookup table.

* `tagged-cert-thumbprint-type`: a `digest` of a certificate.
  The digest value may be used to find the certificate if contained in a lookup table.

* `tagged-cert-path-thumbprint-type`: a `digest` of a certification path.
  The digest value may be used to find the certificate path if contained in a lookup table.

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

A Device Identity triple record relates one or more cryptographic keys to a device identity.
The cryptographic keys are bound to or associated with a Target Environment that is within the device.
The device identifier may be part of the Target Environment's `environment-map` or may be part of some other device identity credential, such as a certificate.
The cryptographic keys are expected to be used to authenticate the device.

Device Identity triples instruct a Verifier to perform key validation checks, such as revocation, certificate path construction & verification, or proof of possession.
The Verifier SHOULD perform offline verification of keys contained in Device Identity triples.

A Device Identity triple endorses that the keys were securely provisioned to the named Target Environment.
Additional details about how a key was provisioned or is protected may be asserted using Endorsements such as `endorsed-triples`.

Depending on key formatting, as defined by `$crypto-key-type-choice`, the Verifier may take different steps to locate and verify the key.

If a key has usage restrictions that limit its use to device identity challenges, Verifiers SHOULD check for key use that violates usage restrictions.

Offline verification of keys or verification of key use restrictions MAY produce Claims that are added to the ACS.
Alternatively, Verifiers MAY report key verification results as part of an error reporting function.

~~~ cddl
{::include cddl/identity-triple-record.cddl}
~~~

#### Attest Key Triple {#sec-comid-triple-attest-key}

An Attest Key triple record relates one or more cryptographic keys to an Attesting Environment.
The cryptographic keys are wielded by an Attesting Environment that collects measurements from a Target Environment.
The cryptographic keys sign Evidence.
Attest Key triples instruct a Verifier to perform key validation checks, such as revocation, certificate path construction & verification, or proof of possession.
The Verifier SHOULD perform offline verification of keys contained in Attest Key triples.

Attest Key triples endorse that the keys were securely provisioned to the named (identified via an `environment-map`) Attesting Environment.
Additional details about how a key was provisioned or is protected may be asserted using Endorsements such as `endorsed-triples`.

Depending on key formatting, as defined by `$crypto-key-type-choice`, the Verifier may take different steps to locate and verify the key.
If a key has usage restrictions that limits its use to Evidence signing, Verifiers SHOULD check for key use that violates usage restrictions.

Offline verification of keys or verification of key use restrictions MAY produce Claims that are added to the ACS.
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
The Endorsed Values are accepted if the series condition in a `conditional-series-record` matches the ACS.
The first `conditional-series-record` that successfully matches an ACS Entry terminates the matching and the corresponding Endorsed Values are accepted.
If none of the series conditions match an ACS Entry, the triple is not matched,
and no Endorsed values are accepted.

The `authorized-by` value in `measurement-map` in the stateful environment, if present,
applies to all measurements in the triple, including `conditional-series-record` records.

~~~ cddl
{::include cddl/conditional-endorsement-series-triple-record.cddl}
~~~

~~~ cddl
{::include cddl/conditional-series-record.cddl}
~~~

#### Conditional Endorsement Triple {#sec-comid-triple-cond-endors}

The semantics of the Conditional Endorsement Triple is as follows:

> "IF accepted state matches all `conds` values, THEN every entry in the `endorsements` is added to the accepted state"

~~~ cddl
{::include cddl/conditional-endorsement-triple-record.cddl}
~~~

A `conditional-endorsement-triple-record` has the following parameters:

* `conditions`: all target environments, along with a specific state, that need to match `state-triples` entries in the ACS for the endorsement(s) to apply
* `endorsements`: endorsements that are added to the ACS `state-triples` if all `conds` match.

The order in which Conditional Endorsement triples are evaluated is important: different sorting may produce different end-results in the computed ACS.

Therefore, the set of applicable Conditional Endorsement triples MUST be topologically sorted based on the criterion that a Conditional Endorsement triple is evaluated before another if its Target Environment and Endorsement pair is found in any of the stateful environments of the subsequent triple.

Notes:

* In order to give the expected result, the condition must describe the expected context completely.
* The scope of a single Conditional Endorsement triple encompasses an arbitrary amount of environments across all layers in an Attester.

There are scope-related questions that need to be answered.  ([^tracked-at] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/176)

## Extensibility {#sec-extensibility}

The base CORIM schema is described using CDDL {{-cddl}} that can be extended
only at specific allowed points known as "extension points"

The following types of extensions are supported in CoRIM

### Map Extensions
Map Extensions provides extensibility support to CoRIM Map structures.
CDDL map extensibility enables a CoRIM profile to extend the base CoRIM definition.
CDDL map extension points have the form `($$NAME-extension)` where "NAME" is the name of the map
and '$$' signifies map extensibility. Typically, map extension requires a convention
for code point naming that avoids code-point reuse.
Well-known code points may be in a registry, such as CoSWID {{-coswid-reg}}.
Non-negative integers are reserved for IANA to assign meaning globally.

### Data Type Extensions

Data type extensibility has the form `($NAME-type-choice)` where "NAME" is the type name
and '$' signifies type extensibility.

Schema extensions (Map or Data Type) should be documented to facilitate interoperability. CoRIM profiles are best used to document vendor or industry defined extensions.

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

Used to tag a byte string as a binary UUID defined in {{Section 4.1.2. of
-uuid}}.

~~~ cddl
{::include cddl/uuid.cddl}
~~~

## UEID {#sec-common-ueid}

Used to tag a byte string as Universal Entity ID Claim (UUID) defined in
{{Section 4.2.1 of -eat}}.

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
CoRIM data structures may be used by Evidence and Attestation Results that wish to describe overlapping structure.
CoRIM-based data structures define an external representation of Conceptual Messages that are mapped to an internal representation.
Appraisal processing describes both mapping transformations and Verifier reconciliation {{sec-verifier-rec}}.
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

> *[Ned] Suggest we use Environment-Properties Tuple (EPT) since the use of claim here is more focused than what is possible given the definition above.*

reference state:
: Claims that describe various alternative states of a Target Environment.  Reference Values Claims typically describe various possible states due to versioning, manufactruing practices, or supplier configuration options.  See also {{Section 2 of -rats-endorsements}}.

actual state:
: Claims that describe a Target Environment instance at a given point in time.  Endorsed Values and Evidence typically are Claims about actual state.  An Attester may be composed of multiple components, where each component may represent a scope of appraisal.  See also {{Section 2 of -rats-endorsements}}.

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

Conceptual Messages are the inputs to a Verifier and may include Evidence, Reference Values, Endorsed Values, or Appraisal Policy.
Internal representations of Conceptual Messages are defined by {{sec-ir-evidence}}, {{sec-ir-ref-val}}, and {{sec-ir-end-val}}.
The internal representation of Conceptual Messages are constructed from a common building block structure called Environment-Claims Tuple (ECT).
Additionally, ECTs define an internal representation of the ACS and ARS. See {{sec-ir-acs}} and {{sec-ir-ars}}.

ECTs have six attributes:

1. The environment.
2. The properties of the environment.
3. The authority.
4. The name space.
5. The Conceptual Message type.
6. The profile.

Environment (label 1):

: Identifies the Target Environment. Environments are identified using instance, class, or group identifiers. Typically,  composite Attester's are composed of components, each having an environment identifier.

Properties (label 2):

: Properties of the Target Environment.

Authority (label 3):

: Identifies the entity that issued the tuple. A certain type of key material by which the authority (and corresponding provenance) of the tuple can be determined, such as the public key of an asymmetric key pair that is associated with an authority's PKIX certificate.

Name Space (label 4):

: Identifies the name space from which the tuple was created.

CM Type (label 5):

: Identifies the type of Conceptual Message that originated the tuple.

Profile (label 6):

: The profile that defines this tuple. If no profile is used, this attribute is omitted.

~~~ cddl
ECT = {
  ? e: environment-map
  ? c: claims-map / [ + local-claim ]
  ? a: [ + $crypto-key-type-choice ]
  ? ns: text
  ? cm: cm-type
  ? p: $profile-type-choice
}
local-claim = {
  le: local-environment
  c: claims-map
}
local-environment =  bstr / tstr
cm-type =  &(
  reference-values: 0
  endorsements: 1
  evidence: 2
  attestation-results: 3
  verifier: 4
  policy: 5
)
~~~

Although all of the ECT attributes are optional, the Conceptual Message type implies certain attributes are mandatory.
See {{sec-ir-evidence}}, {{sec-ir-ref-val}}, and {{sec-ir-end-val}}.

#### Internal Representation of Evidence {#sec-ir-evidence}

An internal representation of attestation Evidence uses the `ae` relation.
The profile identifier for attestation Evidence does not need to be the same as a CoRIM profile that provides reference values.
A CoRIM profile that provides reference values for Evidence MUST be compatible with the Evidence profile.
How a Verifier achieves "compatibility" is out of scope of this document, but will be represented in this document as an implicit transformation of an Evidence `addition` ECT of the Evidence profile into another `addition` ECT, this time with the CoRIM profile.

The `addition` is a list of ECTs with Evidence to be appraised.

A Verifier may maintain multiple simultaneous sessions to different Attesters.
Each Attester has a different ACS. The Verifier ensures the Evidence inputs are associated with the correct ACS.
The `addition` is added to the ACS for a specific Attester.

~~~ cddl
ae = [
  addition: [ + ECT ]
]
~~~

| Type | `e` | `c` | `a` | `ns` | `cm` | `p` |
|---
| addition | T | T | T | F | T | F |
{: #tbl-ae-ect-optionality title="Mandatory fields for Evidence tuples"}

'T' means mandatory.

#### Internal Representation of Reference Values {#sec-ir-ref-val}

An internal representation of Reference Values uses the `rv` relation, which is a list of ECTs that contains possible states and a list of ECTs that contain actual states asserted with RVP authority.

The `rv` relation is a list of condition-addition pairings where each pairing is evaluated together.
If the `condition` containing reference ECTs overlaps Evidence ECTs then the Evidence ECTs are re-asserted, but with RVP authority as contained in the `addition`.

The reference ECTs define the matching conditions that are applied to Evidence ECTs.
If the matching condition is satisfied, then the re-asserted ECTs are added to the ACS.

~~~ cddl
rv = + {
  condition: ECT
  addition: ECT
}
~~~

| Type | `e` | `c` | `a` | `ns` | `cm` | `p` |
|---
| condition | T | T | F | F | F | F |
| addition | T | T | T | F | T | F |
{: #tbl-rv-ect-optionality title="Mandatory fields for Reference Values tuples"}

#### Internal Representation of Endorsed Values {#sec-ir-end-val}

An internal representation of Endorsed Values uses the `ev` and `evs` relations, which are lists of ECTs that describe matching conditions and the additions that are added if the conditions are satisfied.

The `ev` relation compares the `condition` ECTs to the ACS and if all of the ECTs are found in the ACS then the `addition` ECTs are added to the ACS.

The `evs` relation compares the `condition` ECTs to the ACS and if all of the ECTs are found in the ACS then each entry in the series list is evaluated.
The `selection` ECTs are compared with the ACS and if the selection criteria is satisfied, then the `addition` ECTs are added to the ACS and evaluation of the series ends.
If the `selection` criteria is not satisfied, then evaluation procedes to the next series list entry.

~~~ cddl
ev = [
  condition: [ + ECT ]
  addition: [ + ECT ]
]
evs = [
  condition: [ + ECT ]
  series: + {
    selection: [ + ECT ]
    addition: [ + ECT ]
  }
]
~~~

| Type | `e` | `c` | `a` | `ns` | `cm` | `p` |
|---
| condition | F | T | F | F | F | F |
| selection | F | T | F | F | F | F |
| addition | T | T | T | F | T | F |
{: #tbl-ev-ect-optionality title="Mandatory fields for Endorsed Values tuples"}

#### Internal Representation of Policy Statements {#sec-ir-policy}

The `policy` relation compares the `condition` ECTs to the ACS.
If all of the ECTs are found in the ACS then the `addition` ECTs are added to the ACS with the policy author's authority.

~~~ cddl
policy = [
    condition: [ + ECT ]
    addition: [ + ECT ]
]
~~~

| Type | `e` | `c` | `a` | `ns` | `cm` | `p` |
|---
| condition | F | F | F | F | F | F |
| addition | T | T | T | F | T | F |
{: #tbl-policy-ect-optionality title="Mandatory fields for policy tuples"}

#### Internal Representation of Attestation Results {#sec-ir-ar}

The `ar` relation compares the `acs-condition` to the ACS.
If the condition is satisfied, the `ars-additions` are copied from the ACS to the ARS.
If any of the `ars-additions` are not found in the ACS then these ACS entries are not copied to the ARS.

~~~ cddl
ar = [
    acs-condition: [ + ECT ]
    ars-addition: [ + ECT ]
]
~~~

| Type | `e` | `c` | `a` | `ns` | `cm` | `p` |
|---
| acs-condition | F | F | F | F | F | F |
| ars-addition | T | T | T | F | F | F |
{: #tbl-ar-ect-optionality title="Mandatory fields for Attestation Results tuples"}

### Internal Representation of ACS {#sec-ir-acs}

An ACS is a list of ECTs that describe an Attester's actual state.

~~~ cddl
ACS = [ + ECT ]
~~~

### Internal Representation of Attestation Results Set (ARS) {#sec-ir-ars}

An ARS is a list of ECTs that describe ACS entries that are selected for use as Attestation Results.

~~~ cddl
ARS = [ + ECT ]
~~~

## Input Validation and Transformationn (Phase 1) {#sec-phase1}

During the initialization phase, the CoRIM Appraisal Context is loaded with various conceptual message inputs such as CoMID tags {{sec-comid}}, CoSWID tags {{-coswid}}, CoBOM {{sec-cobom}} and cryptographic validation key material (including raw public keys, root certificates, intermediate CA certificate chains, and Concise Trust Anchor Stores (CoTS, {{-ta-store}})).
These objects will be utilized in the Evidence Appraisal phase that follows.
The primary goal of this phase is to ensure that all necessary information is available for subsequent processing.

After context initialization, additional inputs are held back until appraisal processing has completed.

### Input Validation {#sec-phase1-valid}

#### CoRIM Selection

All available CoRIMs are collected.

CoRIMs that are not within their validity period, or that cannot be associated with an authenticated and authorised source MUST be discarded.

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
For instance, in DICE, a proof of liveness is carried out on the final key in the certificate chain (a.k.a., the alias certificate).
If this is successful, a suitable certification path is looked up in the Appraisal Context, based on linking information obtained from the DeviceID certificate (see Section 9.2.1 of {{DICE.Layer}}).
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

Inputs, whether Endorsements, Reference Values, Evidence, or Policies, are transformed to an internal representation that is based on ECTs.

The following mapping conventions apply to all forms of input transformation:
The `e` field is populated with a Target Environment identifier.
The `c` field is populated with the measurements collected by an Attesting Environment.
The `a` field is populated with the identity of the entity that asserted (e.g., signed) the Evidence.
The `ns` field is populated with the namespace context if supplied. For example, the Attester's manufacturer may have a URI that identifies the manufacturing series, family or architecture.
The `cm` field is set based on the type of Conceptual Message inputted or to be outputed.

#### Appraisal Context Construction

All of the extracted and validated tags are loaded into an *appraisal context*.
The Appraisal Context contains an internal representation of the inputted Conceptual Messages.
The selected tags are mapped to the internal representation, making them suitable for appraisal processing.

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/96

#### Reference and Endorsed Values Tranformation

The Reference Values ECT fields are populated as described above {{sec-phase1-trans}} and {#sec-ir-ref-val}.

The Endorsement Values ECT fields are populated as described above {{sec-phase1-trans}} and {#sec-ir-end-val}.

#### Evidence Tranformation

Evidence is divided up into one or more `ev` relations where the `condition` ECT identifies the Attester from which Evidence was collected. If the Verifier maintains multiple Attester sessions, the Verifier session may be identified using an ECT.

Evidence information is mapped to an `addition` ECT that populates each of the ECT fields. If the Evidence doesn't have a value for the mandatory fields, the Verifier MUST NOT process the Evidence.

The Evidence ECT fields are populated as described above {{sec-phase1-trans}} and {{sec-ir-evidence}}.

Evidence transformation algorithms may be well-known;
may be defined by a CoRIM profile ({{sec-corim-profile-types}}); or may be supplied dynamically.
The handling of dynamic Evidence transformation algorithms is out of scope for this document.

## Evidence Augmentation (Phase 2) {#sec-phase2}

### Appraisal Claims Set Initialization {#sec-acs-initialization}

The ACS is initialized by copying the internal representation of Evidence claims to the ACS.
See {{sec-add-to-acs}}.

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
The Verifier has already verified the certificate chain (see {{sec-crypto-validate-evidence}}).

If multiple authorities approve the same Claim, for example if multiple key chains
are available, then the `authorized-by` field SHALL be set to include the trusted
authority keys used by each of those authorities.

When adding Endorsement Claims to the ACS that resulted
from CoRIM processing (see {{sec-add-to-acs}}) the Verifier SHALL set the
`authorized-by` field in that Evidence to the trusted authority key that is
at the head of the key chain that signed the CoRIM.

When searching the ACS for an entry which matches a Reference
Value containing an `authorized-by` field, the Verifier SHALL ignore ACS
entries if none of the keys present in the Reference Value `authorized-by` field
are also present in the ACS `authorized-by` field.

The Verifier SHOULD set the `authorized-by` field in ACS entries
to a format which contains only a key, for example the `tagged-cose-key-type`
format. Using a common format makes it easier to compare the field.

#### Appraisal Claims Set augmentation using CoMID triples

In the ACS augmentation phase, a CoRIM Appraisal Context and an Evidence Appraisal Policy are used by the Verifier to find CoMID triples which match the ACS.
Triples that specify an ACS matching condition will augment the ACS with Endorsements if the condition is met.

Each triple is processed independently of other triples.
However, the ACS state may change as a result of processing a triple.
If a triple condition does not match, then the Verifier continues to process other triples.

#### Ordering of triple processing

Triples interface with the ACS by either adding new ACS entries or by matching existing ACS entries before updating the ACS.
Most triples use an `environment-map` field to select the AES entries to match or modify.
This field may be contained in an explicit matching condition, such as `stateful-environment-record`.

The order of triples processing is important.
Processing a triple may result in ACS modifications that affect matching behavior of other triples.

The Verifier MUST ensure that a triple including a matching condition is processed after any other triple that modifies or adds an ACS entry with an `environment-map` that is in the matching condition.

This can be acheived by sorting the triples before processing, by repeating processing of some triples after ACS modifications or by other algorithms.

## Reference Values Corroboration and Augmentation (Phase 3) {#sec-phase3}

Reference Value Providers (RVP) publish Reference Values triples that are matched against ACS entries.
Reference Values may describe multiple acceptable states for Attesters; hence "matching" determines that Evidence (contained in the ACS) satisfies an appropriate subset of the available Reference Values.
If the appropriate subset matches, the authority of the RVP is added to the appropriate ACS entries.

The Verifier compares each `reference-triple-record` against ACS entries as described in {{sec-match-one-se}}, where the `reference-triple-record` takes the place of a `stateful-environment-record`.
If all fields of the `reference-triple-record` match the ACS, then the Verifier MUST add the RVP authority to each matching ACS field.

If any `reference-triple-record` in the Reference Value triple does not match the ACS then the entire triple is ignored.

## Endorsed Values Augmentation (Phase 4) {#sec-phase4}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/179

> [Ned] *The following sections should describe augmentation in the context of the `ev` and `evs` relations containing ECTs staged for ACS augmentation*

### Processing triples representing Conditional Endorsements

An Endorser may use CoMID tags to publish Conditional Endorsements, which are added to the ACS only if specified conditions are satisfied.
This section describes the process performed by the Verifier to determine which Conditional Endorsements from the candidate CoMIDs should be added to the ACS.

The verifier checks whether Conditional Endorsements are applicable by comparing ACS entries against expected values provided in `stateful-environment-record` object which are part of the triple.

#### Processing Conditional Endorsement Triple

For each Conditional Endorsement Triple the Verifier compares each of the `stateful-environment-record` fields from the `cond` field in the triple against the ACS (see {{sec-match-one-se}}).

If every stateful environment matches a corresponding ACS entry, then the Verifier MUST add an Endorsement entry to the ACS (see {{sec-add-to-acs}}) for each `endorsed-triple-record` in the `endorsements` field.
Each Endorsement from the `endorsed-triple-record` includes the authority which signed the Conditional Endorsement Triple.

#### Processing Conditional Endorsement Series Triple

For each Conditional Endorsement Series Triple the Verifier iterates over the `conditional-series-record`s within the triple, stopping if it finds a match.

For each iteration, the Verifier creates a temporary `stateful-environment-record` by merging the `stateful-environment-record` in the triple with the `refv` field in the `conditional-series-record`. It compares this temporary record against the ACS (see {{sec-match-one-se}}).

If one of the temporary records matches then the Verifier MUST add the `endv` Endorsement entry to the ACS.
This Endorsement includes the authority which signed the Conditional Endorsement Series Triple.

#### Processing a stateful environment against the Appraisal Claims Set {#sec-match-one-se}

This section describes how a stateful environment is matched against an ACS entry.
If any part of the processing indicates that the stateful environment does not match then the remaining steps in this section are skipped for that stateful environment.

The Verifier initializes a temporary "candidate entries" variable with all entries in the ACS where the stateful enviromnment `environment-map` is a subset of the ACS `environment-map`.

A stateful environment `environment-map` is a subset of an ACS entry `environment-map` if each field (for example `class`, `instance` etc.) which is present in the stateful environment `environment-map` is also present in the ACS entry, and the CBOR encoded field values in the stateful environment and ACS entry are binary identical.
If a field is not present in the stateful environment `environment-map` then the presence of, and value of, the corresponding ACS entry field does not affect whether the `environment-map`s are subsets.

Before performing the binary comparison, a Verifier SHOULD convert `environment-map` fields into a form which meets CBOR Core Deterministic Encoding Requirements {{-cbor}}.

If the stateful environment contains an `authorized-by` field then the Verifier SHALL remove all candidate entries whose `authorized-by` field does not contain one of the keys listed in the stateful environment `authorized-by` field (see {{sec-authorized-by}} for more details).

If there are no candidate entries then the triple containing the stateful environment does not match.

The stateful environment entry is compared against each of the candidate entries.

For each of the candidate entries, the Verifier SHALL iterate over the codepoints which are present in the `measurement-values-map` field within the stateful environment `measurement-map`.
Each of the codepoints present in the stateful environment is compared against the candidate entry.

If any codepoint present in the stateful environment `measurement-values-map` does not match the same codepoint within the candidate entry `measurement-values-map` then the stateful environment does not match.

If all checks above have been performed successfully then the stateful environment matches.
If none of the candidate entries match the stateful environment entry then the stateful environment does not match.

## Verifier Augmentation (Phase 5) {#sec-phase5}

## Policy Augmentation (Phase 6) {#sec-phase6}

## Attestation Results Production and Transformationn (Phase 7) {#sec-phase7}

## Adding to the Appraisal Claims Set {#sec-add-to-acs}

### Appraisal Claims Set Requirements {#sec-acs-reqs}

At the end of the Evidence collection process Evidence has been converted into an internal represenetation suitable for appraisal.
See {{sec-ir-cm}}.

Verifiers are not required to use this as their internal representation.
For the purposes of this document, appraisal is described in terms of the above cited internal representation.

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/232

The ACS contains the actual state of Attester's Target Environments (TEs).
The `state-triples` field contains Evidence (from Attesters) and Endorsements
(e.g. from `endorsed-triple-record`).

CoMID Reference Values will be matched against the ACS, as per
the appraisal policy of the Verifier.
This document describes an example evidence structure which can be easily
matched against these Reference Values.

Each entry within `state-triples` uses the syntax of `endorsed-triple-record`.
When an `endorsed-triple-record` appears within `state-triples` it
indicates that the authority named by `measurement-map`/`authorized-by`
asserts that the actual state of one or more Claims within the
Target Environment, as identified by `environment-map`, have the
measurement values in `measurement-map`/`mval`.

ECT authority is represented by cryptographic keys. Authority
is asserted by digitally signing a Claim using the key. Hence, Claims are
added to the ACS under the authority of a cryptographic key.

Each Claim is encoded as an ECT. The `environment-map` and a
key within `measurement-values-map` encode the name of the Claim.
The value matching that key within `measurement-values-map` is the actual
state of the Claim.

This specification does not assign special meanings to any Claim name,
it only specifies rules for determining when two Claim names are the same.

If two Claims have the same `environment-map` encoding then this does not
trigger special encoding in the Verifier. The Verifier follows instructions
in the CoRIM file which tell it how claims are related.

If Evidence or Endorsements from different sources has the same `environment-map`
and `authorized-by` then the `measurement-values-map`s are merged.

The ACS must maintain the authority information for each ECT. There can be
multiple entries in `state-triples` which have the same `environment-map`
and a different authority (see {{sec-authorized-by}}).

If the merged `measurement-values-map` contains duplicate codepoints and the
measurement values are equivalent, then duplicate claims SHOULD be omitted.
Equivalence typically means values MUST be binary identical.

If the merged `measurement-values-map` contains duplicate codepoints and the
measurement values are not equivalent then the verifier SHALL report
an error and stop validation processing.

### ACS Augmentation {#sec-acs-aug}

The ordering of ECTs in the ACS is not significant.
Logically, new ECT entries are appended to the existing ACS.
But implementations may optimize ECT order to achieve better performance.
Additions to the ACS MUST be atomic.

## ECT Comparison {#sec-ect-compare}

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71

This specification defines the comparison algorithm for the codepoints described in sub-sections below.
A CoRIM profile may define additional negative codepoints and their matching algorithms.
Specifications that extend CoMID MUST also define comparison algorithms for their added codepoints, and augment comparison algorithms if existing codepoints' value CDDL expands.
If a codepoint's comparison algorithm is not stated or is referred to as "default", then the Verifier MUST compare the binary equality of the CBOR encodings of the values.

### Environment Comparison {#sec-compare-env}

### Claims Comparison  {#sec-compare-claims}

#### Comparison of measurement-values-map {#sec-match-one-codepoint}

This section describes the algorithm used to compare the `measurement-values-map` codepoints of an ECT with another ECT.
The comparison algorithm performed depends on the value of the codepoint being compared.

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/203

If the `measurement-values-map` value has an associated CBOR tag, the comparison algorithm should comprehend the structure identified by the CBOR tag.

If the Verifier does not recognize a CBOR tag value then the value MUST NOT match.

Note: CBOR tags are useful for discriminating values amongst alternates, but the comparison of tagged values is still determined by the codepoint they appear under. It is recommended but not required to compare values with a specific CBOR tag the same way across codepoints. For this reason, it is recommended to specify a default comparison algorithm with the CBOR tag's registration.

Profile writers SHOULD use CBOR tags for widely applicable comparison methods to ease Verifier implementation compliance across profiles.

The following subsections define non-default comparison algorithms for some `measurement-values-map` key codepoints.

##### Comparison for svn entries

The value stored under `measurement-values-map` key 1 is an SVN, which must
have type UINT.

If the Reference value for `measurement-values-map` key 1 is an untagged UINT or
a UINT tagged with #6.552 then an equality comparison is performed. If the value
of the SVN in ACS is not equal to the value in the Reference
Value then the Reference Value does not match.

If the Reference value for `measurement-values-map` key 1 is a UINT tagged with
#6.553 then a minimum comparison is performed. If the value of the SVN in
ACS less than the value in the Reference Value then the
Reference Value does not match.

##### Comparison for digests entries {#sec-cmp-digests}

The value stored under `measurement-values-map` key 2,
or a value tagged with
#6.TBD is a digest entry.
It contains one or more digests, each measuring the
same object. A Reference Value may contain multiple digests, each with a
different algorithm acceptable to the Reference Value provider. If the
digest in Evidence contains a single value with an algorithm and value
matching one of the algorithms and values in the Reference Value then it
matches.

To prevent downgrade attacks, if there are multiple algorithms which are in
both the Evidence and Reference Value then the digests calculated using all
shared algorithms must match.

If the CBOR encoding of the `digests` entry in the Reference Value or the
ACS value with the same key is incorrect (for example if fields
are missing or the wrong type) then the Reference Value does not match.

The Verifier MUST iterate over the Reference Value `digests` array, locating
hash algorithm identifiers that are present in the Reference Value and
in the ACS entry.

If the hash algorithm identifier which is present in the Reference Value
differs from the hash algorithm identifier in the ACS entry then the Reference Value does not match.

If a hash algorithm identifier is present in both the Reference Value and
the ACS, but the value of the hash is not binary identical
between the Reference Value and the ACS entry then the
Reference Value does not match.

##### Comparison for raw-value entries

> [Andy] *I think this comparison method only works if the entry is at key 4 (because
there needs to be a mask at key 5). Should we have a Reference Value of this
which stores `[expect-raw-value raw-value-mask]` in an array?*

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/71

##### Comparison for cryptokeys entries {#sec-cryptokeys-matching}

The value stored under `measurement-values-map` key 12 is an array of `$crypto-key-type-choice` entries. `$crypto-key-type-choice` entries are CBOR tagged values.
The array contains one or more entries in sequence.

The CBOR tag of the first entry of the Reference Value `cryptokeys` array is compared with
the CBOR tag of the first entry of the ACS `cryptokeys` value.
If the CBOR tags match, then the bytes following the CBOR tag from the Reference Value entry
are compared with the bytes following the CBOR tag from the ACS entry.
If the byte strings match, and there is another array entry,
then the next entry from the Reference Values array is likewise
compared with the next entry of the ACS array.
If all entries of the Reference Values array match a corresponding entry in the ACS array, then the `cryptokeys` Reference Value matches.
Otherwise, `cryptokeys` does not match.

##### Comparison for Integrity Registers {#sec-cmp-integrity-registers}

For each Integrity Register entry in the Reference Value, the Verifier will use the associated identifier (i.e., `integrity-register-id-type-choice`) to look up the matching Integrity Register entry in Evidence.
If no entry is found, the Reference Value does not match.
Instead, if an entry is found, the digest comparison proceeds as defined in {{sec-cmp-digests}} after equivalence has been found according to {{sec-comid-integrity-registers}}.
Note that it is not required for all the entries in Evidence to be used during matching: the Reference Value could consist of a subset of the device's register space. In TPM parlance, a TPM "quote" may report all PCRs in Evidence, while a Reference Value could describe a subset of PCRs.

### Authority Comparison  {#sec-compare-auth}

The `a` field comparison tests for trust path termination.
If the authority of the first ECT is a trust anchor for the authority of the second ECT, the second ECT is valid.
If the authority values are identical, then the second ECT is valid.

### Name Space Comparison  {#sec-compare-ns}

The `ns` field comparison tests equality where the text values are identical.

### Conceptual Message Type Comparison  {#sec-compare-cm}

The `cm` field comparison tests equality of one or more bits.

### Profile-directed Comparison {#sec-compare-profile}

A profile may specify handling for new CBOR tagged Reference Values.
The profile must specify how to compare the CBOR tagged Reference Value against the ACS.

Note that the verifier may compare Reference Values in any order, so the comparison should not be stateful.

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

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/11

# IANA Considerations {#sec-iana-cons}

## New COSE Header Parameters

[^issue] https://github.com/ietf-rats-wg/draft-ietf-rats-corim/issues/12

## New CBOR Tags {#sec-iana-cbor-tags}

IANA is requested to allocate the following tags in the "CBOR Tags" registry {{!IANA.cbor-tags}}, preferably with the specific CBOR tag value requested:

|     Tag | Data Item           | Semantics                                                            | Reference |
|     --- | ---------           | ---------                                                            | --------- |
|     500 | `tag`               | A tagged-concise-rim-type-choice, see {{sec-corim-tags}}             | {{&SELF}} |
|     501 | `map`               | A tagged-corim-map, see {{sec-corim-map}}                            | {{&SELF}} |
|     502 | `tag`               | A tagged-signed-corim, see {{sec-corim-signed}}                      | {{&SELF}} |
| 503-504 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |
|     505 | `bytes`             | A tagged-concise-swid-tag, see {{sec-corim-tags}}                    | {{&SELF}} |
|     506 | `bytes`             | A tagged-concise-mid-tag, see {{sec-corim-tags}}                     | {{&SELF}} |
|     507 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |
|     508 | `bytes`             | A tagged-concise-bom-tag, see {{sec-corim-tags}}                     | {{&SELF}} |
| 509-549 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |
|     550 | `bytes .size 33`    | tagged-ueid-type, see {{sec-common-ueid}}                            | {{&SELF}} |
|     552 | `uint`              | tagged-svn, see {{sec-comid-svn}}                                    | {{&SELF}} |
|     553 | `uint`              | tagged-min-svn, see {{sec-comid-svn}}                                | {{&SELF}} |
|     554 | `text`              | tagged-pkix-base64-key-type, see {{sec-crypto-keys}}                 | {{&SELF}} |
|     555 | `text`              | tagged-pkix-base64-cert-type, see {{sec-crypto-keys}}                | {{&SELF}} |
|     556 | `text`              | tagged-pkix-base64-cert-path-type, see {{sec-crypto-keys}}           | {{&SELF}} |
|     557 | `[int/text, bytes]` | tagged-thumbprint-type, see {{sec-common-hash-entry}}                | {{&SELF}} |
|     558 | `COSE_Key/ COSE_KeySet`   | tagged-cose-key-type, see {{sec-crypto-keys}}                  | {{&SELF}} |
|     559 | `digest`            | tagged-cert-thumbprint-type, see {{sec-crypto-keys}}                 | {{&SELF}} |
|     560 | `bytes`             | tagged-bytes, see {{sec-common-tagged-bytes}}                        | {{&SELF}} |
|     561 | `digest`            | tagged-cert-path-thumbprint-type, see  {{sec-crypto-keys}}           | {{&SELF}} |
| 562-599 | `any`               | Earmarked for CoRIM                                                  | {{&SELF}} |

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

# Base CoRIM CDDL {#sec-corim-cddl}

~~~ cddl
{::include cddl/corim-autogen.cddl}
~~~
# Contributors
The authors would like to thank the following members for their valuable contributions to the specification.

Andrew Draper

Email: andrew.draper@intel.com

Dionna Glaze

Email: dionnaglaze@google.com

# Acknowledgments
{:unnumbered}

{{{Carl Wallace}}} for review and comments on this document.


[^revise]: (This content needs to be revised. Consider removing for now and
    replacing with an issue.)

[^todo]: (Needed content missing. Consider adding an issue into the tracker)

[^issue]: Content missing. Tracked at:

[^tracked-at]: Tracked at:
