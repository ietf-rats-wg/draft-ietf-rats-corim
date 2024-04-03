# CoRIM Validity Operational Model

The claims in a CoRIM document all have different interpretations and impact on security posture.
This document describes how component vendors and environment compositors may structure their issuance of CoRIMs to assign appropriate lifetimes to different sorts of claims.
The main position is that the validity of claims should be bound to the validity of their signatures.
Public key infrastructure (PKI) already provides mechanisms for certificate lifetimes and otherwise revocation of certificates.
The CoRIM specification does not seek to reinvent the notion of validity of the CoRIM itself.

## Fundamentals

The typical chain of trust for keys has three levels: a root certificate authority, an intermediate certificate authority, and a signing key.
Every cryptographic signing algorithm has a limit of how many messages a key may sign before weakening the private key's secrecy.
To avoid exhausting a signer's source of trust, the signer will generate new keys and sign those keys' certificates with a trusted key.
If keys are generated frequently enough, that certificate signing key will also need to periodically get refreshed.
To refresh the intermediate key, you may have yet another intermediate key recursively, or a root key to provide the intermediate certificate authority's certificate.

A key may have its certificate reissued if it is near expiration, without needing new key material.
To ensure continuity, that key may have an identifier separate from the certificate itself.
A signed message may then bind its content to the key by including the key's identifier in its protected headers, for example.

## Certificate lifetime and OCSP

Certificates are invalid if they have expired or have been revoked.
Certificate revocation through certificate revocation lists is a generally unscalable solution for a large amount of certificates.
The Online Certificate Status Protocol makes it quick to check the status of a certificate's validity, but also leaves no time to respond to an incident to update environments and ensure continuity of service.
Revocation should be considered an emergency lockout due to key compromise only.

If the contents of a message should not be considered trustworthy for a long period of time, its signing key's certificate should have a short expiry period.
If the contents of the message are still considered trustworthy after the expiration period, the issuer of the message may reissue a certificate for its signing key.

### Certificate lifetime example: TLS

As of 2023, a typical expiration duration (lifetime) for a TLS key certificate is 398 days.
Due to the prevalence of outages for expired certificates, it's advisable to set the lifetime closer to 90 days to ensure you have the necessary online infrastructure to maintain certificate freshness.
Some managed certificate authority services have a default lifetime of 7 days given the target enterprise users are expected to have tighter security requirements.

## Authenticity

Claims of authenticity are fundamentally different from claims of security.
If a firmware vendor produces a binary and signs its measurement, that measurement is bound to the vendor.
The claim of security version number for that firmware is also immutable, as it can only increase across versions with new binaries.

Claims of authenticity can be longer term claims to not require online infrastructure to re-certify periodically.
This model is similar to distributing package signatures with packages.
Authenticity claims are not required to be long-term, but in heterogeneous environments, maintaining freshness of a large multitude of packages frequently can be an undesirable operational model.

## Confidence

The knowledge that we have about security properties of measured artifacts can change over time.
For stronger attestation appraisal policies, operators and supply chain providers may provide notes about vulnerabilities of specific releases.
A claim that an artifact has no known vulnerabilities should have a short lifetime to ensure that knowledge stays relatively fresh.

The RIM issuer for such claims may then choose to operate a service to provide RIMs signed by keys with short term certificates.
Signatures do not need to be generated on-demand; a background job not connected to the external network may have access to signing key material to keep signatures fresh.

For irrevocable claims, the claims may come with a proof of inclusion in a trusted append-only log.

### Confidence Example: Security Version Number

The AMD SEV-SNP versioned chip endorsement key (VCEK) signs its attestation reports.
Key is versioned to the host firmware components by combining their version numbers with a unique device secret in a key derivation function.
The key's certificate is bound to the host firmware version numbers via an X.509 certificate extension.
When there as a vulnerability in a host firmware component, new components are released with new security version numbers, and partners are informed of the new release.
The old VCEK certificate is still authentically signed by AMD, and will not be revoked.
It's up to platform providers to update host components within a reasonable timeframe.
It's up to attestation verification policy whether to permit any connections in the interval between manufacturer security version number increase and the platform provider's ability to enforce that minimum version of firmware across its fleet.

The platform provider is incentivized to publish its own CoRIM family for fleetwide guarantees for minimum host firmware versions to give customers confidence to update attestation policy without fear of induced outages from attestation failure.

### Confidence Example: Software Component Analysis

Composite environments should undergo routine component analyses to match recent supply chain information with the environment's components.
The Grafeas project provides a model for matching supply chain notes of vulnerable dependencies with instances of analyses for the current state of a composite environment (e.g., a container).
An online CoRIM service may provide access to the latest certificates of recent analysis results for artifacts they offer composite CoRIMs for.
The service is a front end for read-only access to stored results generated offline.

## Service model

With short-term claims come long-term service maintenance responsibilities.
In order to keep certificates fresh, you need to have regular processes for provisioning new certificates.
In order for those certificates to make it to users, you need an online service users connect to.
For best key management purposes, it's best to make these processes separate such that certificate provisioning happens on devices without direct access to the external network.

Not every claim provider (e.g., product team) needs to run a service if they are authorized to submit claims to a more centralized repository of knowledge (e.g., organization).

### Frontend service: Query CoRIM

The Veraison project supports a RESTful API to ingest supply chain information to its in-memory body of knowledge.
The in-memory body of knowledge is "matched" against to determine which claims by whom apply to a stateful environment.
Consider turning the matching logic into a query-API for any verification engine to use for their body of knowledge.

#### Example interaction:

> Query: Which CoRIMs match PCR0=ABCD, PCR7=1234?
> Response: CoRIMs H,I, and J all describe that PCR set.
>  Upon further inspection, CoRIM H includes an endorsement that the PCR0 value is the latest from the manufacturer (lifetime 5 more days).
>  CoRIM I authorizes PCR0 as an authentic firmware for the manufacturer (lifetime 5 years)
>  CoRIM J authorizes the combination of PCR0 and PCR7 as a company Y value-added composition.

It's only CoRIM J that permits the PCR set as a slice, but the additions of endorsements from further down the supply chain add to the stateful environment that the verifier is building about the attesting environment.

### Backend service: CoRIM repository

Whereas the query-based frontend is useful for small queries meant to run during an online attestation flow, organizations that provide a large amount of artifacts to many users through intermediaries will want their repository of knowledge to follow their artifacts.
The organization that publishes information about their artifacts does so through a set of publish/subscribe topics that they work with intermediaries to subscribe to.
Some topics may be open for anyone to subscribe to, or some combination of allow/deny lists.
This content delivery model is called federation.
The pub/sub pathways provide batch delivery modes to propagate knowledge amongst participants in this federation of knowledge bases.

The expectation for such servers is to provide reference values and endorsements upon or prior to availability of a new release of a particular class of attesting environment.
News of releases ahead of availability allows users to audit changes or update attestation policies in response.

#### Example interaction:

An OS distributor creates a new release of their Product-X.Y family of releases, Product-X.Y-20240422 to mitigate a vulnerability, and its CoRIM comes with a security version number increase from 0 to 1.
The Product-X.Y topic is updated to the new release's CoRIM, but Product-X.Y-20230801 still has the old CoRIM.
The Product-X.Y-svn topic is updated to the new security version number.
The Product-X.Y-svn-0 topic is updated with the associated CVE+CVSSs.

Note: topics can be established with appropriate authorization policies to only propagate information to parties included in a vulnerability embargo.

A Cloud Provider subscribing to this family of products ingests the new image and latest security version number.
A background process updates internal knowledge representation.
The Cloud Provider's Attestation Verification Service stops issuing EATs with the "latest" and "svn-latest" claims for machines running the old release.
Projects using Product-X.Y get a security notice that their workloads are not attesting with svn-latest, but instead have a claim with associated vulnerabilities listed.

Note: the vulnerabilities list could be delivered through a different channel from the verifier service to a dashboard due to the sensitivity.

The project has an auto-upgrade workflow to begin a migration process to shed workloads to new instances it assembles from the latest release.
