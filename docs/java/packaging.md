# Packaging and Dependencies

This document distinguishes the libraries used to compile a connector from the libraries placed in its Zoho Flow upload ZIP.

## Compile and local-test classpath

Declare the SDK as a `provided` dependency — Maven resolves the classpath and excludes the SDK from the connector JAR automatically:

```xml
<dependency>
    <groupId>com.zoho.flow</groupId>
    <artifactId>zohoflow-onprem-extension-sdk</artifactId>
    <version>1.0.0</version>
    <scope>provided</scope>
</dependency>
```

`json.jar` (`org.json:json:20231013`) is a transitive dependency declared in the SDK POM — Maven includes it on the compile classpath without any extra declaration. Add any other third-party libraries your connector uses as regular `compile`-scope dependencies.

## Upload ZIP

The Agent supplies the SDK and JSON-java at runtime. Do not package `zohoflow-onprem-extension-sdk.jar` or `json.jar` in the connector upload.

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

The sample connectors in this repository use the Maven Assembly Plugin to produce upload-ready ZIPs automatically on `mvn package`.
