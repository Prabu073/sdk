# Zoho Flow Custom Class SDK

The Zoho Flow Custom Class SDK helps developers build Java integrations that run through the Zoho Flow On-Prem Agent. A custom class can expose actions, polling triggers, real-time triggers, dynamic configuration fields, and integrations with services or devices reachable from the Agent.

This repository contains the customer-facing SDK artifacts and their documentation. It does not contain the Zoho Flow Agent implementation.

## Current support

| Language | Status | SDK |
|---|---|---|
| Java | Available | [Open the Java SDK](sdk/java/README.md) |
| Python | Not currently available | — |
| Node.js | Not currently available | — |

Only directories for currently available language implementations are included. Additional languages can be added later without changing existing Java paths.

## Start here

1. Read the [Java SDK overview](sdk/java/README.md).
2. Follow the [static-first getting-started guide](sdk/java/docs/getting-started.md).
3. Use the [Java API reference](sdk/java/docs/java-api.md) when adding advanced capabilities.
4. Check [SDK and Agent compatibility](sdk/java/docs/compatibility.md) before packaging a connector.

## Try without writing code

Browse the [sample catalog](samples/README.md) for ready-to-upload archives and source projects. Each sample documents its available language implementations, requirements, expected input/output, and build instructions.

## Repository map

```text
sdk/
  README.md             SDK and language index
  java/
    README.md           Java SDK overview and documentation index
    VERSION             Current SDK version
    compatibility.json  Machine-readable compatibility metadata
    SHA256SUMS          Artifact integrity hashes
    lib/                Java compile-time dependencies
    docs/               Detailed Java documentation
samples/
  README.md             Human-readable sample catalog
  catalog.json          Machine-readable sample catalog
```

## Licensing status

The SDK-specific license is pending approval. The existing Zoho Flow On-Prem Agent agreement is retained only as [legal reference material](legal/README.md) and is not presented as the finalized SDK license. Do not publish this repository as a generally available SDK until the SDK license has been approved.

The bundled JSON-java dependency is documented in [third-party notices](THIRD_PARTY_LICENSES/README.md).

## Support and security

- [Support policy](SUPPORT.md)
- [Security reporting](SECURITY.md)
- [Release history](CHANGELOG.md)
