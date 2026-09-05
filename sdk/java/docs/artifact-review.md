# Candidate Artifact Review

This page records release-readiness findings for the supplied Java SDK candidate. It prevents accidental promises that are not yet supported by the source-verified customer contract.

## Confirmed

- `ZFAgentCustom.jar` was built for Java 11.
- `json.jar` contains JSON-java version `20231013.0.0` and was built for Java 8 or later.
- Artifact hashes are recorded in [`SHA256SUMS`](../SHA256SUMS).
- The SDK JAR contains the documented custom-class, annotation, dynamic, real-time, and transformation packages.
- Agent lifecycle bridge classes such as `AgentRuntime`, `DynamicAgentRuntime`, and `RealtimeAgentRuntime` are not present in the supplied SDK JAR.

## Requires confirmation before public release

1. **Embedded version:** the SDK JAR manifest has no implementation or SDK version. Version `1.0.0` currently exists only in repository metadata.
2. **Legacy or additional annotation:** the JAR contains `com.zoho.agent.flow.customclass.annotation.Trigger`, but the source-verified customer guide documents `@PollingTrigger` and `@RealTimeTrigger`, not `@Trigger`.
3. **Test-kit API:** the JAR contains `com.zoho.agent.flow.customclass.testing.*`. Confirm whether these classes are supported public utilities or should be delivered separately.
4. **Agent compatibility:** the minimum supported and maximum-tested Agent versions have not been supplied.
5. **Runtime bridge:** `LongLivedConnectionManager` intentionally references an Agent-side connection manager that is not packaged in the SDK. Confirm that this linkage matches every supported Agent version.

Customers should use only the APIs declared in the [Java API reference](java-api.md) until these items are resolved.
