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

* Keys transformation and processing specified for Attest Key and Device Identity triples
* Key verification is expressed as a pre-condition of `acs::APPEND`; the earlier `CHECK` operation is replaced by explicit pre- and post-conditions
* `authorized-by` reworded TODO(ned)

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

* Attribute path containment (matching)
* Range satisfactiona (ditto)
* Collision resistant names (replace uniqueness)

---

## Terminology Updates: Attribute Path Containment

> **Attribute Path**: A sequence of one or more attribute identifiers that denotes a value within a structured data object by successive selection from a root value.
> An Attribute Path is **defined** in a given value if every prefix of the path exists in that value; otherwise, it is **undefined**.

> **Attribute Path Containment**: A comparison relation between two structured data objects, the **condition** (C) and the **entry** (A), in which C is **contained in** A when:
>
> 1. for every Attribute Path defined in C, the same Attribute Path is defined in A; and
> 2. for each such path, the value in A **satisfies** the value in C.
>
> Attributes present in A but not in C are ignored.
> Unless otherwise specified, **satisfies** means that the two values are equal.

---

## Attribute Path Containment: Example

Entry (A), an ACS-ECT `environment`:

```
{
  class: {
    vendor: "ACME",
    model: "Roadrunner",
    layer: 2
  },
  instance: 560(h'01020304')
}
```

Attribute Paths defined in A: `class`, `class/vendor`, `class/model`, `class/layer`, `instance`

---

## Attribute Path Containment: Example (cont'd)

| Condition (C) | Paths defined in C | In A? | Contained? |
|---|---|---|---|
| `{ class: { vendor: "ACME" } }` | `class`, `class/vendor` | yes | yes (values match) |
| `{ class: { model: "Roadrunner" }, instance: 560(h'01020304') }` | `class/model`, `instance` | yes | yes (values match) |
| `{ class: { vendor: "ACME", model: "Coyote" } }` | `class/model` | defined | not contained (value differs) |
| `{ group: 560(h'AA') }` | `group` | undefined in A | not contained |

---

## Terminology Updates: Range Satisfaction

> **Range Satisfaction**: A value satisfaction relation in which an entry value is said to satisfy a condition value when the entry lies within the bounds expressed by the condition.
> For example, an `int` entry satisfies an `integer-range` condition when the entry is within the condition's inclusive bounds, and an `svn` entry satisfies a `tagged-min-svn` condition when the entry is greater than or equal to the condition's minimum.

---

## Terminology Updates: Collision-Resistant Name

> **Collision-Resistant Name**: As defined in Section 2 of RFC 7519:
> _"A name in a namespace that enables names to be allocated in a manner such that they are highly unlikely to collide with other names.
> Examples of collision-resistant namespaces include: Domain Names, Object Identifiers (OIDs) [...], and Universally Unique IDentifiers (UUIDs)."_
>
> CoRIM identifiers that function as global keys, such as Tag IDs and Environment identifiers, are Collision-Resistant Names.

---

## What's Next

* `int-range` deprecation
* multiple signing authorities and matching
* group profile-related requirements into one place
* TODO

