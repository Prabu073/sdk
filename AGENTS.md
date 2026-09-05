# Repository Instructions

This repository distributes the customer-facing Zoho Flow Custom Class SDK. It does not contain the Zoho Flow Agent implementation.

- Java is the only currently available SDK language.
- The base SDK version is 1.0.0 and the compile target is Java 11.
- Treat `sdk/java/docs/java-api.md` as the canonical customer API reference.
- Follow `sdk/java/docs/getting-started.md` for connector patterns.
- Do not generate or document unsupported Python or Node.js implementations.
- Compile with `sdk/java/lib/ZFAgentCustom.jar` and `sdk/java/lib/json.jar`.
- Never place those two SDK-provided JARs in a connector upload ZIP.
- Do not expose or depend directly on Agent lifecycle implementation classes.
- Keep documentation links relative and verify them when files move.
- Do not present `legal/reference/ZohoFlow_Agent_License.txt` as the finalized SDK license.
