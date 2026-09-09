# Zoho Flow Java On-Prem Extension SDK

Version: **1.0.0**  
Java compilation target: **Java 11**

This SDK provides the customer-facing Java types used to build on-prem extensions for the Zoho Flow On-Prem Agent.

## SDK dependency

### Maven

```xml
<repositories>
    <repository>
        <id>zohoflow-sdk</id>
        <url>https://maven.zohodl.com/flow</url>
    </repository>
</repositories>
<dependency>
    <groupId>com.zoho.flow</groupId>
    <artifactId>zohoflow-onprem-extension-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Gradle

```groovy
repositories {
    maven { url 'https://maven.zohodl.com/flow' }
}
dependencies {
    implementation 'com.zoho.flow:zohoflow-onprem-extension-sdk:1.0.0'
}
```

### Manual download

Download the SDK ZIP and add both JARs to your compile and local-test classpath:

[zohoflow-onprem-extension-sdk-1.0.0-java.zip](https://maven.zohodl.com/flow/com/zoho/flow/zohoflow-onprem-extension-sdk/1.0.0/zohoflow-onprem-extension-sdk-1.0.0-java.zip)

The ZIP contains `zohoflow-onprem-extension-sdk.jar` and `json.jar`. The Agent provides both at runtime — do **not** include either JAR in a connector upload ZIP.

## First connector

Start with the [static-first guide](getting-started.md). It introduces one action with static input and output before adding authentication, dynamic fields, polling, or real-time behavior.

## Concepts

| Concept | Documentation |
|---|---|
| Connector, input, and output classes | [Getting started](getting-started.md) |
| Static fields and annotations | [Getting started: static fields](getting-started.md#2-static-fields-and-annotations) |
| Authentication | [Getting started: authentication](getting-started.md#3-add-authentication-when-required) |
| Dynamic fields and dropdowns | [Getting started: dynamic fields](getting-started.md#5-dynamic-field-mental-model) |
| Polling triggers | [Getting started: polling](getting-started.md#15-polling-trigger) |
| Real-time triggers | [Getting started: real-time](getting-started.md#17-real-time-triggers-and-long-lived-connections) |
| Long-lived connections | [Java API reference](java-api.md#17-long-lived-connection-lifecycle) |
| POJO and JSON transformation | [Transformation reference](transformation.md) |
| Complete API contract | [Java API reference](java-api.md) |
| Packaging | [Packaging and dependencies](packaging.md) |
| Uploading and using an Extension in a Flow | [ZIP-to-Flow guide](../../README.md#deploy-to-zoho-flow) |

## Compile classpath

Declare the SDK as a `provided` dependency in your `pom.xml` — Maven resolves the classpath automatically and excludes the SDK from your connector JAR:

```xml
<dependency>
    <groupId>com.zoho.flow</groupId>
    <artifactId>zohoflow-onprem-extension-sdk</artifactId>
    <version>1.0.0</version>
    <scope>provided</scope>
</dependency>
```

For complete projects and ready-to-upload archives, browse the [sample catalog](../../samples/README.md).

## Important runtime boundaries

- Customer connectors extend the documented SDK types; they do not initialize Agent lifecycle state.
- Dynamic metadata is loaded during configuration, while execution reads or creates dynamic values.
- Polling triggers read Agent-injected `PollingInfo` and return a `List` of events.
- The Agent owns managed connection and real-time subscription lifecycles.
- Connector upload ZIPs contain customer code and customer runtime dependencies, not SDK JARs.

## Licensing

The SDK repository is available under the [MIT License](../../LICENSE.txt). The `json.jar` transitive dependency (`org.json:json:20231013`) is Public Domain — see the [upstream project](https://github.com/stleary/JSON-java).
