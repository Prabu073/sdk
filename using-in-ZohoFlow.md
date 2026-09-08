# Use an On-Prem Extension in Zoho Flow

Your on-prem infrastructure holds systems that no cloud connector can reach — databases behind a firewall, ERP and CRM software on a private network, factory-floor devices, IoT sensors, legacy APIs, local file servers. An On-Prem Extension brings them into Zoho Flow as workflow-native actions and triggers.

You write the connector once, deploy it to an On-Prem Agent running inside your network, and Zoho Flow treats it like any other integration. Your data stays on your network. Any number of Flows can use the same Extension, and each can map its outputs into subsequent steps exactly as they would with a cloud service.

An Extension can be as simple as a single action that reads a row from a local database, or as rich as a set of real-time triggers that push events the moment they occur on your network.

## What you can connect

Any service, device, or system your On-Prem Agent can reach:

- On-premises databases, file servers, and message queues
- Factory-floor controllers, IoT sensors, and industrial devices
- Internal ERP, CRM, or legacy business applications
- Private APIs not accessible from the internet
- Custom business logic specific to your organisation

## How it fits into a Flow

```text
your network → On-Prem Agent → Extension code → Zoho Flow step
```

Zoho Flow discovers the Extension's actions and triggers automatically from the uploaded package — no API endpoints to write, no webhooks to configure. In a Flow, an Extension step works exactly like a cloud service step: input fields can be filled directly or mapped from earlier steps, and outputs are available to every step that follows.

An Extension can expose:

- **Actions** — called on demand when a Flow reaches that step
- **Polling triggers** — checked on a schedule; new events start a Flow run
- **Real-time triggers** — connected continuously; events are delivered the moment they occur

## Try a ready-made ZIP

Use this path to experience an Extension before changing or compiling any code:

1. Download an upload-ready ZIP from the [sample catalog](samples/README.md).
2. Open **On-Prem Extensions** in Zoho Flow and start a new upload.
3. Enter an Extension name and select the downloaded ZIP.
4. Choose the On-Prem Agent that will run the Extension.
5. Review the detected language, version, and actions, then deploy it.
6. Wait until deployment completes before using the Extension in a Flow.

Keep the ready-made ZIP intact. Its required structure is documented in the [SDK packaging guide](sdk/README.md#packaging).

## Add the Extension action

1. Open the Flow builder and add an action where the local operation should run.
2. Find the deployed On-Prem Extension and select its action.
3. Select or create a connection if the Extension requires one.
4. Configure the action fields.
5. Save and run the Flow.
6. Inspect the action output and map its fields into later steps as needed.

The Extension class, actions, input fields, and output fields are discovered from the uploaded code. Customers do not need to enter class or method names in the Flow builder.

## Build your own

After trying a ready-made ZIP, open that sample's language directory, modify its source, and run its build command. Upload the newly generated ZIP using the same process.

Start with [Hello Static](samples/01-hello-static/README.md) for the smallest complete example.
