# Hello Static

Difficulty: **Beginner**  
Estimated time: **5 minutes with the ready-made ZIP; 15 minutes when building from source**

This is the smallest complete Zoho Flow on-prem extension. It exposes one `sayHello` action, accepts a static `name` field, and returns a static `message` field.

It demonstrates:

- Extending `AbstractExtension`.
- Marking a public method with `@Action`.
- Defining input and output models with `ExtensionData`.
- Using labels and descriptions in Flow metadata.
- Packaging a connector without bundling SDK-provided JARs.

## Available implementations

| Language | Status | Project | Ready-made ZIP |
|---|---|---|---|
| Java | Available | [Java instructions](java/README.md) | [Download](java/hello-static.zip) |

Only implemented languages are listed. The directory structure permits other language implementations to be added later without moving this sample.
