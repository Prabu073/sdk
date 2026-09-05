# Compatibility

## SDK version

The base Java SDK version in this repository is `1.0.0`.

This version is assigned by the repository distribution metadata. The current candidate JAR manifest identifies Java 11 but does not contain an SDK implementation version. Embedding the SDK version in the release build remains a release-readiness item.

## Java version

The supplied SDK JAR was built for Java 11. Customer connector projects should compile with Java release 11 unless a later compatibility entry explicitly changes the requirement.

## Zoho Flow Agent version

The minimum supported and maximum-tested Agent versions have not yet been approved for public documentation. They remain `null` with status `pending-verification` in [`compatibility.json`](../compatibility.json).

This repository must not claim compatibility with every Agent version until the release has been tested against the supported production matrix.

See the [candidate artifact review](artifact-review.md) for the remaining API-boundary checks.

## Versioning policy

The SDK uses semantic versioning:

- Major: incompatible public API or connector-contract changes.
- Minor: backward-compatible APIs and capabilities.
- Patch: backward-compatible fixes and documentation corrections.

Agent and SDK versions are independent. A release should publish a tested compatibility range rather than relying on matching version numbers.
