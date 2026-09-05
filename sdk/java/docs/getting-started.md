# Zoho Flow Java Custom Classes — Static-First Customer Guide

This guide helps a Java developer build a first working custom connector quickly, then add advanced capabilities only when the integration needs them.

The SDK source is authoritative. Classes such as `CustomerApi`, `SpreadsheetClient`, `CsvSupport`, `DatabaseClient`, and `ProtocolClient` used in examples are placeholders for customer-owned code; they are not SDK classes.

## 1. Start here: a static action

A basic connector needs only:

1. A connector extending `AbstractCustomClass`.
2. An input POJO extending `CustomClassData`.
3. An output POJO extending `CustomClassData`.
4. A public method annotated with `@Action`.

Put each public top-level class in its own `.java` file.

### `TextConnector.java`

```java
package com.example.text;

import com.zoho.agent.flow.customclass.AbstractCustomClass;
import com.zoho.agent.flow.customclass.annotation.Action;

public final class TextConnector extends AbstractCustomClass {
    @Action
    public UppercaseOutput uppercase(UppercaseInput input) {
        UppercaseOutput output = new UppercaseOutput();
        output.value = input.value == null ? null : input.value.toUpperCase(java.util.Locale.ROOT);
        return output;
    }
}
```

### `UppercaseInput.java`

```java
package com.example.text;

import com.zoho.agent.flow.customclass.CustomClassData;
import com.zoho.agent.flow.customclass.annotation.Label;

public final class UppercaseInput extends CustomClassData {
    @Label("Text")
    public String value;
}
```

### `UppercaseOutput.java`

```java
package com.example.text;

import com.zoho.agent.flow.customclass.CustomClassData;

public final class UppercaseOutput extends CustomClassData {
    public String value;
}
```

The Agent reads the public POJO fields to build metadata. During execution, it deserializes Flow's JSON into `UppercaseInput`, invokes `uppercase`, and serializes `UppercaseOutput` back to JSON.

All framework-instantiated classes must be public and have an accessible no-argument constructor. A class has an implicit public no-argument constructor when it declares no constructor. Do not make execution fields `final`.

## 2. Static fields and annotations

Supported static field families include:

| Java field | Flow field |
|---|---|
| `String` | String |
| `boolean` / `Boolean` | Boolean |
| `int` / `Integer` | Integer |
| `long` / `Long` | Long |
| `float` / `Float` | Float |
| `double` / `Double` | Double |
| `java.util.Date` | Date-time |
| enum | Dropdown |
| Array or `List<T>` | Repeated value |
| `CustomClassData` subtype | Nested object |

Use arrays or parameterized `List<T>` for repeated values. Maps and arbitrary Java POJOs are not static field types; nested customer models must extend `CustomClassData`.

```java
public final class CreateContactInput extends CustomClassData {
    @Label("Full name")
    @Description("Name displayed in the remote application")
    public String name;

    @Label("Manager note")
    @Optional
    public String note;

    public ContactAddress address;
    public List<String> tags;
}

public final class ContactAddress extends CustomClassData {
    public String city;
    public String country;
}
```

Static fields are mandatory by default. Use `@Optional` when a value may be omitted. Treat optional values as nullable.

Customer-facing annotations are:

| Annotation | Purpose |
|---|---|
| `@Action` | Marks an action method |
| `@PollingTrigger` | Marks a polling-trigger method |
| `@RealTimeTrigger` | Marks a real-time subscription method |
| `@Authentication(Auth.class)` | Declares the connector authentication model |
| `@Label("...")` | Sets UI display text |
| `@Description("...")` | Provides help text |
| `@Optional` | Makes a static input optional |
| `@Mask` | Hides a saved authentication secret in the UI |
| `@DependsOn({...})` | Defines configuration-time dynamic dependencies |

## 3. Add authentication when required

Authentication is optional. Add it only when the external system requires credentials or connection settings.

```java
package com.example.contacts;

import com.zoho.agent.flow.customclass.AbstractAuthenticationData;
import com.zoho.agent.flow.customclass.AbstractCustomClass;
import com.zoho.agent.flow.customclass.annotation.Authentication;
import com.zoho.agent.flow.customclass.annotation.Label;
import com.zoho.agent.flow.customclass.annotation.Mask;

public final class ContactAuthentication extends AbstractAuthenticationData {
    @Label("Base URL")
    public String baseUrl;

    @Label("API token")
    @Mask
    public String token;
}

@Authentication(ContactAuthentication.class)
public final class ContactConnector extends AbstractCustomClass {
    private ContactAuthentication authentication() {
        return (ContactAuthentication) getAuthentication();
    }
}
```

The Agent injects authentication before invoking connector code. Customers may read `getConnectionId()` and `getModifiedTime()` when needed, but must not call SDK lifecycle initialization methods.

Use `@Mask` for secrets only inside authentication models. It controls UI visibility; it does not transform or redact action/trigger data.

## 4. When static fields are enough

Prefer static POJO fields whenever the schema is known while writing the connector.

Use dynamic APIs only when the available choices or data structure depend on configuration or on the connected customer's external system. Typical examples are:

- Projects loaded from an API.
- Worksheets depending on a selected spreadsheet.
- CSV columns depending on a file path.
- SQL columns depending on a selected table.
- ERP fields that differ between customer accounts.

Static fields remain easier to implement, document, validate, and maintain.

## 5. Dynamic-field mental model

Dynamic configuration has two phases:

| Phase | Framework action | Customer code |
|---|---|---|
| Configuration | Resolves dependencies and calls `load()` | Returns dropdown options or schema metadata |
| Execution input | Populates a read-only dynamic value | Reads it through `get()` and navigation methods |
| Execution output | Serializes the returned POJO | Calls `create()` and writes values |

Remember three verbs:

- `load()` — describe options or schema during configuration.
- `get()` — read framework-populated execution input.
- `create()` — create writable execution output.

Dynamic fields use these customer-facing types:

| Type | Meaning |
|---|---|
| `DynamicDropdown` | One selected option from values loaded at configuration time |
| `DropdownOption` | Dropdown `id` and display `label` |
| `DynamicField<DynamicObject>` | A runtime-defined object |
| `DynamicField<DynamicArray>` | A runtime-defined array of objects |
| `PrimitiveField` | One primitive schema leaf |
| `PrimitiveArray` | An array of primitive values |
| `DynamicObject` | Nested object schema or value |
| `DynamicArray` | Nested array-of-objects schema or value |

## 6. Dynamic dropdown

Extend `DynamicInput` when an input contains a dynamic member.

```java
import com.zoho.agent.flow.customclass.annotation.Label;
import com.zoho.agent.flow.customclass.dynamic.DropdownOption;
import com.zoho.agent.flow.customclass.dynamic.DynamicDropdown;
import com.zoho.agent.flow.customclass.dynamic.DynamicInput;
import java.util.List;
import java.util.stream.Collectors;

public final class ProjectInput extends DynamicInput {
    @Label("Project")
    public DynamicDropdown project = new DynamicDropdown() {
        @Override
        public List<DropdownOption> load() throws Exception {
            ProjectAuthentication auth = (ProjectAuthentication) ProjectInput.this.getAuthentication();
            return CustomerApi.listProjects(auth).stream().map(project -> option(project.id, project.name)).collect(Collectors.toList());
        }
    };
}
```

Return stable, nonblank, unique IDs. Labels are display text and may change without changing the stored identity.

During execution:

```java
String projectId = input.project.getId();
String projectLabel = input.project.getLabel();
```

Use `isResolved()` only when the selection may legitimately be absent. Do not attempt to set the selected option yourself; the Agent owns input population.

## 7. Dependent dropdowns

Use `@DependsOn` when a dynamic member requires earlier configuration values.

```java
public final class WorksheetInput extends DynamicInput {
    @Label("Spreadsheet")
    public DynamicDropdown spreadsheet = new DynamicDropdown() {
        @Override
        public List<DropdownOption> load() throws Exception {
            return SpreadsheetClient.listSpreadsheets().stream().map(item -> option(item.id, item.name)).collect(Collectors.toList());
        }
    };

    @Label("Worksheet")
    @DependsOn("spreadsheet")
    public DynamicDropdown worksheet = new DynamicDropdown() {
        @Override
        public List<DropdownOption> load() throws Exception {
            return SpreadsheetClient.listWorksheets(spreadsheet.getId()).stream().map(item -> option(item.id, item.name)).collect(Collectors.toList());
        }
    };
}
```

Flow resolves `spreadsheet` before calling `worksheet.load()`.

Dependencies must:

- Name Java fields in the same input hierarchy.
- Be nonblank and unique.
- Not refer to the current field.
- Not contain cycles.
- Refer to a populated static field or `DynamicDropdown`.

A `DynamicField` cannot currently be used as a dependency of another dynamic field.

### Safe `load()` caching

The Agent may call `load()` repeatedly while a customer configures or revisits a flow. Do not rely on a particular invocation count, call order, or framework cache lifetime. An instance field is not a useful cache because configuration loads may use newly created input or output objects.

Caching is optional and connector-owned. Use it only when the remote lookup is expensive and slightly stale configuration metadata is acceptable.

| Cache decision | Guidance |
|---|---|
| Key | Include the authentication `connectionId`, `modifiedTime`, the dynamic member name, and every value that affects the result, including all `@DependsOn` values |
| Lifetime | Use both a bounded entry count and a short, documented TTL appropriate to the remote system |
| Cached value | Cache immutable customer-owned source metadata, then build a fresh option list or `DynamicObject`/`DynamicArray` schema for every `load()` return |
| Concurrency | Make shared caches thread-safe; coalesce concurrent loads for the same key when duplicate remote calls are costly |
| Failures | Do not retain exceptions, authentication failures, null results, or partial responses as successful entries |
| Secrets | Never put access tokens, passwords, or other secret values in cache keys or diagnostic output |
| Invalidation | A changed dependency, changed authentication `modifiedTime`, expired TTL, or connector reload must produce a miss |

Do not cache framework-populated runtime values, `DynamicField`/`DynamicDropdown` instances, managed connections, or mutable schema/list instances. In particular, a key containing only `connectionId` is unsafe when the result also depends on a selected spreadsheet, table, or other configuration value.

```java
@Override
public List<DropdownOption> load() throws Exception {
    ProjectAuthentication auth = (ProjectAuthentication) ProjectInput.this.getAuthentication();
    ProjectCacheKey key = new ProjectCacheKey(auth.getConnectionId(), auth.getModifiedTime());
    List<ProjectSummary> projects = ProjectMetadataCache.get(key); // bounded TTL cache owned by connector code
    return projects.stream()
        .map(project -> option(project.id, project.name))
        .collect(Collectors.toList());
}
```

`ProjectMetadataCache` and `ProjectCacheKey` are customer-code examples, not SDK types. If freshness is mandatory or the remote call is inexpensive, call the service directly instead of caching.

## 8. Define a dynamic object schema

Use `PrimitiveField` for scalar leaves and `DynamicObject` for nested objects.

```java
import com.zoho.agent.flow.customclass.FieldType;
import com.zoho.agent.flow.customclass.dynamic.DynamicObject;
import com.zoho.agent.flow.customclass.dynamic.PrimitiveField;

private static DynamicObject contactSchema() {
    return new DynamicObject()
        .addField(new PrimitiveField("contact_id", "Contact ID", FieldType.STRING).mandatory())
        .addField(new PrimitiveField("name", "Name", FieldType.STRING))
        .addField(new PrimitiveField("created_at", "Created At", FieldType.DATE_TIME));
}
```

The field ID is the JSON key. The label is UI text. IDs must be stable and unique among siblings. Dynamic IDs cannot contain `.` because dotted paths are used for polling-field navigation.

Metadata builders available on schema fields are:

```java
.mandatory()
.mandatory(booleanValue)
.helpText("Shown to the customer")
.mask()
.mask(booleanValue)
```

For a static choice list:

```java
new PrimitiveField("priority", "Priority", FieldType.DROP_DOWN).options("Low", "Medium", "High");
```

`DATE_TIME` values use the SDK's standard ISO-8601 instant representation. Connector developers are responsible for converting external time zones and formats.

## 9. Nested objects and arrays

The schema classes describe the same shape that execution JSON must use.

```java
DynamicObject author = new DynamicObject()
    .addField(new PrimitiveField("id", "Author ID", FieldType.STRING))
    .addField(new PrimitiveField("name", "Author Name", FieldType.STRING));

DynamicObject book = new DynamicObject()
    .addField(new PrimitiveField("id", "Book ID", FieldType.STRING))
    .addField(new PrimitiveField("title", "Title", FieldType.STRING))
    .addField(new DynamicObject("author", "Author", author));

DynamicObject user = new DynamicObject()
    .addField(new PrimitiveField("id", "User ID", FieldType.STRING))
    .addField(new PrimitiveField("name", "User Name", FieldType.STRING))
    .addField(new PrimitiveArray("emails", "Email addresses", FieldType.STRING))
    .addField(new DynamicArray("books", "Books", book));
```

This represents:

```json
{
  "id": "u-1001",
  "name": "Diana Prince",
  "emails": ["diana@example.com"],
  "books": [
    {
      "id": "b-1001",
      "title": "Wonder Woman",
      "author": {
        "id": "a-1001",
        "name": "George Perez"
      }
    }
  ]
}
```

Only the outer `DynamicField` implements `load()`. Nested `DynamicObject`, `DynamicArray`, `PrimitiveField`, and `PrimitiveArray` nodes never load independently.

Choose a `DynamicArray` constructor according to its position:

| Constructor | Correct use |
|---|---|
| `new DynamicArray()` | Open root array with no configured element fields |
| `new DynamicArray(book)` | Root `DynamicField<DynamicArray>` whose elements follow the `book` schema |
| `new DynamicArray("books", "Books", book)` | Named array nested inside another `DynamicObject` |

The root constructors do not have an ID or label and cannot be inserted as nested schema fields. Use `PrimitiveArray` when the repeated elements are scalars rather than objects.

## 10. Dynamic input depending on static configuration

This CSV-style example derives its fields from a typed path.

```java
public final class CsvRowInput extends DynamicInput {
    @Label("CSV path")
    public String path;

    @Label("Column values")
    @DependsOn("path")
    public DynamicField<DynamicObject> columns = new DynamicField<DynamicObject>() {
        @Override
        public DynamicObject load() throws Exception {
            DynamicObject schema = new DynamicObject();
            for (String column : CsvSupport.readHeader(path)) {
                schema.addField(new PrimitiveField(column, column, FieldType.STRING));
            }
            return schema;
        }
    };
}
```

During execution, input values are read-only:

```java
DynamicObject columns = input.columns.get();
String customerName = columns.getString("customer_name");
Number amount = columns.getNumber("amount");
```

Available object readers are:

```java
get(id)
getString(id)
getBoolean(id)
getNumber(id)
getObject(id)
getArray(id)
getPrimitiveArray(id)
rawValue()
```

Nested arrays can be read by index or iteration:

```java
DynamicArray books = columns.getArray("books");
if (books != null) {
    for (DynamicObject book : books) {
        String title = book.getString("title");
    }
}
```

Calling write methods on framework-populated input throws `UnsupportedOperationException`.

## 11. Build dynamic output

Extend `DynamicOutput<I>` when an output contains a dynamic field. Its `input` and authentication are available while Flow loads output metadata.

```java
public final class DescribeInput extends CustomClassData {
    public String objectType;
}

public final class DescribeOutput extends DynamicOutput<DescribeInput> {
    @Label("Record")
    public DynamicField<DynamicObject> record = new DynamicField<DynamicObject>() {
        @Override
        public DynamicObject load() throws Exception {
            return CustomerApi.loadSchema(input.objectType);
        }
    };
}
```

At execution, create and populate the value:

```java
@Action
public DescribeOutput describe(DescribeInput input) throws Exception {
    RemoteRecord remote = CustomerApi.fetch(input.objectType);
    DescribeOutput output = new DescribeOutput();
    output.record.create()
        .add("id", remote.id)
        .add("name", remote.name);
    return output;
}
```

Object writers are:

```java
add(id, primitiveValue)
addObject(id)
addArray(id)
addPrimitiveArray(id)
loadJson(JSONObject)
loadJson(String)
```

Array writers are:

```java
DynamicArray rows = output.rows.create();
DynamicObject row = rows.addObject();
row.add("id", "r-1001");

PrimitiveArray tags = row.addPrimitiveArray("tags");
tags.add("new").add("priority");
```

Call `DynamicField.create()` only once per output field.

### Current dynamic-output constraint

Flow calls `load()` on a separate initialized output instance during configuration. During execution, `create()` creates a writable value but does not attach the separately resolved schema. Therefore, connector code must ensure that output IDs, primitive types, and nested shapes match the schema returned during configuration.

Raw JSON can be passed through when it already matches the configured contract:

```java
output.record.create().loadJson(thirdPartyJson);
```

If external JSON uses different names or contains sensitive values, construct the output explicitly instead:

```java
output.record.create()
    .add("customer_id", thirdPartyJson.getString("external_id"))
    .add("masked_email", maskEmail(thirdPartyJson.optString("email", null)));
```

The schema `.mask()` metadata does not transform data. The connector must perform any required masking.

## 12. Common static and dynamic combinations

| Input | Output | Input base | Output base |
|---|---|---|---|
| Static | Static | `CustomClassData` | `CustomClassData` |
| Dynamic | Static | `DynamicInput` | `CustomClassData` |
| Static | Dynamic | `CustomClassData` | `DynamicOutput<Input>` |
| Dynamic | Dynamic | `DynamicInput` | `DynamicOutput<Input>` |

Choose bases according to whether the POJO contains a top-level `DynamicDropdown` or `DynamicField`.

## 13. Spreadsheet recipe

An “Add row” action commonly uses:

```text
spreadsheet dropdown
  -> worksheet dropdown
       -> dynamic column values
            -> static action result
```

```java
public final class AddRowInput extends DynamicInput {
    public DynamicDropdown spreadsheet = new DynamicDropdown() {
        @Override public List<DropdownOption> load() throws Exception {
            return SpreadsheetClient.spreadsheets();
        }
    };

    @DependsOn("spreadsheet")
    public DynamicDropdown worksheet = new DynamicDropdown() {
        @Override public List<DropdownOption> load() throws Exception {
            return SpreadsheetClient.worksheets(spreadsheet.getId());
        }
    };

    @DependsOn({"spreadsheet", "worksheet"})
    public DynamicField<DynamicObject> columns = new DynamicField<DynamicObject>() {
        @Override public DynamicObject load() throws Exception {
            return SpreadsheetClient.columnSchema(spreadsheet.getId(), worksheet.getId());
        }
    };
}

public final class AddRowOutput extends CustomClassData {
    public String rowId;
}
```

At execution, read `spreadsheet.getId()`, `worksheet.getId()`, and `columns.get()`.

## 14. SQL or external-schema recipe

SQL and metadata-driven APIs usually need richer field types than a string map can express. Construct the schema from the external metadata:

```java
@DependsOn("table")
public DynamicField<DynamicObject> values = new DynamicField<DynamicObject>() {
    @Override
    public DynamicObject load() throws Exception {
        DynamicObject schema = new DynamicObject();
        for (DatabaseColumn column : DatabaseClient.columns(table.getId())) {
            schema.addField(new PrimitiveField(column.id, column.label, column.fieldType)
                .mandatory(!column.nullable)
                .helpText(column.description));
        }
        return schema;
    }
};
```

Validate or allow-list SQL identifiers. Never concatenate untrusted labels or values directly into SQL.

## 15. Polling trigger

A polling trigger accepts one `CustomClassData` input and returns `List<Event>`.

```java
public final class PollInput extends CustomClassData {
    public String queue;
}

public final class PollEvent extends CustomClassData {
    public String id;
    public String body;
    public long updatedTime;
}

@PollingTrigger
public List<PollEvent> poll(PollInput input) throws Exception {
    PollingInfo polling = input.getPollingInfo();
    Long previous = polling.hasLastPolledValue() ? polling.getLongValue() : null;
    return CustomerApi.fetchAfter(input.queue, polling.getFieldPath(), previous);
}
```

During configuration, Flow lets the customer choose a scalar leaf from the resolved output, such as:

```text
updatedTime
book.updatedTime
book.author.updatedTime
```

At execution, the Agent injects:

- `fieldPath` — the selected dotted path.
- `fieldType` — its scalar `FieldType`.
- `lastPolledValue` — the previous value, or null for the first poll.

Use the typed getter matching `getFieldType()`:

```java
getStringValue()
getBooleanValue()
getIntegerValue()
getLongValue()
getFloatValue()
getDoubleValue()
getDateTimeValue()
```

The connector does not set polling state on returned events. Flow knows the configured output path and obtains the next polling value from returned data. `PollingInfo` is populated only for the root input of an `@PollingTrigger` invocation; actions and real-time triggers do not receive it.

The external system may support server-side filtering and sorting. Agent-side sorting, deduplication, scheduling, and empty-result persistence are platform concerns and are not defined by the connector contract.

## 16. Polling trigger with dynamic output

Use the same unified dynamic bases:

```java
public final class DynamicPollInput extends DynamicInput {
    public String stream;
}

public final class DynamicPollOutput extends DynamicOutput<DynamicPollInput> {
    public DynamicField<DynamicObject> record = new DynamicField<DynamicObject>() {
        @Override public DynamicObject load() throws Exception {
            return CustomerApi.streamSchema(input.stream);
        }
    };
}

@PollingTrigger
public List<DynamicPollOutput> pollDynamic(DynamicPollInput input) throws Exception {
    PollingInfo polling = input.getPollingInfo();
    List<RemoteEvent> events = CustomerApi.fetchAfter(input.stream, polling.getFieldPath(), polling.hasLastPolledValue() ? polling.getLongValue() : null);
    List<DynamicPollOutput> output = new ArrayList<>();
    for (RemoteEvent event : events) {
        DynamicPollOutput item = new DynamicPollOutput();
        item.record.create().loadJson(event.canonicalJson);
        output.add(item);
    }
    return output;
}
```

Runtime output instances are created by customer code and are not the metadata-loading instance. Do not read their protected configuration-time `input` field during execution.

## 17. Real-time triggers and long-lived connections

Real-time triggers are an advanced feature for WebSocket, Kafka, Redis, RPC streaming, MQTT, or another push protocol.

Three types participate:

1. Authentication identifies the connection class.
2. `LongLivedConnection<A>` owns one physical connection and routes payloads by subscription key.
3. `Subscription<C,I,O>` represents one configured Flow subscription and converts payloads to output POJOs.

```java
public final class RealtimeAuthentication extends AbstractAuthenticationData {
    public String endpoint;
    public String token;

    @Override
    public Class<? extends LongLivedConnection<?>> getConnectionClass() {
        return ProtocolConnection.class;
    }
}

public final class ProtocolConnection extends LongLivedConnection<RealtimeAuthentication> {
    private ProtocolClient client;

    @Override
    public void connect(RealtimeAuthentication authentication) throws Exception {
        client = new ProtocolClient(authentication.endpoint, authentication.token, this::onMessage);
        client.connect();
    }

    private void onMessage(String channel, Object payload) {
        emit(channel, payload);
    }

    @Override protected void subscribeToSource(String channel) throws Exception { client.subscribe(channel); }
    @Override protected void unsubscribeFromSource(String channel) throws Exception { client.unsubscribe(channel); }

    @Override
    public void close() throws Exception {
        clearListeners();
        if (client != null) client.close();
    }
}
```

```java
public final class MessageInput extends CustomClassData {
    public String channel;
}

public final class MessageEvent extends CustomClassData {
    public String text;
}

public final class MessageSubscription extends Subscription<ProtocolConnection, MessageInput, MessageEvent> {
    private final MessageInput input;

    public MessageSubscription(MessageInput input) {
        this.input = input;
    }

    @Override protected String getSubscriptionKey() { return input.channel; }

    @Override
    protected MessageEvent convert(Object payload) {
        MessageEvent output = new MessageEvent();
        output.text = String.valueOf(payload);
        return output;
    }
}
```

```java
@Authentication(RealtimeAuthentication.class)
public final class RealtimeConnector extends AbstractCustomClass {
    @RealTimeTrigger
    public MessageSubscription messages(MessageInput input) {
        return new MessageSubscription(input);
    }
}
```

The Agent owns connection caching, subscription activation, listener registration, and cleanup. Connector code must not call framework lifecycle methods such as connection/subscription initialization or activation.

An action in the same authenticated connector may deliberately access the managed connection. Fetch it inside each invocation; do not retain it in an instance/static field and do not close it:

```java
@Action
public PublishOutput publish(PublishInput input) throws Exception {
    ProtocolConnection connection = LongLivedConnectionManager.getConnection(this);
    try {
        return connection.publish(input);
    } catch (ProtocolUnavailableException exception) {
        throw CustomClassException.retryable("Protocol connection is temporarily unavailable", exception);
    }
}
```

The Agent pins the connection from its first lookup until the action returns or throws, then returns it to normal LRU/idle eviction eligibility. Connections idle for 30 minutes by default are closed and recreated on a later lookup. Customer connection state and payload conversion must be thread-safe. Avoid blocking protocol receive threads.

## 18. Error classification

Use `CustomClassException` when connector code can distinguish transient and permanent failures.

```java
if (response.statusCode() == 429 || response.statusCode() >= 500) {
    throw CustomClassException.retryable("Remote service is temporarily unavailable");
}

if (response.statusCode() == 401) {
    throw CustomClassException.nonRetryable("Authentication was rejected");
}
```

Factories accepting a cause are also available. Preserve the original cause when wrapping an exception.

Use retryable errors for temporary failures. Use non-retryable errors for invalid credentials, unsupported configuration, or permanently invalid data. The exact retry schedule is controlled by the platform.

## 19. Customer API and Agent lifecycle

The full Agent runtime uses package-private lifecycle methods to initialize SDK objects. Agent-only runtime bridge classes call those methods and are excluded from the customer SDK JAR. Connector implementations therefore use only the customer-facing read and extension APIs; they do not initialize:

- Connector authentication.
- Authentication internal identity.
- Dynamic input authentication.
- Dynamic output input/authentication context.
- Polling information.
- Long-lived connections or subscriptions.

Customer code should use:

- Connector and dynamic-base protected `getAuthentication()`.
- `CustomClassData.getPollingInfo()` inside polling-trigger methods.
- `DynamicDropdown.getId()` and `getLabel()` during execution.
- `DynamicField.get()` for execution input.
- `DynamicField.create()` for execution output.
- Schema constructors and metadata builders during `load()`.
- `LongLivedConnectionManager.getConnection(this)` only when an action intentionally shares its managed long-lived connection.

## 20. Recommended project layout

```text
pom.xml or build.gradle
README.md
src/main/java/com/example/connector/
  ExampleConnector.java
  ExampleAuthentication.java
  action/
    CreateInput.java
    CreateOutput.java
  trigger/
    PollInput.java
    PollEvent.java
  dynamic/
    Schemas.java
  realtime/
    ProtocolConnection.java
    MessageSubscription.java
  client/
    CustomerApi.java
```

Reference the Zoho Agent SDK JAR through the build mechanism approved for the environment. Do not copy SDK implementation classes into the connector project. Keep third-party libraries and protocol code behind customer-owned client classes.

### Execution logs

The agent writes each library's log output to a dedicated directory alongside the main agent log:

```text
<agent-home>/logs/customlib/<libraryName>/<libraryName>0.log
```

Log records emitted by any `java.util.logging.Logger` on the execution thread — during action and polling-trigger invocations — are captured and written to this file. To log from connector code:

```java
import java.util.logging.Logger;

private static final Logger LOGGER = Logger.getLogger(ExampleConnector.class.getName());

// inside a method:
LOGGER.info("Processing row: " + rowId);
```

Log files rotate automatically (up to 3 files, 10 MB each). The library log is created when the library is loaded and closed when it is unloaded. Real-time trigger callbacks — including `convert()` and the event emission — are also routed to the per-library log on the connection thread.

## 21. Common mistakes

| Symptom | Cause | Fix |
|---|---|---|
| A simple connector becomes difficult to configure | Dynamic fields were used for a compile-time-known schema | Start with public static POJO fields; add dynamic fields only for tenant-dependent choices or shapes |
| A class or method is missing from metadata | The class/constructor is inaccessible, a field is `final`, or the method signature is invalid | Use public framework-instantiated classes with public no-arg constructors and supported method signatures |
| Static nested data is rejected | An arbitrary POJO or map was used | Make nested models extend `CustomClassData`; use dynamic structures only for runtime-defined schemas |
| A dynamic member is absent or throws during loading | The `DynamicDropdown` or `DynamicField` member was left null | Initialize dynamic members when declaring them |
| Dynamic input throws `UnsupportedOperationException` | Connector code attempted to mutate framework-populated input or called `create()` on it | Read input with `get()`; call `create()` only on output |
| Dynamic output is null or reports duplicate creation | `get()` was called before `create()`, or `create()` was called twice | Call `create()` exactly once and retain the returned writable structure |
| Nested array schema is rejected for a missing ID | A root `DynamicArray()` or `DynamicArray(schema)` was inserted as a child | Use `new DynamicArray(id, label, schema)` for nested arrays |
| Dynamic values fail schema validation | Labels, dotted IDs, unknown IDs, or a different output shape were used | Use stable dot-free schema IDs and return the exact configured shape |
| A dependency never resolves | `DynamicField` depends on another `DynamicField`, a static field has `@DependsOn`, or the graph cycles | Depend only on earlier static/dropdown configuration values and keep the graph acyclic |
| `load()` returns another account's or an old dependency's metadata | A shared cache key omitted authentication identity/version or a dependency value | Key by `connectionId`, `modifiedTime`, member name, and every result-affecting dependency; use a bounded TTL |
| Cached dynamic metadata changes between calls | A mutable option list or SDK schema object was reused | Cache immutable customer-owned source metadata and construct a fresh SDK result for each `load()` call |
| Polling trigger is ignored | It returns one event instead of `List<Event>` | Return a parameterized list of output events |
| Polling cursor is unavailable or has the wrong type | Output sets cursor state or input calls a getter that does not match `getFieldType()` | Read Agent-injected `PollingInfo` from input and use its matching typed getter |
| A secret remains visible in serialized data | `.mask()` or `@Mask` was treated as transformation | Use `@Mask` only for authentication UI secrecy; explicitly omit sensitive execution data |
| A managed connection is unexpectedly closed or leaked | Connector code cached or closed the Agent-owned connection | Fetch it inside each action invocation and never retain or close it |
| Delivery/retry behavior differs from assumptions | Connector code assumes schedules, ordering, or exactly-once guarantees | Implement idempotency and rely only on documented platform guarantees |

## 22. Final checklist

### First static project

- [ ] Connector extends `AbstractCustomClass`.
- [ ] Input and output extend `CustomClassData`.
- [ ] Action method is public, has one input parameter, and uses `@Action`.
- [ ] Public model classes have accessible no-argument constructors.
- [ ] Execution fields are public, supported, and non-final.
- [ ] Optional values use `@Optional` and are handled as nullable.
- [ ] Project compiles against the current SDK JAR.

### When adding dynamic fields

- [ ] Dynamic input extends `DynamicInput`.
- [ ] Dynamic output extends `DynamicOutput<Input>`.
- [ ] Every dynamic member is initialized.
- [ ] `load()` returns options or schema metadata only.
- [ ] Dependencies exist, are acyclic, and resolve before `load()`.
- [ ] Any connector-owned `load()` cache is bounded, expiring, dependency-complete, authentication-scoped, and returns freshly built SDK objects.
- [ ] Schema IDs are stable, unique among siblings, and contain no dots.
- [ ] Input values are read using `get()` and never mutated.
- [ ] Output values are created once and match the configured schema.
- [ ] Raw JSON is used only when it already matches the canonical contract.

### When adding triggers

- [ ] Polling trigger returns `List<Output>`.
- [ ] Polling trigger reads the configured path/type/value from `PollingInfo`.
- [ ] Polling output does not set its own last-polled value.
- [ ] Real-time authentication declares the correct connection class.
- [ ] Subscription generic types are concrete and match the trigger method.
- [ ] Long-lived connection and conversion code are thread-safe.
- [ ] Connector code does not call framework lifecycle methods.

Begin with the static action in section 1. Add later sections only when the external integration requires them.
