# Zoho Flow On-Prem Extension SDK

The Zoho Flow On-Prem Extension SDK helps developers build Java integrations that run through the Zoho Flow On-Prem Agent. An On-Prem Extension can expose actions, polling triggers, real-time triggers, dynamic configuration fields, and integrations with services or devices reachable from the Agent.

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

## License

This repository is available under the [MIT License](LICENSE.txt).

Third-party components retain their respective terms. The bundled JSON-java dependency is documented with the [Java SDK third-party notices](sdk/java/third_party_licenses/README.md).

## Support and security

- [Support policy](SUPPORT.md)
- [Security reporting](SECURITY.md)
- [Release history](CHANGELOG.md)
