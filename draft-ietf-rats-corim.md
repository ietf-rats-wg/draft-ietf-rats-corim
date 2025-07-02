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
  RFC7519: jwt
  RFC7942:
  RFC9562:
  I-D.fdb-rats-psa-endorsements: psa-endorsements
  I-D.tschofenig-rats-psa-token: psa-token
  I-D.ietf-rats-endorsements: rats-endorsements
  I-D.ietf-rats-msg-wrap: cmw
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
  DICE.cert:
    title: DICE Certificate Profiles
    author:
      org: Trusted Computing Group
    seriesinfo: Version 1.0, Revision 0.01
    date: July 2020
    target: https://trustedcomputinggroup.org/wp-content/uploads/DICE-Certificate-Profiles-r01_pub.pdf
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
Ideally, only the supply chain actor who is the most knowledgable entity regarding a particular component will supply Reference Values or Endorsements for that component.

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

Attestation Results Set (ARS):
: A structure that holds results of appraisal and Environment-Claim Tuples that are used to construct an Attestation Results message that is conveyed to a Relying Party.

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
: A domain is a topological description of a Composite Attester in terms of its constituent Environments and their compositional relationships.

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
Internal representations of Conceptual Messages, ACS, and Attestation Results Set (ARS) SHOULD satisfy the following requirements for Verifier reconciliation and appraisal processing:

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

## CoRIM Map {#sec-corim-map}

The CDDL specification for the `corim-map` is as follows and this rule and its
constraints MUST be followed when creating or validating a CoRIM map.

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

A `corim-map` is unsigned, and its tagged form is an entrypoint for parsing a CoRIM, so it is named `tagged-unsigned-corim-map`.
~~~ cddl
{::include cddl/tagged-unsigned-corim-map.cddl}
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

* `thumbprint` (index 1): expected digest of the resource referenced by `href`.
  See sec-common-hash-entry}}.

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

* `kid` (index 4): A byte string which is a key identity pertaining to the CoRIM Issuer.

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

## Signer authority of securely conveyed unsigned CoRIM {#sec-conveyed-signer}

An unsigned (#6.501-tagged) CoRIM may be a payload in an enveloping signed document.
The CoRIM signer authority is taken from the authenticated credential of the entity that originates the CoRIM.
A CoRIM role entry that contains the `manifest-signer` role MUST be added to `corim-entity-map`.

It is out of scope of this document to specify a method of delegating the signer role in the case that an unsigned CoRIM is conveyed through multiple secured links with different notions of authenticity without end-to-end integrity protection.

### CoRIM collections

Several CoRIMs may share the same signer (e.g., as collection payload in a different signed message) and use locally-resolvable references to each other, for example using a RATS Conceptual Message Wrapper (CMW) {{-cmw}}.
The Collection CMW type is similar to a profile in its way of restricting the shape of the CMW collection.
The Collection CMW type for a CoRIM collection SHALL be `tag:{{&SELF}}:corim`.

A COSE_Sign1-signed CoRIM Collection CMW has a similar requirement to a signed CoRIM.
The signing operation MUST include the `corim-meta` in the COSE_Sign1 `protected-header` parameter.
The `corim-meta` statement ensures that each CoRIM in the collection has an identified signer.
The COSE protected header can include a Collection CMW type name by using the `cmwc_t` content type parameter for the `&(content-type: 3)` COSE header.

If using other signing envelope formats, the CoRIM signing authority MUST be specified. For example, this can be accomplished by adding the `manifest-signer` role to every CoRIM, or by using a protected header analogous to `corim-meta`.

~~~ cddl
{::include cddl/cmw-corim-collection.cddl}
~~~

The Collection CMW MAY use any label for its CoRIMs.
If there is a hierarchical structure to the CoRIM Collection CMW, the base entry point SHOULD be labeled `0` in CBOR or `"base"` in JSON.
It is RECOMMENDED to label a CoRIM with its tag-id in string format, where `uuid-type` string format is specified by {{RFC9562}}.
CoRIMs distributed in a CoRIM Collection CMW MAY declare their interdependence `dependent-rims` with local resource indicators.
It is RECOMMENDED that a CoRIM with a `uuid-type` tag-id be referenced with URI `urn:uuid:`_tag-id-uuid-string_.
It is RECOMMENDED that a CoRIM with a `tstr` tag-id be referenced with `tag:{{&SELF}}:local,`_tag-id-tstr_.
It is RECOMMENDED for a `corim-locator-map` containing local URIs to afterwards list a nonzero number of reachable URLs as remote references.

The following example demonstrates these recommendations for bundling CoRIMs with a common signer but have different profiles.

~~~cbor-diag
{::include cddl/examples/cmw-corim-collection.diag}
~~~

# Concise Module Identifier (CoMID) {#sec-comid}

A CoMID tag contains information about hardware, firmware, or module composition.

Each CoMID has a unique ID that is used to unambiguously identify CoMID instances when cross referencing CoMID tags, for example in typed link relations, or in a CoTL tag.

A CoMID defines several types of Claims, using "triples" semantics.

At a high level, a triple is a statement that links a subject to an object via a predicate.
CoMID triples typically encode assertions made by the CoRIM author about Attesting or Target Environments and their security features, for example measurements, cryptographic key material, etc.

This specification defines two classes of triples, the Mandatory to Implement (MTI) and the Optional to Implement (OTI).
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

* `conditional-endorsement-series-triples` (index 8): Triples describing a series of Endorsement that are applicable based on the acceptance of a series of stateful environment records.
  Described in {{sec-comid-triple-cond-series}}.

* `conditional-endorsement-triples` (index 10): Triples describing a series of conditional Endorsements based on the acceptance of a stateful environment.
  Described in {{sec-comid-triple-cond-endors}}.

##### Environments {#sec-environments}

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
  The vendor determines the encoding of `raw-value`.
  When used for comparison, the `tagged-masked-raw-value` variant includes a mask indicating which bits in the value to compare.
  Described in {{sec-comid-raw-value-types}}

* `raw-value-mask-DEPRECATED` (index 5): Is an obsolete method of indicating which bits in a raw value to compare. New CoMID files should use the `tagged-masked-raw-value` on index 4 instead of using index 5.

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

* `tagged-key-thumbprint-type`: a `digest` of a raw public key.
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


##### Int Range {#sec-comid-int-range}

An int range describes an integer value that can be compared with linear order in the target environment.
An int range is represented with either major type 0 or major type 1 ints.

~~~ cddl
{::include cddl/int-range-type-choice.cddl}
~~~

The signed integer range representation is an inclusive range unless either `min` or `max` are infinite as represented by `null`, in which case, each infinity is necessarily exclusive.

#### Reference Values Triple {#sec-comid-triple-refval}

A Reference Values Triple provides reference measurements or reference claims pertaining to a Target Environment.
For a Reference Value triple, the subject identifies a Target Environment, the object contains reference measurements associated to one or more measured elements of the Environment, and the predicate asserts that these are expected (i.e., reference) measurements for the Target Environment.

The Reference Values Triple has the following structure:

~~~ cddl
{::include cddl/reference-triple-record.cddl}
~~~

The `reference-triple-record` has the following parameters:

* `ref-env`: Identifies the Target Environment
* `ref-claims`: One or more measurement claims for the Target Environment

To process `reference-triple-record` both the `ref-env` and `ref-claims` criteria are compared with Evidence entries.
First `ref-env` is used as a search criterion to locate the Evidence environment that matches the reference environment.
Subsequently, the `ref-claims` from this triple are used to match against the Evidence measurements for the matched environment.
If the search criteria are satisfied, the matching entry is re-asserted, except with the Reference Value Provider's authority.
By re-asserting Evidence using the RVP's authority, the Verifier can avoid mixing Reference Values (reference state) with Evidence (actual state).
See {{-rats-endorsements}}.
Re-asserted Evidence using RVP authority is said to be "corroborated".

#### Endorsed Values Triple {#sec-comid-triple-endval}

An Endorsed Values triple provides additional Endorsements - i.e., claims reflecting the actual state - for an existing Target Environment.
For Endorsed Values Claims, the subject is a Target Environment, the object contains Endorsement Claims for the Environment, and the predicate defines semantics for how the object relates to the subject.

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

A Conditional Endorsement Triple declares one or more conditions that, once matched, results in augmenting the Attester's actual state with the Endorsement Claims.
The conditions are expressed via `stateful-environment-records`, which match Target Environments from Evidence in certain reference state.

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

The Conditional Endorsement Series Triple is used to assert endorsed values based on an initial condition match (specified in `condition:`) followed by a series condition match (specified in `selection:` inside `conditional-series-record`).
Every `conditional-series-record` selection MUST select the same mkeys where every selected mkey's corresponding set of code points represented as mval.key MUST be the same across each `conditional-series-record`.
For example, if a selection matches on 3 `measurement-map` statements; `mkey` is the same for all 3 statements and `mval` contains only A= variable-X, B= variable-Y, and C= variable-Z (exactly the set of code points A, B, and C) respectively for every `conditional-series-record` in the series.

These restrictions ensure that evaluation order does not change the meaning of the triple during the appraisal process.
Series entries are ordered such that the most precise match is evaluated first and least precise match is evaluated last.
The first series condition that matches terminates series matching and the endorsement values are added to the Attester's actual state.


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

The `series` array contains an ordered list of `conditional-series-record` entries.
Evaluation order begins at list position 0.

For each `series` entry, if the `selection` criteria matches an entry found in the `condition` result, the `series` `addition` is combined with the `environment-map` from the `condition` result to form a new Endorsement entry.
The new entry is added to the existing set of Endorsements.

The first `series` entry that successfully matches the `selection` criteria terminates `series` processing.

#### Device Identity Triple {#sec-comid-triple-identity}

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

* `environment`: An `environment-map` condition used to identify the target Evidence or Reference Value.
  See {{sec-environments}}.

* `key-list`: A list of `$crypto-key-type-choice` keys that identifies which keys are to be verified.
  See {{sec-crypto-keys}}.

* `mkey`: An optional `$measured-element-type-choice` condition used to identify the element within the target Evidence or Reference Value.
  See {{sec-comid-mkey}}.

* `authorized-by`: An optional list of `$crypto-key-type-choice` keys that identifies the authorities that asserted the `key-list` in the target Evidence or Reference Values.

#### Attest Key Triple {#sec-comid-triple-attest-key}

Attest Key triples (see `attest-key-triples` in {{sec-comid-triples}}) endorse that the keys were securely provisioned to the named Attesting Environment.
An Attesting Environment (as identified by `environment` and `mkey`) may contain one or more cryptographic keys.
The existence of these keys is asserted in Evidence, Reference Values, or Endorsements.

The attestation keys may have been used to sign Evidence or may be held in reserve for later use.

Attest Key triples instruct a Verifier to perform key validation checks, such as revocation, certification path construction and validation, or proof of possession.
The Verifier SHOULD verify keys contained in Attest Key triples.

Additional details about how a key was provisioned or is protected may be asserted using Endorsements such as `endorsed-triples`.

Depending on key formatting, as defined by `$crypto-key-type-choice`, the Verifier may take different steps to locate and verify the key.
If a key has usage restrictions that limits its use to Evidence signing (e.g., see Section 5.1.5.3 in {{DICE.cert}}).
The Verifier SHOULD enforce key use restrictions.

Each successful verification of a key in `key-list` SHALL produce Endorsement Claims that are added to the Attester's Claim set.
Claims are asserted with the joint authority of the Endorser (CoRIM signer) and the Verifier.
The Verifier MAY report key verification results as part of an error reporting function.

~~~ cddl
{::include cddl/attest-key-triple-record.cddl}
~~~

See {{sec-comid-triple-identity}} for additional details.

#### Triples for domain definitions {#sec-comid-domains}

A domain is a topological description of a Composite Attester in terms of its constituent Environments and their compositional relationships.

The following CDDL describes domain type.

~~~ cddl
{::include cddl/domain-type.cddl}
~~~

Domain structure is defined with the following types of triples.

##### Domain Membership Triple {#sec-comid-triple-domain-membership}

A Domain Membership Triple (DMT) links a domain identifier to its member Environments.
The triple's subject is the domain identifier while the triple’s object lists all the member Environments within the domain.
Representing members of a DMT as domains enables the recursive construction of an entity's topology, such as a Composite Device (see {{Section 3.3 of -rats-arch}}), where multiple lower-level domains can be aggregated into a higher-level domain.

~~~ cddl
{::include cddl/domain-membership-triple-record.cddl}
~~~

##### Domain Dependency Triple {#sec-comid-triple-domain-dependency}

A Domain Dependency triple defines trust dependencies between measurement sources.
The subject identifies a domain ({{sec-comid-triple-domain-membership}}) that has a predicate relationship to the object containing one or more dependent domains.
Dependency means the subject domain’s trustworthiness properties rely on the object domain(s) trustworthiness having been established before the trustworthiness properties of the subject domain exist.

~~~ cddl
{::include cddl/domain-dependency-triple-record.cddl}
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

The CDDL specification for the `concise-tl-tag` map is as follows and this
rule and its constraints MUST be followed when creating or validating a CoTL
tag:

~~~ cddl
{::include cddl/concise-tl-tag.cddl}
~~~

The following describes each member of the `concise-tl-tag` map.

* `tag-identity` (index 0): A `tag-identity-map` containing unique
  identification information for the CoTL.
  Described in {{sec-comid-tag-id}}.

* `tags-list` (index 1): A list of one or more `tag-identity-maps` identifying
  the CoMID and CoSWID tags that constitute the "bill of material", i.e.,
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
Defined in {{Section 4.1.2. of -uuid}}.

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

Verifier implementations MUST provide the specified information model of the ACS at the end of phase 4 as described in this specification.
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

# Example Verifier Algorithm {#sec-verifier-abstraction}

This document assumes that Verifier implementations may differ.
To facilitate the description of normative Verifier behavior, this document describes the internal representation for an example Verifier and demonstrates how the data is used in the appraisal phases outlined in {{sec-appraisal-procedure}}.


The terms
Claim,
Environment-Claim Tuple (ECT),
Authority,
Appraisal Claims Set (ACS),
Appraisal Policy, and
Attestation Results Set (ARS)
are used with the meaning defined in {{sec-glossary}}.

### Internal Representation of Conceptual Messages {#sec-ir-cm}

Conceptual Messages are Verifier input and output values such as Evidence, Reference Values, Endorsed Values, Appraisal Policy, and Attestation Results.

The internal representation of Conceptual Messages, as well as the ACS ({{sec-ir-acs}}) and ARS ({{sec-ir-ars}}), are constructed from a common building block structure called Environment-Claims Tuple (ECT).

### Internal structure of ECT {#sec-ir-ect}

Environment-Claims Tuples (ECT) have six attributes:

{:ect-enum: style="format %d."}

{: ect-enum}
* Environment : Identifies the Target Environment. Environments are identified using instance, class, or group identifiers. Environments may be composed of elements, each having an element identifier.

* Elements : Identifies the set of elements contained within a Target Environment and their trustworthiness Claims.

* Authority : Identifies the entity that issued the tuple. A certain type of key material by which the authority (and corresponding provenance) of the tuple can be determined, such as the public key of an asymmetric key pair that is associated with an authority's PKIX certificate.

* Members : Identifies the set of Environments that act as members when a Domain Membership is expressed in an ECT

* Conceptual Message Type : Identifies the type of Conceptual Message that originated the tuple.

* Profile : The profile that defines this tuple. If no profile is used, this attribute is omitted.

The following CDDL describes the ECT structure in more detail.

~~~ cddl
{::include cddl/intrep-ect.cddl}
~~~

The Conceptual Message type determines which attributes are mandatory.

### Internal Representation of Cryptographic Keys {#sec-ir-ext}

The internal representation for keys use the extension slot within `measurement-values-map` with the `intrep-keys` claim that consists of a list of `typed-crypto-key`.
`typed-crypto-key` consists of a `key` and an optional `key-type`.
There are two types of keys `attest-key` and `identity-key`.

~~~ cddl
{::include cddl/intrep-key.cddl}
~~~

### Internal Representation of Evidence {#sec-ir-evidence}

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
|           | `members`       | n/a         |
{: #tbl-ae-ect-optionality title="Evidence tuple requirements"}

### Internal Representation of Reference Values {#sec-ir-ref-val}

An internal representation of Reference Values uses the `rv` relation, which is a list of ECTs that contains possible states and a list of ECTs that contain actual states asserted with RVP authority.

~~~ cddl
{::include cddl/intrep-rv.cddl}
~~~

The `rv` relation is a list of condition-addition pairings where each pairing is evaluated together.
If the `condition` containing reference ECTs matches Evidence ECTs then the Evidence ECTs are re-asserted, but with RVP authority as contained in the `addition` and `cmtype` set to `reference-values`.

The reference ECTs define the matching conditions that are applied to Evidence ECTs.
If the matching condition is satisfied, then the re-asserted ECTs are added to the ACS.
Refer to {{sec-phase3}} for how the `rv` entries are processed.

{{tbl-rv-ect-optionality}} contains the requirements for the ECT fields of the Reference Values tuple:

| ECT type  | ECT Field       | Requirement |
|---
| condition | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Optional    |
|           | `cmtype`        | n/a         |
|           | `profile`       | n/a         |
|           | `members`       | n/a         |
| addition  | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
|           | `members`       | n/a         |
{: #tbl-rv-ect-optionality title="Reference Values tuple requirements"}

### Internal Representation of Endorsed Values {#sec-ir-end-val}

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
|           | `members`       | n/a         |
| selection | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Optional    |
|           | `cmtype`        | n/a         |
|           | `profile`       | n/a         |
|           | `members`       | n/a         |
| addition  | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
|           | `members`       | n/a         |
{: #tbl-ev-ect-optionality title="Endorsed Values and Endorsed Values Series tuples requirements"}

### Internal Representation of Domain Membership {#sec-ir-dm}

An internal representation of Domain Membership is expressed in a single ECT, where the domain identifier is set in the `environment` field of the ECT, and the domain members are expressed in the `members` field.
The `cmtype` is set to domain-member.

~~~ cddl
{::include cddl/intrep-domain-mem.cddl}
~~~

{{tbl-dm-ect-optionality}} contains the requirements for the ECT fields of the Domain Membership tuple:

| ECT type  | ECT Field       | Requirement |
|---
| domain    | `environment`   | Mandatory   |
|           | `element-list`  | Optional    |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
|           | `members`       | Mandatory   |
{: #tbl-dm-ect-optionality title="Domain Membership tuple requirements"}

### Internal Representation of Policy Statements {#sec-ir-policy}

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
|           | `members`       | n/a         |
| addition  | `environment`   | Mandatory   |
|           | `element-list`  | Mandatory   |
|           | `authority`     | Mandatory   |
|           | `cmtype`        | Mandatory   |
|           | `profile`       | Optional    |
|           | `members`       | n/a         |
{: #tbl-policy-ect-optionality title="Policy tuple requirements"}

### Internal Representation of Attestation Results {#sec-ir-ar}

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
|               | `members`       | n/a         |
| ars-addition  | `environment`   | Mandatory   |
|               | `element-list`  | Mandatory   |
|               | `authority`     | Mandatory   |
|               | `cmtype`        | Mandatory   |
|               | `profile`       | Optional    |
|               | `members`       | Optional    |
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

During the initialization phase, the CoRIM Appraisal Context is loaded with various conceptual message inputs such as CoMID tags ({{sec-comid}}), CoSWID tags {{-coswid}}, CoTL tags, and cryptographic validation key material (including raw public keys, root certificates, intermediate CA certificate chains), and Concise Trust Anchor Stores (CoTS) {{-ta-store}}.
These objects will be utilized in the Evidence Appraisal phase that follows.
The primary goal of this phase is to ensure that all necessary information is available for subsequent processing.

After context initialization, additional inputs are held back until appraisal processing has completed.

### Input Validation {#sec-phase1-valid}

#### CoRIM Selection

All available CoRIMs are collected.

CoRIMs that are not within their validity period, or that cannot be associated with an authenticated and authorized source MUST be discarded.

Any CoRIM that has been secured by a cryptographic mechanism that fails validation MUST be discarded.
An example of such a mechanism is a digital signature.

Other selection criteria MAY be applied.
For example, if the Evidence format is known in advance, CoRIMs using a profile that is not understood by a Verifier can be readily discarded.

Later stages will further select the CoRIMs appropriate to the Evidence Appraisal stage.

#### Tags Extraction and Validation

The Verifier chooses tags from the selected CoRIMs - including CoMID, CoSWID, CoTL, and CoTS.

The Verifier MUST discard all tags which are not syntactically and semantically valid.
Cross-referenced triples MUST be successfully resolved. An example of a cross-referenced triple is a CoMID-CoSWID linking triple.

#### CoTL Extraction

This section is not applicable if the Verifier appraisal policy does not require CoTLs.

CoTLs which are not within their validity period MUST be discarded.

The Verifier processes all CoTLs that are valid at the point in time of Evidence Appraisal and activates all tags referenced therein.

The Verifier MAY decide to discard some of the available and valid CoTLs depending on any locally configured authorization policies.
Such policies model the trust relationships between the Verifier Owner and the relevant suppliers, and are out of the scope of the present document.
For example, a composite device ({{Section 3.3 of -rats-arch}}) is likely to be fully described by multiple CoRIMs, each signed by a different supplier.
In such a case, the Verifier Owner may instruct the Verifier to discard tags activated by supplier CoTLs that are not also activated by the trusted integrator.

After the Verifier has processed all CoTLs it MUST discard any tags which have not been activated by a CoTL.

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
If a trusted root certificate is found, X.509 certificate validation is performed.

As a second example, in PSA {{-psa-token}} the verification public key is looked up in the appraisal context using the `ueid` claim found in the PSA claims-set.
If found, COSE Sign1 verification is performed accordingly.

Regardless of the specific integrity protection method used, the Verifier MUST NOT process Evidence which is not successfully validated.

> If a CoRIM profile is supplied, it MUST describe:
>
> * How cryptographic verification key material is represented (e.g., using Attestation Keys triples, or CoTS tags)
> * How key material is associated with the Attesting Environment
> * How the Attesting Environment is identified in Evidence

### Input Transformation {#sec-phase1-trans}

Input Conceptual Messages, whether Evidence, Reference Values, Endorsements, or Policies, are transformed to an internal representation that is based on ECTs ({{sec-ir-cm}}).

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

#### Evidence Tranformation

Evidence is transformed from an external representation to an internal representation based on the `ae` relation ({{sec-ir-evidence}}).
The Evidence is mapped into one or more `addition` ECTs.
If the Evidence does not have a value for the mandatory `ae` fields, the Verifier MUST NOT process the Evidence.

Evidence transformation algorithms may be well-known, defined by a CoRIM profile ({{sec-corim-profile-types}}), or supplied dynamically.
The handling of dynamic Evidence transformation algorithms is out of scope for this document.

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

> > **copy**(e.`measurement-map`, `rv`.`condition`.`element-list`.`element-map`)

{: rtt-enum}
* The signer of the Endorsement conceptual message is copied to the `rv`.`addition`.`authority` field.

* If the Endorsement conceptual message has a profile, the profile identifier is copied to the `rv`.`addition`.`profile` field.

#### Endorsement Triples Transformations {#sec-end-trans}

##### Endorsed Values Triple Transformation {#sec-end-trans-evt}

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

##### Conditional Endorsement Triple Transformation {#sec-end-trans-cet}

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

* If the Conditional Endorsement conceptual message has a profile, the profile is copied to the `ev`.`addition`.`profile` field.

##### Conditional Endorsement Triple Transformation {#sec-end-trans-cest}

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
* The signer of the Conditional Endorsement Series conceptual message is copied to the `evs`.`series`.`addition`.`authority` field.

* If the Conditional Endorsement Series conceptual message has a profile, the profile is copied to the `evs`.`series`.`addition`.`profile` field.

##### Key Verification Triples Transformation {#sec-end-trans-kvt}

The following transformation steps are applied for both the `identity-triples` and `attest-key-triples` with noted exceptions:

{:kvt-enum: counter="ckvt" style="format Step %d."}

{: kvt-enum}
* An `ev` entry ({{sec-ir-end-val}}) is allocated.

* The `cmtype` of the `ev` entry's `addition` ECT is set to `endorsements`.

* Populate the `ev` `condition` ECT using either the `identity-triple-record` or `attest-key-triple-record` ({{sec-comid-triple-identity}}) as follows:

{:kvt2-enum: counter="kvt2" style="format %i."}

{: kvt2-enum}
* **copy**(`environment-map`, `ev`.`condition`.`environment`.`environment-map`).

* Foreach _key_ in `keylist`.`$crypto-key-type-choice`, **copy**(_key_, `ev`.`condition`.`element-list`.`element-map`.`element-claims`.`measurement-values-map`.`intrep-keys`.`key`).

* If `key-list` originated from `attest-key-triples`, **set**(`ev`.`condition`.`element-list`.`element-map`.`element-claims`.`measurement-values-map`.`intrep-keys`.`key-type` = `attest-key`).

* Else if `key-list` originated from `identity-triples`, **set**(`ev`.`condition`.`element-list`.`element-map`.`element-claims`.`measurement-values-map`.`intrep-keys`.`key-type` = `identity-key`).

* If populated, **copy**(`mkey`, `ev`.`condition`.`element-list`.`element-map`.`element-id`).

* If populated, **copy**(`authorized-by`, `ev`.`condition`.`authority`).

{: kvt-enum}
* The signer of the Identity or Attest Key Endorsement conceptual message is copied to the `ev`.`addition`.`authority` field.

* If the Endorsement conceptual message has a profile, the profile is copied to the `ev`.`addition`.`profile` field.

#### Domain Membership Triples Transformation {#sec-ir-dm-trans}

This section describes how the external representation of a Domain Membership Triple (DMT) ({{sec-comid-triple-domain-membership}}) is transformed into its CoRIM internal representation `dm` (see {{sec-ir-dm}}).

{:dmt-enum: counter="dmt1" style="format Step %d."}

{: dmt-enum}
* Allocate a `domain` ECT entry.

* Set the conceptual message type for the `domain` ECT to 6 (`domain-member`).

{:dmt4-enum: counter="dmt4" style="format %i"}

{: dmt4-enum}
* **copy**(`domain-member`, `domain`.`cmtype`)

{: dmt-enum}
* Set the authority for the domain ECT to the DMT signer ({{sec-corim-signer}}).

{:dmt5-enum: counter="dmt5" style="format %i"}

{: dmt5-enum}
* **copy**(DMT.`signer`, `domain`.`authority`)

{: dmt-enum}
* Use the DMT to populate the `dm` internal representation.

{:dmt2-enum: counter="dmt2" style="format %i"}

{: dmt2-enum}
* **copy**(DMT.`domain-id`, `domain`.`environment`)

{: dmt2-enum}
* For each `environment` `e` in DMT.`members`:

> > **copy**(DMT.`members`[e].`environment-map`, `domain`.`members`[e].`environment-map`)

{: dmt-enum}
* If the conceptual message containing the DMT has a profile, it is used to populate the profile for the `domain` ECT.

{:dmt3-enum: counter="dmt3" style="format %i"}

{: dmt3-enum}
* **copy**(DMT.`profile`, `domain`.`profile`)

## ACS Augmentation - Phases 2, 3, and 4 {#sec-acs-aug}

In the ACS augmentation phase, a CoRIM Appraisal Context and an Evidence Appraisal Policy are used by the Verifier to find CoMID triples which match the ACS.
Triples that specify an ACS matching condition will augment the ACS with Endorsements if the condition is met.

Each triple is processed independently of other triples.
However, the ACS state may change as a result of processing a triple.
If a triple condition does not match, then the Verifier continues to process other triples.

### ACS Requirements {#sec-acs-reqs}

At the end of the Evidence collection process, the Evidence has been converted into an internal representation suitable for appraisal.
See {{sec-ir-cm}}.

Verifiers are not required to use this as their internal representation.
For the purposes of this document, appraisal is described in terms of the above cited internal representation.

#### ACS Processing Requirements

The ACS contains the actual state of Attester's Target Environments (TEs).
The ACS contains Evidence ECTs (from Attesters) and Endorsement ECTs
(e.g. from `endorsed-triple-record`).

CoMID Reference Values will be matched against the ACS following the comparison rules in {{sec-match-condition-ect}}.
This document describes an example evidence structure which can be
matched against these Reference Values.

Each Endorsement ECT contains the environment and internal representation of `measurement-map`s as extracted from an `endorsed-triple-record`.
When an `endorsed-triple-record` is transformed to Endorsements ECTs it
indicates that the authority named by `measurement-map`.`authorized-by`
asserts that the actual state of one or more Claims within the
Target Environment, as identified by `environment-map`, have the
measurement values in `measurement-map`.`mval`.

ECT authority is represented by cryptographic keys. Authority
is asserted by digitally signing a Claim using the key. Hence, Claims are
added to the ACS under the authority of a cryptographic key.

Each Claim is encoded as an ECT. The `environment-map`, the `mkey` or `element-id`, and a
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

The ACS MUST maintain the authority information for each ECT. There can be
multiple entries in `state-triples` which have the same `environment-map`
and a different authority.
See {{sec-authority}}.

If the merged `measurement-values-map` contains duplicate codepoints and the
measurement values are equivalent, then duplicate claims SHOULD be omitted.
Equivalence typically means values MUST be binary identical.

If the merged `measurement-values-map` contains duplicate codepoints and the
measurement values are not equivalent, then the Verifier SHALL report
an error and stop validation processing.

##### Ordering of triple processing

Triples interface with the ACS by either adding new ACS entries or by matching existing ACS entries before updating the ACS.
Most triples use an `environment-map` field to select the ACS entries to match or modify.
This field may be contained in an explicit matching condition, such as `stateful-environment-record`.

The order of triples processing is important.
Processing a triple may result in ACS modifications that affect matching behavior of other triples.

The Verifier MUST ensure that a triple including a matching condition is processed after any other triple that modifies or adds an ACS entry with an `environment-map` that is in the matching condition.

This can be acheived by sorting the triples before processing, by repeating processing of some triples after ACS modifications or by other algorithms.

#### ACS Augmentation Requirements {#sec-acs-aug-req}

The ordering of ECTs in the ACS is not significant.
Logically, the ACS represents the conjunction of all claims, so adding an ECT entry to the existing ACS at the end is equivalent to inserting it anywhere else.
Implementations may optimize ECT order to achieve better performance.
Additions to the ACS MUST be atomic.

### Evidence Augmentation (Phase 2) {#sec-phase2}

#### Appraisal Claims Set Initialization {#sec-acs-initialization}

The ACS is initialized by copying the internal representation of Evidence claims to the ACS.
See {{sec-acs-aug}}.

#### The authority field in the ACS {#sec-authority}

The `authority` field in an ACS ECT indicates the entity whose authority backs the Claims.

The Verifier keeps track of authority so that it can satisfy appraisal policy that specifies authority.

When adding an Evidence entry to the ACS, the Verifier SHALL set the `authority` field using a `$crypto-keys-type-choice` representation of the entity that signed the Evidence.

If multiple authorities approve the same Claim, for example if multiple key chains are available, then the `authority` field SHALL be set to include the `$crypto-keys-type-choice` representation for each key chain.

When adding Endorsement or Reference Values Claims to the ACS that resulted from CoRIM processing,
the Verifier SHALL set the `authority` field using a `$crypto-keys-type-choice` representation of the entity that signed the CoRIM.

When searching the ACS for an entry which matches a triple condition containing an `authorized-by` field, the Verifier SHALL ignore ACS entries if none of the entries present in the condition `authorized-by` field are present in the ACS `authority` field.
The Verifier SHALL match ACS entries if all of the entries present in the condition `authorized-by` field are present in the ACS `authority` field.

#### ACS augmentation using CoMID triples

In the ACS augmentation phase, a CoRIM Appraisal Context and an Evidence Appraisal Policy are used by the Verifier to find CoMID triples which match the ACS.
Triples that specify an ACS matching condition will augment the ACS with Endorsements if the condition is met.

Each triple is processed independently of other triples.
However, the ACS state may change as a result of processing a triple.
If a triple condition does not match, then the Verifier continues to process other triples.

### Reference Values Corroboration and Augmentation (Phase 3) {#sec-phase3}

Reference Value Providers (RVP) publish Reference Values using the Reference Values Triple ({{sec-comid-triple-refval}}) which are transformed ({{sec-ref-trans}}) into an internal representation ({{sec-ir-ref-val}}).
Each Reference Value Triple describes a single possible Attester state.

Corroboration is the process of determining whether actual Attester state (as contained in the ACS) can be satisfied by Reference Values.

Reference Values are matched with ACS entries by iterating through the `rv` list.
For each `rv` entry, the `condition` ECT is compared with an ACS ECT, where the ACS ECT `cmtype` contains `evidence`.

If satisfied, for the `rv` entry, the following three steps are performed:

1. The `addition` ECT is moved to the ACS, with `cm-type` set to `reference-values`
2. The claims, i.e., the `element-list` from the ACS ECT with `cmtype` set to `evidence` is copied to the `element-list` of the `addition` ECT
3. The `authority` field of the `addition` ECT has been confirmed as being set correctly to the RVP authority

### Endorsed Values Augmentation (Phase 4) {#sec-phase4}
Endorsers publish Endorsements using endorsement triples (see {{sec-comid-triple-endval}}), {{sec-comid-triple-cond-endors}}, and {{sec-comid-triple-cond-series}}) which are transformed ({{sec-end-trans}}) into an internal representation ({{sec-ir-end-val}}).
Endorsements describe actual Attester state.
Endorsements are added to the ACS if the Endorsement condition is satisifed by the ACS.

#### Processing Endorsements {#sec-process-end}

Endorsements are matched with ACS entries by iterating through the `ev` list.
For each `ev` entry, the `condition` ECT is compared with an ACS ECT, where the ACS ECT `cmtype` contains either `evidence`, `reference-values`, or `endorsements`.
If the ECTs match ({{sec-match-condition-ect}}), the `ev` `addition` ECT is added to the ACS.

#### Processing Conditional Endorsements {#sec-process-cond-end}

Conditional Endorsement Triples are transformed into an internal representation based on `ev`.
Conditional endorsements have the same processing steps as shown in ({{sec-process-end}}).

#### Processing Conditional Endorsement Series {#sec-process-series}

Conditional Endorsement Series Triples are transformed into an internal representation based on `evs`.
Conditional series endorsements are matched with ACS entries first by iterating through the `evs` list,
where for each `evs` entry, the `condition` ECT is compared with an ACS ECT, where the ACS ECT `cmtype` contains either `evidence`, `reference-values`, or `endorsements`.
If the ECTs match ({{sec-match-condition-ect}}), the `evs` `series` array is iterated,
where for each `series` entry, if the `selection` ECT matches an ACS ECT,
the `addition` ECT is added to the ACS.
Series iteration terminates after the first matching series entry is processed or when no series entries match.

#### Processing Key Verification Endorsements {#sec-process-keys}

For each `ev` entry, the `condition` ECT is compared with an ACS ECT, where the ACS ECT `cmtype` contains either `evidence`, `reference-values`, or `endorsements`.
If the ECTs match ({{sec-match-condition-ect}}), for each _key_ in `ev`.`condition`.`element-claims`.`measurement-values-map`.`intrep-keys`:

* Verify the certificate signatures for the certification path.

* Verify certificate revocation status for the certification path.

* Verify key usage restrictions appropriate for the type of key.

* If key verification succeeds, **append**(_key_, `ev`.`addition`.`element-list`.`element-map`.`element-claims`.`measurement-values-map`.`intrep-keys`).

If key verification succeeds for any _key_:

* **copy**(`ev`.`condition`.`environment`, `ev`.`addition`.`environment`).

* **copy**(`ev`.`condition`.`element-list`.`element-map`.`element-id`, `ev`.`addition`.`element-list`.`element-map`.`element-id`).

* Set `ev`.`addition`.`cmtype` to `endorsements`.

* Add the Verifier authority `$crypto-key-type-choice` to the `ev`.`addition`.`authority` field.

* Add the `addition` ECT to the ACS.

Otherwise, do not add the `addition` ECT to the ACS.

#### Processing Domain Membership {#sec-process-dm}

Domain Membership Triples allow an Endorser (for example, an Integrator) to issue an authoritative statement about the composition of an Attester as a collection of Environments.
If the Verifier Appraisal policy requires Domain Membership, the Domain Membership Triple is used to match an Attester's reference composition with the actual composition represented by Evidence.

This section assumes that each Domain Membership Triples has been transformed into an internal representation following the steps described in {{sec-ir-dm-trans}}, resulting in the representation specified in {{sec-ir-dm}}.

Domain Membership ECTs (`cmtype`: `domain-member`) are matched with ACS entries (of `cmtype`: `evidence`) using the following algorithm:

* For every `domain` entry:
  * Each `i` within `members` array, check that there is an ACS entry with a matching `environment` and cm-type = `evidence`
  * If all `members` match an a ACS entry, add the `domain` ECT to ACS

* If there is a partial match between the `member` environments and the ACS ECT `environment`, three separate cases must be considered.

  ACS ECT contains `N` environments while Domain ECT `members` reports `M` Environments:

  1. `N` >= `M` and some entries of `M` match.
  This is a case of a Composite Attester, where other entries of `M`, may itself be domain identifiers for other `domains`.
  In such case, upon complete appraisal, they MUST appear in other `domain` ECTs.
  Otherwise, the Appraisal is failed.

  2. If `N` >= `M` and all entries of `M` match.
  If the Evidence reports extra environments, it may be upto Verifier policy to allow/dis-allow such Evidence.

  3. `N` < `M` and all `N` or some of `N` ACS ECT environments match some of the `M` members of the `domain` ECT.
  The Appraisal is terminated with Attestation Results set as Verification Failure.

If none of the `members` match, proceed to next `domain` ECT in the list.

If none of the `domain` entries match, the Appraisal is terminated with Attestation Results set as Verification Failure.

### Examples for optional phases 5, 6, and 7 {#sec-phases567}

Phases 5, 6, and 7 are optional depending on implementation design.
Verifier implementations that apply consistency, integrity, or validity checks could be represented as Claims that augment the ACS or could be handled by application specific interfaces.
Processing appraisal policies may result in augmentation or modification of the ACS, but techniques for tracking the application of policies during appraisal need not result in ACS augmentation.
Additionally, the creation of Attestation Results is out-of-scope for this document, nevertheless internal staging may facilitate processing of Attestation Results.

Phase 5: Verifier Augmentation

Verifiers may add value to accepted Claims, such as ensuring freshness, consistency, and integrity.
The results of the added value may be asserted as Claims with Verifier authority.
For example, if a Verifier is able to ensure collected Evidence is fresh, it might create a freshness Claim that is included with the Evidence Claims in the ACS.

Phase 6: Policy Augmentation

Appraisal policy inputs could result in Claims that augment the ACS.
For example, an Appraisal Policy for Evidence may specify that if all of a collection of subcomponents satisfy a particular quality metric, the top-level component also satisfies the quality metric.
The Verifier might generate an Endorsement ECT for the top-level component that asserts a quality metric.
Details about the applied policy may augment the ACS.
An internal representation of policy details, based on the policy ECT, as described in {{sec-ir-policy}}, contains the environments affected by the policy with policy identifiers as Claims.

Phase 7: Attestation Results Production and Transformation

Attestation Results rely on input from the ACS, but may not bear any similarity to its content.
For example, Attestation Results processing may map the ACS state to a generalized trustworthiness state such as {{-ar4si}}.
Generated Attestation Results Claims may be specific to a particular Relying Party.
Hence, the Verifier may need to maintain multiple Attestation Results contexts.
An internal representation of Attestation Results as separate contexts ({{sec-ir-ars}}) ensures Relying Party–specific processing does not modify the ACS, which is common to all Relying Parties.
Attestation Results contexts are the inputs to Attestation Results procedures that produce external representations.

## Comparing a condition ECT against the ACS {#sec-match-condition-ect}

The Verifier SHALL iterate over all ACS entries and SHALL attempt to match the condition ECT against each ACS entry. See {{sec-match-one-condition-ect}}.
The Verifier SHALL create a "matched entries" set, and SHALL populate it with all ACS entries which matched the condition ECT.

If the matched entries array is not empty, then the condition ECT matches the ACS.

If the matched entries array is empty, then the condition ECT does not match the ACS.

### Comparing a condition ECT against a single ACS entry {#sec-match-one-condition-ect}

If the condition ECT contains a profile and the profile defines an algorithm for a codepoint and `environment-map` then the Verifier MUST use the algorithm defined by the profile, or it MUST use a standard algorithm if the profile defines that.
If the condition ECT contains a profile, but the profile does not define an algorithm for a particular codepoint and `environment-map` then the verifier MUST use the standard algorithm described in this document to compare the data at that codepoint.

The Verifier SHALL perform all of the comparisons defined in {{sec-compare-environment}}, {{sec-compare-authority}}, and {{sec-compare-element-list}}.

Each of these comparisons compares one field in the condition ECT against the same field in the ACS entry.

If all of the fields match, then the condition ECT matches the ACS entry.

If any of the fields does not match, then the condition ECT does not match the ACS entry.

### Environment Comparison {#sec-compare-environment}

The Verifier SHALL compare each field which is present in the condition ECT `environment-map` against the corresponding field in the ACS entry `environment-map` using binary comparison.
Before performing the binary comparison, the Verifier SHOULD convert both `environment-map` fields into a form which meets CBOR Core Deterministic Encoding Requirements {{-cbor}}.

If all fields which are present in the condition ECT `environment-map` are present in the ACS entry and are binary identical, then the environments match.

If any field which is present in the condition ECT `environment-map` is not present in the ACS entry, then the environments do not match.

If any field which is present in the condition ECT `environment-map` is not binary identical to the corresponding ACS entry field, then the environments do not match.

If a field is not present in the condition ECT `environment-map` then the presence of, and value of, the corresponding ACS entry field SHALL NOT affect whether the environments match.

### Authority comparison {#sec-compare-authority}

The Verifier SHALL compare the condition ECT's `authority` value to the candidate entry's `authority` value.

If every entry in the condition ECT `authority` has a matching entry in the ACS entry `authority` field, then the authorities match.
The order of the fields in each `authority` field do not affect the result of the comparison.

If any entry in the condition ECT `authority` does not have a matching entry in the ACS entry `authority` field then the authorities do not match.

When comparing two `$crypto-key-type-choice` fields for equality, the Verifier SHALL treat them as equal if their deterministic CBOR encoding is binary equal.

### Element list comparison {#sec-compare-element-list}

The Verifier SHALL iterate over all the entries in the condition ECT `element-list` and compare each one against the corresponding entry in the ACS entry `element-list`.

If every entry in the condition ECT `element-list` has a matching entry in the ACS entry `element-list` field then the element lists match.

The order of the fields in each `element-list` field do not affect the result of the comparison.

If any entry in the condition ECT `element-list` does not have a matching entry in the ACS entry `element-list` field then the `element-list` do not match.

### Element map comparison {#sec-compare-element-map}

The Verifier SHALL compare each `element-map` within the condition ECT `element-list` against the ACS entry `element-list`.

First, the Verifier SHALL locate the entries in the ACS entry `element-list` which have a matching `element-id` as the condition ECT `element-map`.
Two `element-id` fields are the same if they are either both omitted, or both present with binary identical deterministic encodings.

Before performing the binary comparison, the Verifier SHOULD convert both fields into a form which meets CBOR Core Deterministic Encoding Requirements {{-cbor}}.

If any condition ECT entry `element-id` does not have a corresponding `element-id` in the ACS entry then the element map does not match.

If any condition ECT entry has multiple corresponding `element-id`s then the element map does not match.

Second, the Verifier SHALL compare the `element-claims` field within the condition ECT `element-list` and the corresponding field from the ACS entry.
See {{sec-compare-mvm}}.

### Measurement values map map Comparison {#sec-compare-mvm}

The Verifier SHALL iterate over the codepoints which are present in the condition ECT element's `measurement-values-map`.
Each of the codepoints present in the condition ECT `measurement-values-map` is compared against the same codepoint in the candidate entry `measurement-values-map`.

If any codepoint present in the condition ECT `measurement-values-map` does not have a corresponding codepoint within the candidate entry `measurement-values-map` then Verifier SHALL remove that candidate entry from the candidate entries array.

If any codepoint present in the condition ECT `measurement-values-map` does not match the same codepoint within the candidate entry `measurement-values-map` then Verifier SHALL remove that candidate entry from the candidate entries array.

#### Comparison of a single measurement-values-map codepoint {#sec-match-one-codepoint}

The Verifier SHALL compare each condition ECT `measurement-values-map` value against the corresponding ACS entry value using the appropriate algorithm.

Non-negative codepoints represent standard data representations.
The comparison algorithms for these are defined in this document (in the sections below) or in other specifications.
For some non-negative codepoints their behavior is modified by the CBOR tag at the start of the condition ECT `measurement-values-map` value.

Negative codepoints represent profile defined data representations.
The Verifier SHALL use the codepoint number, the profile associated with the condition ECT, and, if present, the tag value to select the comparison algorithm.

If the Verifier is unable to determine the comparison algorithm which applies to a codepoint then it SHALL behave as though the candidate entry does not match the condition ECT.

Profile writers SHOULD use CBOR tags for widely applicable comparison methods to ease Verifier implementation compliance across profiles.

The following subsections define the comparison algorithms for the `measurement-values-map` codepoints defined by this specification.

##### Comparison for version entries

The value stored under `measurement-values-map` codepoint 0 is an version label, which MUST have type `version-map`.
Two `version-map` values can only be compared for equality, as they are colloquial versions that cannot specify ordering.

##### Comparison for svn entries

The ACS entry value stored under `measurement-values-map` codepoint 1 is a security version number, which MUST have type `svn-type`.

If the entry `svn-type` is a `uint` or a `uint` tagged with #6.552, then comparison with the `uint` named as SVN is as follows.

*  If the condition ECT value for `measurement-values-map` codepoint 1 is an untagged `uint` or a `uint` tagged with #6.552 then an equality comparison is performed on the `uint` components.
The comparison MUST return true if the value of SVN is equal to the `uint` value in the condition ECT.

*  If the condition ECT value for `measurement-values-map` codepoint 1 is a `uint` tagged with #6.553 then a minimum comparison is performed.
The comparison MUST return true if the `uint` value in the condition ECT is less than or equal to the value of SVN.

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

If there are multiple algorithms in common between the condition ECT and candidate entry, then the bytes paired with common algorithms MUST be equal.
This is to prevent downgrade attacks.
The Verifier SHALL treat two algorithm identifiers as equal if they have the same deterministic binary encoding.
If both an integer and a string representation are defined for an algorithm then entities creating ECTs SHOULD use the integer representation.
If condition ECT and ACS entry use different names for the same algorithm, and the Verifier does not recognize that they are the same, then a downgrade attack is possible.

The comparison MUST return false if the CBOR encoding of the `digests` entry in the condition ECT or the ACS value with the same codepoint is incorrect. For example, if fields are missing or if they are the wrong type.

The comparison MUST return false if the condition ECT digests entry does not contain any digests.

The comparison MUST return false if either digests entry contains multiple values for the same hash algorithm.

The Verifier MUST iterate over the condition ECT `digests` array, locating the common hash algorithm identifiers which are present in both the condition ECT and in the candidate entry.
If the value associated with any common hash algorithm identifier in the condition ECT differs from the value for the same algorithm identifier in the candidate entry then the comparison MUST return false.

The comparison MUST return false if there are no hash algorithms from the condition ECT in common with the hash algorithms from the candidate entry ECT.

##### Comparison for raw-value entries

A `raw-value` entry contains binary data.

The value stored under `measurement-values-map` codepoint 4 in an ACS entry MUST be a `raw-value` entry, which MUST be tagged and have type `bytes`.

The value stored under the condition ECT `measurement-values-map` codepoint 4 may additionally be a `tagged-masked-raw-value` entry, which specifies an expected value and a mask.

If the condition ECT `measurement-value-map` codepoint 4 is of `tagged-bytes`, and there is no value stored under codepoint 5, then the Verifier treats it in the same way as a `tagged-masked-raw-value` with the `value` field holding the same contents and a `mask` of the same length as the value with all bits set.
The standard comparison function defined in this document removes the tag before performing the comparison.

For backwards compatibility, if the condition ECT `measurement-value-map` codepoint 4 is of type `tagged-bytes`, and there is a mask stored under codepoint 5, then the Verifier treats it in the same way as a `tagged-masked-raw-value` with the `value` field holding the same contents and a `mask` holding the contents of codepoint 5.

The comparison MUST return false if the lengths of the candidate entry value and the condition ECT value are different.

The comparison MUST return false if the lengths of the condition ECT mask and value are different.

The comparison MUST use the mask to determine which bits to compare.
If a bit in the mask is 0 then this indicates that the corresponding bit in the ACS Entry value may have either value.
If, for every bit position in the mask whose value is 1, the corresponding bits in both values are equal then the comparison MUST return true.

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

##### Comparison for int-range entries

The ACS entry value stored under `measurement-values-map` codepoint 15 is an int range value, which MUST have type `int-range-type-choice`.

Consider an `int` ACS entry value named ENTRY in a `measurement-values-map` codepoint (e.g., 15) that allows comparing `int` against a either another `int` or an `int-range` named CONDITION.

*  If CONDITION is an `int` then an equality comparison is performed with ENTRY.

*  If CONDITION is an `int-range` (CBOR tag 564), then a range inclusion comparison is performed.
The comparison MUST return true if and only if all the following conditions are true:
    + CONDITION.min is `null` or ENTRY is greater than or equal to CONDITION.min.
    + CONDITION.max is `null` or ENTRY is less than or equal to CONDITION.max.

Consider an `int-range` or `int-range` (CBOR tag 564) value named ENTRY in a `measurement-values-map` codepoint (e.g., 15) that allows comparing an `int-range` against either another `int-range` or an `int` named CONDITION.

*  If CONDITION is an `int`, then the comparison MUST return true if and only if ENTRY.min and ENTRY.max are both equal to CONDITION.

*  If CONDITION is an `int-range` (CBOR tag 564), then a range subsumption comparison is performed (i.e., the condition range includes all values of the entry range).
The comparison MUST return true if and only if all the following conditions are true:
    + CONDITION.min is `null` or ENTRY.min is an `int` that is greater than or equal to CONDITION.min
    + CONDITION.max is `null` or ENTRY.max is an `int` that is less than or equal to CONDITION.max.

### Profile-directed Comparison {#sec-compare-profile}

A profile MUST specify comparison algorithms for its additions to `$`-prefixed CoRIM CDDL codepoints when this specification does not prescribe binary comparison.
The profile MUST specify how to compare the CBOR tagged Reference Value against the ACS.

Note that the Verifier may compare Reference Values in any order, so the comparison SHOULD NOT be stateful.

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

The integrity of public and private key material and the secrecy of private key material must be ensured at all times.
This includes key material carried in attestation key triples and key material used to verify the authority of triples (such as public keys that identify trusted supply chain actors).
For more detailed information on protecting Trust Anchors, refer to {{Section 12.4 of -rats-arch}}.
Utilizing the public part of an asymmetric key pair that is used for Evidence generation to identify an Attesting Environment raises privacy considerations that must be carefully considered.

The Verifier should use cryptographically protected, mutually authenticated secure channels to all its trusted input sources (Endorsers, RVPs, Verifier Owners).
These links must reach as deep as possible - possibly terminating within the appraisal session context - to avoid man-in-the-middle attacks.
Minimizing the use of intermediaries is also vital: each intermediary becomes another party that might need to be trusted and therefore factored in the Attesters and Relying Parties' TCBs.
Refer to {{Section 12.2 of -rats-arch}} for information on Conceptual Messages protection.


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

| Index | Item Name           | Specification |
|---
| 0     | reference-triples                     | {{&SELF}}     |
| 1     | endorsed-triples                      | {{&SELF}}     |
| 2     | identity-triples                      | {{&SELF}}     |
| 3     | attest-key-triples                    | {{&SELF}}     |
| 4     | dependency-triples                    | {{&SELF}}     |
| 5     | membership-trples                     | {{&SELF}}     |
| 6     | coswid-triples                        | {{&SELF}}     |
| 7     | (reserved)                            | {{&SELF}}     |
| 8     | conditional-endorsment-series-triples | {{&SELF}}     |
| 9     | (reserved)                            | {{&SELF}}     |
| 10    | conditional-endorsement-triples       | {{&SELF}}     |
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
