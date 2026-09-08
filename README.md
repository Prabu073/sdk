# Zoho Flow On-Prem Extension SDK

An On-Prem Extension connects your on-prem services, devices, databases, and business systems to Zoho Flow as workflow-native actions and triggers — without exposing them to the internet or building a separate API.

Build an Extension once, deploy it to a Zoho Flow On-Prem Agent running inside your network, and any Flow can call it. The same Extension can serve multiple Flows, handle authentication, expose static or runtime-resolved fields, respond to scheduled polling, or deliver real-time events the moment they occur on your network.

This repository contains the SDK artifacts and documentation needed to build On-Prem Extensions. It does not contain the Zoho Flow Agent implementation.

## Current support

| Language | Status | SDK |
|---|---|---|
| Java | Available | [Open the Java SDK](sdk/java/README.md) |
| Python | Not currently available | — |
| Node.js | Not currently available | — |

Only directories for currently available language implementations are included. Additional languages can be added later without changing existing paths.

## Start here

1. Choose a language from the [SDK index](sdk/README.md) and open its overview.
2. Follow the getting-started guide for that language.
3. Use the language API reference when adding advanced capabilities.
4. Check compatibility metadata before packaging an Extension.
5. To upload and use your Extension in Zoho Flow, see [Use an On-Prem Extension in Zoho Flow](using-in-ZohoFlow.md).

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

Third-party components retain their respective terms. See the third-party notices in each language SDK directory.

## Support and security

- [Support policy](SUPPORT.md)
- [Security reporting](SECURITY.md)
- [Release history](CHANGELOG.md)
