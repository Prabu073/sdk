# Hello Static — Java

This directory contains a complete Java implementation and an upload-ready archive for the Hello Static sample.

## Compatibility

| Requirement | Value |
|---|---|
| SDK | `1.0.0` |
| Java source/bytecode | Java 11 |
| Authentication | None |
| Third-party runtime dependencies | None |

The supported Zoho Flow Agent range is pending product verification. See the SDK [compatibility guide](../../../sdk/java/docs/compatibility.md).

## Try the ready-made ZIP

1. Download [`hello-static.zip`](hello-static.zip).
2. Open the on-prem-extension/library upload interface in Zoho Flow.
3. Use `hello-static` as the library link name if the interface asks for one.
4. Upload the ZIP.
5. Select the discovered `sayHello` action.
6. Set **Name** to `Ada` and run the action.

Expected output:

```json
{
  "message": "Hello, Ada!"
}
```

## Source layout

```text
source/
└── src/
    ├── main/java/com/zoho/flow/samples/hello/
    │   ├── HelloConnector.java
    │   ├── HelloInput.java
    │   └── HelloOutput.java
    └── test/java/com/zoho/flow/samples/hello/
        └── HelloConnectorSmokeTest.java
```

## Build from source

Prerequisites:

- JDK 11 or newer with `javac`, `java`, and `jar` available.
- `zip` on macOS/Linux, or PowerShell on Windows.
- This complete repository checkout, because the script uses the SDK JARs under `sdk/java/lib`.

macOS/Linux:

```bash
./build.sh
```

Windows:

```bat
build.bat
```

The build:

1. Compiles the connector for Java 11.
2. Compiles and runs the dependency-free smoke test.
3. Creates the customer connector JAR.
4. Packages `hello-static.zip` using the required top-level directory.

## Upload ZIP contents

```text
hello-static.zip
└── hello-static/
    └── hello-static.jar
```

The archive intentionally excludes `ZohoFlow-extension-sdk.jar` and `json.jar`; the Agent supplies them at runtime.

The download checksum is recorded in [`SHA256SUMS`](SHA256SUMS).

## Examples

- [`examples/input.json`](examples/input.json)
- [`examples/output.json`](examples/output.json)

If `name` is absent, empty, or whitespace-only, the action returns `Hello, World!`.

## Modify the sample

Edit the files under `source/src/main/java`, run the build again, and upload the newly generated `hello-static.zip`. Keep all framework-created classes public with accessible no-argument constructors, and keep input/output fields non-final.

For the complete contract, read the [Java API reference](../../../sdk/java/docs/java-api.md).
