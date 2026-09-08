# Zoho Flow Java On-Prem Extension SDK

Version: **1.0.0**  
Java compilation target: **Java 11**

This SDK provides the customer-facing Java types used to build on-prem extensions for the Zoho Flow On-Prem Agent.

## Downloaded libraries

The [`lib`](lib/) directory contains:

- [`ZohoFlow-extension-sdk.jar`](lib/ZohoFlow-extension-sdk.jar) — on-prem-extension API, annotations, dynamic fields, triggers, long-lived connections, and transformations.
- [`json.jar`](lib/json.jar) — JSON-java dependency used by the SDK APIs.

Add both JARs to the compile and local-test classpath. The Agent provides these libraries at runtime, so do **not** include either JAR in a connector upload ZIP.

## First connector

Start with the [static-first guide](docs/getting-started.md). It introduces one action with static input and output before adding authentication, dynamic fields, polling, or real-time behavior.

## Concepts

| Concept | Documentation |
|---|---|
| Connector, input, and output classes | [Getting started](docs/getting-started.md) |
| Static fields and annotations | [Getting started: static fields](docs/getting-started.md#2-static-fields-and-annotations) |
| Authentication | [Getting started: authentication](docs/getting-started.md#3-add-authentication-when-required) |
| Dynamic fields and dropdowns | [Getting started: dynamic fields](docs/getting-started.md#5-dynamic-field-mental-model) |
| Polling triggers | [Getting started: polling](docs/getting-started.md#15-polling-trigger) |
| Real-time triggers | [Getting started: real-time](docs/getting-started.md#17-real-time-triggers-and-long-lived-connections) |
| Long-lived connections | [Java API reference](docs/java-api.md#17-long-lived-connection-lifecycle) |
| POJO and JSON transformation | [Transformation reference](docs/transformation.md) |
| Complete API contract | [Java API reference](docs/java-api.md) |
| Packaging | [Packaging and dependencies](docs/packaging.md) |
| SDK and Agent versions | [Compatibility](docs/compatibility.md) |

## Compile classpath

macOS/Linux:

```bash
javac -cp "sdk/java/lib/ZohoFlow-extension-sdk.jar:sdk/java/lib/json.jar" YourConnector.java
```

Windows:

```bat
javac -cp "sdk\java\lib\ZohoFlow-extension-sdk.jar;sdk\java\lib\json.jar" YourConnector.java
```

For complete projects and ready-to-upload archives, browse the [sample catalog](../../samples/README.md).

## Important runtime boundaries

- Customer connectors extend the documented SDK types; they do not initialize Agent lifecycle state.
- Dynamic metadata is loaded during configuration, while execution reads or creates dynamic values.
- Polling triggers read Agent-injected `PollingInfo` and return a `List` of events.
- The Agent owns managed connection and real-time subscription lifecycles.
- Connector upload ZIPs contain customer code and customer runtime dependencies, not SDK JARs.

## Integrity and version information

- [`VERSION`](VERSION)
- [`compatibility.json`](compatibility.json)
- [`SHA256SUMS`](SHA256SUMS)

Version `1.0.0` is currently assigned by this distribution. The supplied JAR manifest does not yet embed an implementation version; the repository's `VERSION`, compatibility metadata, and checksum identify this distribution.

## Licensing

The SDK repository is available under the [MIT License](../../LICENSE.txt). The bundled JSON-java dependency retains its own terms, documented in the Java SDK [third-party notices](third_party_licenses/README.md).
