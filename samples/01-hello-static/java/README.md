# Hello Static — Java

This directory contains a complete Java implementation and an upload-ready archive for the Hello Static sample.

## Compatibility

| Requirement | Value |
|---|---|
| SDK | `1.0.0` |
| Java source/bytecode | Java 11 |
| Authentication | None |
| Third-party runtime dependencies | None |

## Try the ready-made ZIP

1. Download [`hello-static.zip`](hello-static.zip).
2. Upload it as an On-Prem Extension named `hello-static` and deploy it to an On-Prem Agent.
3. During review, confirm that Zoho Flow detects the Java Extension and its `sayHello` action.
4. In the Flow builder, add the `sayHello` action from the deployed `hello-static` Extension.
5. Set **Name** to `Ada` and run the Flow.

Expected output:

```json
{
  "message": "Hello, Ada!"
}
```

For the complete upload and deployment steps, see [Deploy to Zoho Flow](../../../README.md#deploy-to-zoho-flow).

## Source layout

```text
source/
├── pom.xml
└── src/
    └── main/java/com/zoho/flow/samples/hello/
        ├── HelloConnector.java
        ├── HelloInput.java
        └── HelloOutput.java
```

## Build from source

Prerequisites: JDK 11 or newer and Maven 3.6+.

```bash
cd source
mvn package
```

Maven downloads the SDK automatically, compiles the connector, and produces the upload-ready ZIP.

The output ZIP is at `source/target/hello-static.zip`.

## Upload ZIP contents

```text
hello-static.zip
└── hello-static/
    └── hello-static.jar
```

`zohoflow-onprem-extension-sdk.jar` and `json.jar` are excluded — the Agent supplies them at runtime.

## Examples

- [`examples/input.json`](examples/input.json)
- [`examples/output.json`](examples/output.json)

If `name` is absent, empty, or whitespace-only, the action returns `Hello, World!`.

## Modify the sample

Edit the files under `source/src/main/java`, run `mvn package` again from the `source/` directory, and upload the newly generated ZIP. Keep all framework-created classes public with accessible no-argument constructors, and keep input/output fields non-final.

For the complete contract, read the [Java API reference](../../../docs/java/java-api.md).
