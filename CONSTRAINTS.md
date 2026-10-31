# CoRIM Specification Constraints

This document details development constraints placed upon the CoRIM specification.

## DICE Endorsement Architecture for Devices

[TCG's DICE Endorsement Architecture for Devices](https://trustedcomputinggroup.org/wp-content/uploads/TCG-Endorsement-Architecture-for-Devices-V1-R38_pub.pdf)
leverages CoRIM constructs such as CoMID tags and associated claims. The CoRIM specification is
not to break compatibility with section 5 of this document.

## Data Model and Reference Verifier

The data model sections (currently sections 4 through 7: CoRIM, CoMID, CoTL and Common Types) are not
to specify or reference the Reference Verifier (currently section 8). They describe what CoRIM data
means and the requirements it must meet. Verifier behavior, such as comparison, matching and
discarding tags, is specified in the Reference Verifier section, which may reference the data model
sections.
