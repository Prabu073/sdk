# Repository Instructions

This repository distributes the customer-facing Zoho Flow On-Prem Extension SDK. It does not contain the Zoho Flow Agent implementation.

- Java is the only currently available SDK language.
- The base SDK version is 1.0.0 and the compile target is Java 11.
- Treat `sdk/java/docs/java-api.md` as the canonical customer API reference.
- Follow `sdk/java/docs/getting-started.md` for connector patterns.
- Do not generate or document unsupported Python or Node.js implementations.
- Compile with `sdk/java/lib/ZohoFlow-extension-sdk.jar` and `sdk/java/lib/json.jar`.
- Never place those two SDK-provided JARs in a connector upload ZIP.
- Do not expose or depend directly on Agent lifecycle implementation classes.
- Keep documentation links relative and verify them when files move.
- Preserve the root `LICENSE.txt` and the dependency notices under `sdk/java/third_party_licenses/` when reorganizing or distributing artifacts.
- Discover available samples and language implementations through `samples/catalog.json`; keep individual sample details inside `samples/`.
