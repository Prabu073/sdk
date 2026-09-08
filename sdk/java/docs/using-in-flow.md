# Use an On-Prem Extension in Zoho Flow

An On-Prem Extension turns Java code that can reach a local system, file, database, or device into an action that can be used in a Zoho Flow.

Use an On-Prem Extension when a Flow needs to:

- Reach a service available only from the customer's network.
- Read or write local files, databases, or business systems.
- Interact with local devices such as printers.
- Run customer-specific Java logic as part of an automated workflow.

## How it fits into a Flow

```text
Extension ZIP → On-Prem Agent → action in a Flow → output for later steps
```

The ZIP contains the customer's compiled Extension and any customer-owned runtime dependencies. After deployment, Zoho Flow discovers its actions and fields. When a Flow reaches an Extension action, the selected On-Prem Agent runs the Java code and returns its output to the Flow.

An Extension is used as an action step: its inputs can be entered directly or mapped from earlier steps, and its outputs can be mapped into later steps.

## Try a ready-made ZIP

Use this path to experience an Extension before changing or compiling any code:

1. Download an upload-ready ZIP from the [sample catalog](../../../samples/README.md).
2. Open **On-Prem Extensions** in Zoho Flow and start a new upload.
3. Enter an Extension name and select the downloaded ZIP.
4. Choose the On-Prem Agent that will run the Extension.
5. Review the detected language, version, and actions, then deploy it.
6. Wait until deployment completes before using the Extension in a Flow.

Keep the ready-made ZIP intact. Its required structure is documented in [Packaging and dependencies](packaging.md).

## Add the Extension action

1. Open the Flow builder and add an action where the local operation should run.
2. Find the deployed On-Prem Extension and select its action.
3. Select or create a connection if the Extension requires one.
4. Configure the action fields.
5. Save and run the Flow.
6. Inspect the action output and map its fields into later steps as needed.

The Extension class, actions, input fields, and output fields are discovered from the uploaded code. Customers should not need to enter Java class or method names in the Flow builder.

## Build your own

After trying a ready-made ZIP, open that sample's language directory, modify its source, and run its build command. Upload the newly generated ZIP using the same process.

Start with [Hello Static](../../../samples/01-hello-static/README.md) for the smallest complete Java example.
