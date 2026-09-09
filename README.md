# Zoho Flow On-Prem Extension SDK

Your on-prem infrastructure holds systems that no cloud connector can reach — databases behind a firewall, ERP and CRM software on a private network, factory-floor devices, IoT sensors, legacy APIs, local file servers. An On-Prem Extension brings them into Zoho Flow as workflow-native actions and triggers, without exposing them to the internet or building a separate API.

## What you can connect

Any service, device, or system your On-Prem Agent can reach:

- On-premises databases, file servers, and message queues
- Factory-floor controllers, IoT sensors, and industrial devices
- Internal ERP, CRM, or legacy business applications
- Private APIs not accessible from the internet
- Custom business logic specific to your organisation

## How it works

```text
your network → On-Prem Agent → Extension code → Zoho Flow step
```

Build an Extension, deploy it to a Zoho Flow On-Prem Agent running inside your network, and Zoho Flow treats it like any other integration. Your data stays on your network. Any number of Flows can use the same Extension, and each can map its outputs into subsequent steps exactly as they would with a cloud service.

Zoho Flow discovers the Extension's actions and triggers automatically from the uploaded package — no API endpoints to write, no webhooks to configure.

## What an Extension can expose

- **Actions** — called on demand when a Flow reaches that step; input fields can be filled directly or mapped from earlier steps
- **Polling triggers** — checked on a schedule; new events start a Flow run
- **Real-time triggers** — connected continuously; events are delivered the moment they occur on your network

A single Extension can expose multiple actions and triggers, handle authentication, serve static or runtime-resolved input fields, and be shared across any number of Flows.

## Language support

| Language | Status | SDK |
|---|---|---|
| Java | Available | [Open the Java SDK](sdk/java/README.md) |
| Python | Not currently available | — |
| Node.js | Not currently available | — |

## Start here

1. Choose a language from the [SDK index](sdk/README.md) and open its overview.
2. Follow the getting-started guide for that language.
3. Use the language API reference when adding advanced capabilities.
4. Check compatibility metadata before packaging an Extension.
5. Upload and use your Extension in Zoho Flow — see [Deploy to Zoho Flow](#deploy-to-zoho-flow) below.

## Deploy to Zoho Flow

### Upload an Extension

1. Open **On-Prem Extensions** in Zoho Flow and start a new upload.
2. Enter an Extension name and select the packaged ZIP.
3. Choose the On-Prem Agent that will run the Extension.
4. Review the detected language, version, and actions, then deploy it.
5. Wait until deployment completes before using the Extension in a Flow.

The Extension's class, actions, input fields, and output fields are discovered automatically from the uploaded package — no class or method names need to be entered manually.

### Use it in a Flow

1. In the Flow builder, add an action step where the local operation should run.
2. Find the deployed On-Prem Extension and select its action.
3. Select or create a connection if the Extension requires authentication.
4. Configure the action fields — inputs can be filled directly or mapped from earlier steps.
5. Save and run the Flow. The action output is available to every step that follows.

## Try without writing code

Download a ready-made sample ZIP and upload it to Zoho Flow to see an Extension running end to end before writing a line of code. Browse the [sample catalog](samples/README.md) for available samples, their expected inputs and outputs, and build instructions if you want to modify them.

## Repository map

```text
sdk/
  README.md           SDK and language index, packaging guide
  java/
    README.md         Java SDK overview and documentation index
    docs/             Java API reference, guides, and compatibility
samples/
  README.md           Sample catalog
```

## License

This repository is available under the [MIT License](LICENSE.txt).

Third-party components retain their respective terms. See the third-party notices in each language SDK directory.

## Support and security

- [Support policy](SUPPORT.md)
- [Security reporting](SECURITY.md)
- [Release history](CHANGELOG.md)
