---
footer: IETF 127, San Francisco, RATS WG
slidenumbers: true
autoscale: true
theme: Next
---

# CoRIM 12

## [`draft-ietf-rats-corim-12`](https://www.ietf.org/archive/id/draft-ietf-rats-corim-12.html)

### IETF 127, San Francisco, RATS WG

---

## Scope

* Adding "basic types" and their matchers to the `measurement-values-map`
* `keys` relation and authority
* Multiple signatures via COSE_Sign
* Reference Verifier improvements
* CoMID additions, CDDL fixes and editorial/IANA clean-up
* Terminology updates

---

## Basic Types and Matchers

Added entries for "basic" types with configurable matching to `measurement-values-map` 

| Index | Name | Type |
|---|---|---|
| 16 | `bool` | bare `bool`, exact match only |
| 17 | `integer` | `int` plus range and set matching |
| 18 | `text` | `text` plus set matching |
| 19 | `bytes` | `bytes` plus set matching |
| 20 | `float` | `float` plus range and set matching |

---

## Basic Types and Matchers (cont'd)

* Bare value => exact match
* Matching semantics are carried by CBOR tags:
  * tag 565: inclusive range (`null` means unbounded)
  * tag 566: set of two or more alternatives

The codepoint (and environment/mkey) name the measurement and the CBOR tag says how to compare

---

## Basic Types and Matchers (cont'd)

* Range and set forms are only meaningful in a condition (C-ECT)
* An ACS-ECT entry at codepoints 16-20 MUST be the bare form (no tag)
* These entries carry no meaning of their own beyond primitive type and matching criterion
  * A profile that uses these entries MUST define what each one measures (e.g., its unit), and any further constraints
* Comparison rules are specified per codepoint / type


---

## Basic Types and Matchers (cont'd)

* Ranges are inclusive; `null` means unbounded
* Malformed ranges are rejected, e.g.: `min` greater than `max`, both bounds `null`, etc.
* float and int can't be compared
* Float-specific rules:
  * comparison is numeric, independent of CBOR encoding width
  * `+0.0` and `-0.0` are equal
  * `NaN` MUST NOT appear in a matcher; a transformation MUST NOT produce one
  * `+Infinity` and `-Infinity` MUST NOT be range bounds; `null` is the only way to say "unbounded"

---

## Keys Relation & Authority

* TODO

---

## Multiple Signatures

* A CoRIM may now be a `COSE_Sign` (tag 98) as well as a `COSE_Sign1` (tag 18)
* Use cases:
  * one authority signing with several algorithms (e.g., adding PQ signatures alongside T)
  * several authorities, each signing the same unsigned CoRIM
* Top-level protected/unprotected header pair plus `signature: [+ signature-structure]`; one entry per signer
  * A one-signature `COSE_Sign` is allowed (`[+ ...]`), so a CoRIM can start with one signer and be extended
* Header parameter sections restructured: one for `COSE_Sign1`, one for `COSE_Sign`
* Verification: if a CoRIM has multiple signers, at least the signature of the CoRIM creator MUST be verified before further processing; appraisal policy may require more

---

## Reference Verifier Improvements

* Pseudocode Cheat Sheet
  * New section "Pseudocode Notation": comments, types, variables, functions, expressions, conditionals, iteration, primitive operations
  * Types are the CDDL types of the data model

* Appraisal and matching text improvements
  * apply _"attribute path containment"_ and _"range satisfaction"_ defs to environment and element-claims matching

---

## CoMID misc Additions, IANA Updates, CDDL fixes

* TODO

---

## Terminology Updates

* containment, range satisfaction, collision resistant names (replace uniqueness)

---

## What's Next

* `int-range` deprecation
* multiple signing authorities and matching
* group profile-related requirements into one place
* TODO

