# Packaging and Dependencies

This document distinguishes the libraries used to compile a connector from the libraries placed in its Zoho Flow upload ZIP.

## Compile and local-test classpath

Compile customer projects with:

- `ZohoFlow-extension-sdk.jar`
- `json.jar`
- Any third-party libraries directly used by the connector

## Upload ZIP

The Agent supplies the SDK and JSON-java at runtime. Do not package `ZohoFlow-extension-sdk.jar` or `json.jar` in the connector upload.

Use this layout for a Java Extension:

```text
<extension-name>.zip
└── <extension-name>/
    ├── <connector>.jar
    └── <customer-runtime-dependency>.jar
```

The ZIP has one top-level directory matching the Extension name used for packaging. Place all customer runtime dependency JARs at the same level as the connector JAR — the Agent does not read nested directories. Do not include source files, test classes, credentials, build caches, or Agent implementation JARs.

## Dependency rules

- Keep third-party integrations behind customer-owned client classes.
- Pin dependency versions and review their licenses.
- Avoid bundling classes under `com.zoho.agent.flow.*` or `org.json.*`.
- Compile for Java 11 unless the compatibility metadata documents another target.
- Test the final ZIP, rather than only the connector JAR.

Ready-made ZIPs and automated packaging commands will be introduced with the sample applications.
