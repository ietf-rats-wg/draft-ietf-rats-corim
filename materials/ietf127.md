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
* Reference Verifier pseudocode cheat-sheet
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
* Float-specific rules:
  * comparison is numeric, independent of CBOR encoding width
  * `+0.0` and `-0.0` are equal
  * `NaN` MUST NOT appear in a matcher; a transformation MUST NOT produce one
  * `+Infinity` and `-Infinity` MUST NOT be range bounds; `null` is the only way to say "unbounded"

---

## Keys Relation & Authority

* TODO

---

## Multiple signatures

* TODO

---

## Reference Verifier Pseudocode Cheat Sheet

* New section "Pseudocode Notation": comments, types, variables, functions, expressions, conditionals, iteration, primitive operations
* Types are the CDDL types of the data mode

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

