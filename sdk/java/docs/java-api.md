# Zoho Flow Java Custom Class SDK — Source-Verified Reference

## 1. Scope and source note

This reference describes the customer-facing Java API found in the inspected source tree on 2026-08-26. The Java source is authoritative.

No SDK version constant is associated with these packages in the inspected source. Therefore, compatibility with another Agent build is not guaranteed by this source alone.

## 2. Package map

| Package | Customer-facing purpose                                                                                                                                               |
|---|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `com.zoho.agent.flow.customclass` | Base classes for connectors and data, field types, exception handling, and access to long-lived connections such as Redis, WebSocket, RPC, SQL connection pools, etc. |
| `com.zoho.agent.flow.customclass.annotation` | Connector, method, field, and dependency annotations                                                                                                                  |
| `com.zoho.agent.flow.customclass.dynamic` | Dynamic dropdowns, schemas, and runtime dynamic values                                                                                                                |
| `com.zoho.agent.flow.customclass.realtime` | Long-lived protocol connections, logical subscriptions, and event delivery                                                                                            |
| `com.zoho.agent.flow.transformation` | Customer-callable POJO-to-JSON and JSON-to-POJO conversion utilities                                                                                                  |

Customer projects may use `JSONSerializer` and `JSONDeserializer` from `com.zoho.agent.flow.transformation`; see section 20.

Public type inventory:

| Fully qualified type | Kind | Customer role                                                       |
|---|---|---------------------------------------------------------------------|
| `com.zoho.agent.flow.customclass.AbstractCustomClass` | abstract class | Extend for the connector                                            |
| `com.zoho.agent.flow.customclass.CustomClassData` | abstract class | Extend for action, trigger, real-time, and nested data |
| `com.zoho.agent.flow.customclass.PollingInfo` | final class | Read the configured polling field and previous value |
| `com.zoho.agent.flow.customclass.AbstractAuthenticationData` | abstract class | Extend for authentication                                           |
| `com.zoho.agent.flow.customclass.CustomClassException` | checked exception | Create through static factories                                     |
| `com.zoho.agent.flow.customclass.FieldType` | enum | Select dynamic primitive schema types                               |
| `com.zoho.agent.flow.customclass.LongLivedConnectionManager` | final utility | Access a long-lived connection                                      |
| `com.zoho.agent.flow.customclass.dynamic.Dynamic` | abstract class | Framework hierarchy; do not extend directly                         |
| `com.zoho.agent.flow.customclass.dynamic.DynamicDropdown` | abstract class | Extend/instantiate anonymously for remote choices                   |
| `com.zoho.agent.flow.customclass.dynamic.DropdownOption` | final class | Dropdown metadata value                                             |
| `com.zoho.agent.flow.customclass.dynamic.DynamicField<T>` | abstract class | Extend/instantiate anonymously for a dynamic root                   |
| `com.zoho.agent.flow.customclass.dynamic.DynamicInput` | abstract class | Extend for dynamic action input                                     |
| `com.zoho.agent.flow.customclass.dynamic.DynamicOutput<I>` | abstract class | Extend for dynamic action output                                    |
| `com.zoho.agent.flow.customclass.dynamic.FieldSchema` | abstract class | Metadata hierarchy; use shipped concrete nodes                      |
| `com.zoho.agent.flow.customclass.dynamic.DynamicStructure` | abstract class | Root/nested structure hierarchy; use shipped concrete nodes         |
| `com.zoho.agent.flow.customclass.dynamic.DynamicObject` | final class | Object schema/value                                                 |
| `com.zoho.agent.flow.customclass.dynamic.DynamicArray` | final class | Object-array schema/value                                           |
| `com.zoho.agent.flow.customclass.dynamic.PrimitiveField` | final class | Primitive leaf schema                                               |
| `com.zoho.agent.flow.customclass.dynamic.PrimitiveArray` | final class | Primitive-array schema/value                                        |
| `com.zoho.agent.flow.customclass.realtime.LongLivedConnection<A>` | abstract class | Implement a long-lived protocol connection                          |
| `com.zoho.agent.flow.customclass.realtime.Subscription<C,I,O>` | abstract class | Implement a logical real-time subscription                          |
| `com.zoho.agent.flow.customclass.realtime.FlowListener<O>` | functional interface | Framework-provided event destination; do not implement/call directly |
| `com.zoho.agent.flow.transformation.JSONSerializer` | final utility | Convert a customer POJO to a JSON-compatible value                  |
| `com.zoho.agent.flow.transformation.JSONDeserializer` | final utility | Convert JSON text to a customer POJO or list                        |

## 3. Connector base classes

### `com.zoho.agent.flow.customclass.AbstractCustomClass`

Purpose: base of the one connector class scanned by the Agent. It has an implicit public no-argument constructor when the subclass declares none.

| Method | Who calls it | Contract |
|---|---|---|
| `protected AbstractAuthenticationData getAuthentication()` | Customer subclass | Reads the current invocation's authentication. May be `null` when no authentication is declared/supplied. |

The connector class must be instantiable through an accessible no-argument constructor. Only public methods declared directly on the connector class are scanned. A scanned method must have exactly one of `@Action`, `@PollingTrigger`, and `@RealTimeTrigger`.

```java
@Authentication(ApiAuth.class)
public final class ExampleConnector extends AbstractCustomClass {
    @Action
    public Pong ping(Ping input) {
        ApiAuth auth = (ApiAuth) getAuthentication();
        Pong out = new Pong();
        out.value = auth.baseUrl + "/" + input.value;
        return out;
    }
}
```

### `com.zoho.agent.flow.customclass.LongLivedConnectionManager`

Final utility with no public constructor.

```java
public static <C extends LongLivedConnection<?>> C getConnection(AbstractCustomClass customClass) throws Exception
```

Real-time triggers do not need to call this manager. The Agent creates, caches, reuses, and closes their long-lived connections automatically. An action may call this method only when it deliberately needs access to the same long-lived connection declared by its authentication. Customer code must not instantiate, cache, or close that connection itself.

The method rejects a null connector, missing authentication, missing connection class, or blank connection ID.

```java
ProtocolConnection connection = LongLivedConnectionManager.getConnection(this);
```

## 4. Input, output, and authentication bases

All customer model classes should be public and have an accessible no-argument constructor. The deserializer invokes `getDeclaredConstructor().newInstance()` without making the constructor accessible.

### `CustomClassData`

Unified base for action, polling-trigger, real-time-trigger, and nested static models. For polling triggers only, the Agent injects configuration-owned `PollingInfo` into the input POJO before invoking the method.

| Method | Customer use |
|---|---|
| `hasPollingInfo()` | Check whether polling state was injected. It is false for actions and real-time triggers. |
| `getPollingInfo()` | Read the configured field path, field type, and previous polled value. |

### `AbstractAuthenticationData`

Authentication is a separate framework model and does not extend `CustomClassData`.

| Method | Customer use |
|---|---|
| `public String getConnectionId()` | Read Agent-supplied stable connection identity. |
| `public long getModifiedTime()` | Read Agent-supplied authentication modification time. |
| `public Class<? extends LongLivedConnection<?>> getConnectionClass()` | Override when using a long-lived connection; default is `null`. |

```java
public final class ApiAuth extends AbstractAuthenticationData {
    public String baseUrl;
    @Mask public String token;

    @Override
    public Class<? extends LongLivedConnection<?>> getConnectionClass() {
        return ProtocolConnection.class;
    }
}
```

### Dynamic bases

| Class | Superclass | Generic bound | Intended use |
|---|---|---|---|
| `DynamicInput` | `CustomClassData` | — | Action or trigger input containing top-level dynamic members |
| `DynamicOutput<I>` | `CustomClassData` | `I extends CustomClassData` | Action or trigger output whose schema depends on configured input |

Each exposes protected authentication through `getAuthentication()`. `DynamicOutput` also exposes `protected transient I input` after framework initialization. Agent-owned runtime bridges inject these values through package-private lifecycle methods that are not included in the customer SDK artifact.

```java
public final class SearchOutput extends DynamicOutput<SearchInput> {
    public DynamicField<DynamicObject> result = new DynamicField<DynamicObject>() {
        @Override public DynamicObject load() { return Schemas.result(input.kind); }
    };
}
```

## 5. Available annotations

All have runtime retention.

| Annotation | Target | Contract |
|---|---|---|
| `@Authentication(Auth.class)` | Type | Declares an `AbstractAuthenticationData` subtype. |
| `@Action` | Method | Marks an action. |
| `@PollingTrigger` | Method | Marks a polling trigger. |
| `@RealTimeTrigger` | Method | Marks a real-time subscription factory. |
| `@Label("text")` | Field | UI label. |
| `@Description("text")` | Type, method, field | Help text describing a connector, action/trigger, or field in the Flow UI. |
| `@Optional` | Field | Makes a static field non-mandatory; static fields default to mandatory. |
| `@Mask` | Field | Marks an authentication field as a password field. After the value is saved, Flow UI does not fetch it back for display. It has no meaningful effect on action or trigger input/output fields. |
| `@DependsOn({"field"})` | Field | Declares configuration-time prerequisites for a `DynamicDropdown` or `DynamicField`. |

`@DependsOn` names Java fields in the same input hierarchy. Names must exist, be nonblank, unique, non-self-referential, and acyclic. A dependency may be a static field or `DynamicDropdown`; a `DynamicField` cannot be a dependency. Applying `@DependsOn` to a non-dynamic field is invalid.

## 6. Valid action method signatures

```java
@Action public Output run(Input input) throws Exception;
@Action public List<Output> runBatch(List<Input> input) throws Exception;
```

`Input` and `Output` must extend `CustomClassData`. Raw collections and non-concrete element types are rejected. The scanner recognizes `List`, not an arbitrary collection contract. The method must be public, declared on the connector class, and accept exactly one argument.

The source accepts `List` input only for actions. It also accepts either a single action output or `List<Output>`. `throws Exception` is optional Java syntax; exceptions are described in section 21.

## 7. Valid polling-trigger method signatures

```java
@PollingTrigger public List<Event> poll(PollInput input) throws Exception;
```

`PollInput` and `Event` extend `CustomClassData`. Polling input cannot be a list. A polling trigger must return `List<Event>`; a single `Event` return is not accepted by the scanner. The schedule, batch limit, and retry schedule are not guaranteed by the inspected SDK source.

## 8. Polling cursor behavior

During configuration, Flow lets the customer choose a scalar leaf from the resolved trigger output, for example `book.author.updatedTime`. At execution, the Agent injects that selection and its previous value into the trigger input as `PollingInfo`.

```java
@PollingTrigger
public List<OrderEvent> poll(PollInput input) throws Exception {
    PollingInfo polling = input.getPollingInfo();
    Long previous = polling.hasLastPolledValue() ? polling.getLongValue() : null;
    return Client.after(polling.getFieldPath(), previous);
}
```

`PollingInfo` provides `getFieldPath()`, `getFieldPathAsArray()`, `getFieldType()`, `hasLastPolledValue()`, and type-specific getters for supported scalar types. Call the getter matching `getFieldType()`; a mismatched getter fails. Dynamic schema IDs cannot contain `.` because dots delimit path segments. The connector returns ordinary event POJOs and does not set a cursor on each event. Flow already knows the chosen output path and derives the next value from returned data. Sorting, empty-result persistence, deduplication, batch size, and schedule are platform concerns and are not guaranteed by this SDK source.

## 9. Valid real-time-trigger method signatures

```java
@RealTimeTrigger
public OrdersSubscription orders(OrdersInput input) {
    return new OrdersSubscription(input);
}
```

`OrdersInput extends CustomClassData`. The concrete return class extends:

```java
Subscription<ConcreteConnection, OrdersInput, OrdersOutput>
```

`ConcreteConnection extends LongLivedConnection<? extends AbstractAuthenticationData>` and `OrdersOutput extends CustomClassData`. The method input must equal the resolved subscription input type. The scanner resolves concrete `C`, `I`, and `O` through a parameterized inheritance chain; unresolved type variables are rejected.

The same inheritance-aware generic resolver is used during metadata scanning and runtime activation. Intermediate parameterized subscription base classes are supported when all three types resolve concretely; unresolved type variables are rejected before activation.

## 10. Static field types and Java-to-SDK mapping

| Java type | `FieldType` | Array/list behavior |
|---|---|---|
| `String` | `STRING` | repeated string |
| `boolean` / `Boolean` | `BOOLEAN` | repeated boolean |
| `int` / `Integer` | `INTEGER` | repeated integer |
| `long` / `Long` | `LONG` | repeated long |
| `float` / `Float` | `FLOAT` | repeated float |
| `double` / `Double` | `DOUBLE` | repeated double |
| `java.util.Date` | `DATE_TIME` | repeated date-time |
| enum | Choice field, handled automatically | enum array/list becomes a multiple-choice field |
| `CustomClassData` subtype | Nested object, handled automatically | array/list becomes a repeated nested object |

Public instance fields are the simplest reliable model. Static and internal-key fields are excluded from metadata. Final fields are excluded from serialization and deserialization; because metadata scanning does include them, they appear in the Flow configuration UI but are always null or their initial value at runtime — do not declare data fields `final`.

The abstract `Number` class, maps, arbitrary POJOs, and Java time types are not supported static field families. Generic list elements must resolve to a concrete class.

Although `FieldType` recognizes `Date` subclasses for metadata, the deserializer's date conversion is implemented for the exact `java.util.Date` type. Use `java.util.Date`, not a custom subclass, for reliable input deserialization. Authentication metadata retains only scalar supported fields; arrays and nested object fields are filtered out.

```java
public final class CreateInput extends CustomClassData {
    @Label("Display name") @Description("Name sent to the service") public String name;
    @Optional public String note;
    public String[] tags;
    public Address address;
}
public final class Address extends CustomClassData { public String city; }
```

## 11. Dynamic-field lifecycle

Dynamic members are top-level fields of a dynamic input/output model; nesting a `Dynamic` member inside a static nested object is rejected.

| Phase | Framework behavior | Customer behavior |
|---|---|---|
| Configuration time, input | Instantiates/deserializes input, injects auth, validates dependencies, invokes selected member's `load()` | Return dropdown choices or a schema. Do not return runtime data. |
| Configuration time, output | Instantiates output with accessible no-arg constructor, initializes `input`/auth, invokes each dynamic output field's `load()` | Return the output schema based on configured input. |
| Execution time, input | Populates dropdown selection and dynamic value; marks dynamic value read-only | Call dropdown getters and `DynamicField.get()`. |
| Execution time, output | Serializes the returned output | Call `create()` once and populate the returned writable root. |

`DynamicField<T extends DynamicStructure>` must resolve exactly to `DynamicObject` or `DynamicArray`. Implement `public T load() throws Exception`. `get()` throws until populated. `create()` throws for framework input, if already created, or if the generic root is invalid. `create()` constructs an empty root and does not invoke `load()`.

### `load()` caching contract

The SDK does not expose a result-cache contract for `DynamicDropdown.load()` or `DynamicField.load()`. The Agent may invoke them repeatedly on newly created model instances, so connector behavior must remain correct without instance reuse and must not depend on an exact invocation count or order.

A connector may maintain its own cache when remote metadata is expensive to retrieve and bounded staleness is acceptable. Such a cache must:

- Have a bounded size and explicit TTL.
- Be safe for concurrent configuration requests.
- Include authentication `connectionId` and `modifiedTime`, the dynamic member identity, and every result-affecting static or dropdown dependency in its key.
- Exclude credentials and other secrets from keys and logs.
- Avoid treating failures, nulls, or partial responses as successful entries.
- Cache immutable customer-owned source metadata and create a fresh `List<DropdownOption>` or `DynamicStructure` for each return.

Do not cache populated execution values, dynamic member instances, managed connections, or mutable SDK schema objects. When freshness is required, do not cache. Connector code owns cache eviction and invalidation; no Agent cleanup guarantee is provided for customer-created caches.

## 12. Dynamic dropdown API

### `DynamicDropdown`

Abstract class with a package-owned constructor inherited from `Dynamic`; customer code uses an anonymous subclass or a customer subclass.

```java
public abstract List<DropdownOption> load() throws Exception;
protected final DropdownOption option(String id, String label);
public final DropdownOption getSelected();
public final String getId();
public final String getLabel();
public final boolean isResolved();
```

`load()` must return a non-null list of non-null options with nonblank, unique IDs. A null label displays as the ID. Selection getters throw before resolution.

### `DropdownOption`

```java
public DropdownOption(String id, String label);
public String getId();
public String getLabel();
```

Prefer `option(...)` within `DynamicDropdown.load()`.

```java
public DynamicDropdown project = new DynamicDropdown() {
    @Override public List<DropdownOption> load() throws Exception {
        ApiAuth auth = (ApiAuth) MyInput.this.getAuthentication();
        return Client.projects(auth).stream().map(p -> option(p.id, p.name)).collect(Collectors.toList());
    }
};
```

## 13. Dynamic schema node hierarchy

```text
Dynamic
├── DynamicDropdown
└── DynamicField<T extends DynamicStructure>

FieldSchema
├── PrimitiveField
├── PrimitiveArray
└── DynamicStructure
    ├── DynamicObject
    └── DynamicArray
```

### `FieldSchema`

Protected no-arg and `(String id, String label)` constructors are for SDK subclasses. Customer code calls final getters and fluent metadata methods:

```java
getId(); getLabel(); isMandatory(); getHelpText(); isMask();
mandatory(); mandatory(boolean); helpText(String); mask(); mask(boolean);
```

### `PrimitiveField`

```java
public PrimitiveField(String id, String label, FieldType type);
public FieldType getType();
public List<String> getOptions();
public PrimitiveField options(String... options);
```

### `PrimitiveArray`

Same constructor/type/options metadata, plus `add`, indexed reads, `size`, `isEmpty`, iteration, and `rawValue`. Its no-arg constructor is package-private.

### `DynamicObject`

```java
public DynamicObject();
public DynamicObject(String id, String label);
public DynamicObject(String id, String label, DynamicObject childSchema);
public DynamicObject addField(FieldSchema child);
public List<FieldSchema> getFields();
```

### `DynamicArray`

```java
public DynamicArray();
public DynamicArray(DynamicObject elementSchema);
public DynamicArray(String id, String label, DynamicObject elementSchema);
public DynamicObject getElementSchema();
```

Choose the constructor by where the array appears:

| Constructor | Use |
|---|---|
| `new DynamicArray()` | Open root array when element keys are not known during configuration |
| `new DynamicArray(elementSchema)` | Root array returned by `DynamicField<DynamicArray>.load()` with a known object schema |
| `new DynamicArray(id, label, elementSchema)` | Named array nested inside a `DynamicObject` schema |

The no-arg and one-arg forms have no field ID and therefore must not be added as children of another `DynamicObject`. The three-argument form supplies the required nested identity. Every array element is an object; use `PrimitiveArray` for repeated scalar values.

Nested nodes require nonblank IDs, and sibling IDs must be unique. Choose the matching scalar `FieldType` when constructing `PrimitiveField` or `PrimitiveArray`; object and dynamic field types are handled by their dedicated schema classes. Empty root schemas are allowed and act as open JSON containers at execution time.

```java
DynamicObject book = new DynamicObject()
    .addField(new PrimitiveField("id", "Book ID", FieldType.STRING).mandatory())
    .addField(new PrimitiveArray("tags", "Tags", FieldType.STRING));
DynamicObject root = new DynamicObject()
    .addField(new DynamicArray("books", "Books", book));
```

## 14. Accessing dynamic input values

```java
DynamicObject o = input.payload.get();
Object any = o.get("id");
String s = o.getString("name");
Boolean b = o.getBoolean("active");
Number n = o.getNumber("count");
DynamicObject child = o.getObject("child");
DynamicArray rows = o.getArray("rows");
PrimitiveArray tags = o.getPrimitiveArray("tags");
```

`DynamicArray` supports `size()`, `isEmpty()`, `getObject(int)`, and iteration over `DynamicObject`. `PrimitiveArray` supports `get`, `getString`, `getNumber`, `size`, `isEmpty`, and iteration over `Object`.

Missing or JSON-null values return `null`. With a loaded schema, unknown IDs and wrong typed-reader shapes throw. `getString`, `getBoolean`, and `getNumber` ultimately use casts, so a mismatched runtime value can produce `ClassCastException`.

Framework-populated dynamic input roots and their nested values are read-only. Mutation methods throw `UnsupportedOperationException`. Calling `rawValue()` on read-only `DynamicObject`, `DynamicArray`, or `PrimitiveArray` returns a defensive JSON copy.

## 15. Creating dynamic output values

```java
DynamicObject out = output.payload.create();
out.add("name", "Ada");
DynamicObject address = out.addObject("address");
address.add("city", "Chennai");
DynamicArray rows = out.addArray("rows");
rows.addObject().add("id", "r1");
PrimitiveArray tags = out.addPrimitiveArray("tags");
tags.add("sdk").add(null);
```

`DynamicObject.add`, `addObject`, `addArray`, and `addPrimitiveArray` reject blank IDs and duplicate writes. If that value object has an attached schema, they also reject unknown IDs, wrong shapes, and incompatible primitive values. `DynamicArray.addObject()` appends a row. No remove/replace API exists. In particular, `DynamicField.create()` produces an empty root without attaching the schema separately returned by configuration-time `load()`; output code must keep its emitted IDs and shapes consistent itself.

`loadJson(JSONObject|String)` is available on `DynamicObject`; `loadJson(JSONArray|String)` is available on `DynamicArray`. It is appropriate only for JSON already keyed by canonical schema IDs and matching all shapes/types.

Customer-created output roots are writable. Their `rawValue()` returns the live backing `JSONObject` or `JSONArray`; mutating that object bypasses the typed methods and should be avoided.

## 16. Nested object and array handling

| Runtime shape | Schema node | Read | Write |
|---|---|---|---|
| object | `DynamicObject` | `getObject(id)` | `addObject(id)` |
| array of objects | `DynamicArray` | `getArray(id)` / `getObject(index)` | `addArray(id)` / `addObject()` |
| array of primitives | `PrimitiveArray` | `getPrimitiveArray(id)` / indexed getters | `addPrimitiveArray(id)` / `add(value)` |

Object-array elements may be JSON null; `getObject(index)` then returns `null`. Array bounds are delegated to `org.json`. Retain and fill the child returned by an `add*` method; each parent key can be written only once.

## 17. Long-lived connection lifecycle

### `LongLivedConnection<A extends AbstractAuthenticationData>`

Abstract, implements `AutoCloseable`, and is created by the Agent through an accessible no-argument constructor.

Customer implements:

```java
public abstract void connect(A authentication) throws Exception;
protected abstract void subscribeToSource(String key) throws Exception;
protected void unsubscribeFromSource(String key) throws Exception; // optional
public abstract void close() throws Exception;
```

Customer calls `protected final emit(String key, Object rawMessage)` when the protocol receives a message, and may call `protected final clearListeners()` during cleanup. Connection initialization is package-private and performed through an Agent-only runtime bridge.

Connections are keyed by project class loader and authentication connection ID and reused by actions and triggers. They are closed under capacity pressure, after the cache's configured idle period (30 minutes by default), during project shutdown, or during Agent shutdown. Active subscriptions hold a pin until deactivation. Actions acquire a pin lazily when they first request the managed connection and release it when the method returns or throws. If `connect` fails, the Agent attempts `close` and suppresses cleanup failure onto the original exception. Exact reconnection/backoff behavior is not guaranteed by this source.

## 18. Subscription lifecycle

### `Subscription<C,I,O>`

Abstract, implements `AutoCloseable`. Customer implements only:

```java
protected abstract String getSubscriptionKey();
protected abstract O convert(Object payload);
```

The key must be nonblank when activated. The Agent initializes and subscribes the returned instance. The first SDK listener for a key calls `subscribeToSource`; the last removed listener calls `unsubscribeFromSource`. `convert` runs synchronously in the thread that calls connection `emit`, and its output is passed to the Agent listener.

Connection-type resolution, initialization, and subscription activation are package-private and performed through an Agent-only runtime bridge. Do not call `close` from connector trigger code; the Agent closes subscriptions during deactivation and project cleanup.

`FlowListener<O extends CustomClassData>` is a public functional interface with `void emit(O output)`. It is Agent-provided to the internal activation path, not a customer extension point in a connector project.

```java
public final class OrdersSubscription extends Subscription<ProtocolConnection, OrdersInput, OrderEvent> {
    private final OrdersInput input;
    public OrdersSubscription(OrdersInput input) { this.input = input; }
    @Override protected String getSubscriptionKey() { return input.topic; }
    @Override protected OrderEvent convert(Object payload) { return Mapping.toOrderEvent(payload); }
}
```

## 19. Thread-safety expectations

Connection listener routing uses concurrent collections, and listener registration/removal is synchronized. This does not make customer connection fields, protocol clients, `convert`, or output objects thread-safe. `emit` calls listeners synchronously on the caller's thread; a protocol client may invoke it concurrently for different messages. Make long-lived customer state thread-safe and avoid blocking receive threads unnecessarily.

The connector instance is created per shown execution/activation path, while the Agent may reuse a long-lived connection across actions and subscriptions. No broader invocation serialization, ordering, delivery-once guarantee, or memory model guarantee is provided by the inspected source.

## 20. POJO JSON serialization and deserialization

Customer code may use these public utilities:

```java
import com.zoho.agent.flow.transformation.JSONDeserializer;
import com.zoho.agent.flow.transformation.JSONSerializer;
import org.json.JSONObject;
import java.util.List;

CreateUserInput input = JSONDeserializer.convert(jsonText, CreateUserInput.class);
JSONObject json = (JSONObject) JSONSerializer.convert(input);
List<CreateUserInput> inputs = JSONDeserializer.convertList(jsonArrayText, CreateUserInput.class);
```

Example POJO:

```java
public final class CreateUserInput extends CustomClassData {
    public String name;
    public Integer age;
    public java.util.Date createdAt;
    public Role role;
    public Address address;
    public List<String> tags;
}

public final class Address extends CustomClassData {
    public String city;
}

public enum Role { ADMIN, MEMBER }
```

Example JSON:

```json
{
  "name": "Asha",
  "age": 31,
  "createdAt": "2026-08-20T07:30:00Z",
  "role": "ADMIN",
  "address": {"city": "Chennai"},
  "tags": ["customer", "priority"]
}
```

JSON keys are Java field names; `@Label` does not rename them. Serialization uses an accessible getter when available, otherwise a public field. It skips final fields, null values, and cyclic revisits. Arrays and collections become JSON arrays, `Date` becomes an ISO-8601 UTC instant, and enums use their constant names.

Deserialization requires an accessible no-argument constructor and uses a setter when available, otherwise a public field. Missing fields retain their Java defaults. JSON null for a supported scalar produces no assignment. Invalid numeric, date, or enum conversion generally produces no assignment; an unrecognized boolean string is parsed as `false`. Omit absent optional nested objects or arrays instead of relying on JSON-null handling for those shapes.

`JSONSerializer.convert(Object)` returns a JSON-compatible value, normally `JSONObject` for a POJO and `JSONArray` for a collection. `JSONDeserializer.convert(String, Class<T>)` converts one JSON object, while `convertList(String, Class<T>)` converts a JSON array.

## 21. Validation and exception behavior

`CustomClassException extends Exception` has no public constructor. Create one with:

```java
CustomClassException.retryable(message);
CustomClassException.retryable(message, cause);
CustomClassException.nonRetryable(message);
CustomClassException.nonRetryable(message, cause);
```

`isRetryable()` exposes the classification. Use retryable only for transient failures and non-retryable for bad credentials/configuration or unsupported data.

Throw `CustomClassException` deliberately when the connector can classify a failure. Exact transport formatting and server retry policy are not guaranteed by the inspected SDK source.

Metadata and value validation commonly throws `IllegalArgumentException`, unresolved state throws `IllegalStateException`, and attempts to mutate read-only dynamic input throw `UnsupportedOperationException`.

## 22. Customer-callable API

| API | Customer role |
|---|---|
| `AbstractCustomClass.getAuthentication()` | Call from subclass |
| Dynamic base `getAuthentication()` and output `input` | Read in subclass, primarily during `load()` |
| `DynamicDropdown.load()` | Implement; framework calls |
| Dropdown getters | Call after configuration/execution resolution |
| `DynamicField.load()` | Implement; framework calls at configuration time |
| `DynamicField.get()` | Call for populated input |
| `DynamicField.create()` | Call for execution output |
| Schema constructors/mutators | Call while building schema |
| Dynamic value access and mutation methods | Call according to read-only/writable phase |
| `CustomClassData.getPollingInfo()` and typed `PollingInfo` getters | Customer polling logic |
| Authentication connection-ID/modified-time getters | Customer read |
| `LongLivedConnectionManager.getConnection(this)` | Customer action call |
| Connection `connect`, subscribe/unsubscribe hooks, `close` | Implement; framework calls |
| Connection `emit` | Customer connection calls on incoming data |
| Subscription `getSubscriptionKey`, `convert` | Implement; framework calls |
| Subscription `close` | Agent owns the call despite the public `AutoCloseable` contract |

## 23. Decision table

| Requirement                                                                             | Use |
|-----------------------------------------------------------------------------------------|---|
| Compile-time-known field                                                                | Public static-model field |
| Optional/help/label metadata                                                            | `@Optional`, `@Description`, `@Label` |
| Authentication password field                                                           | `@Mask` |
| Choices fetched during configuration                                                    | `DynamicDropdown` |
| Tenant-dependent object schema                                                          | `DynamicField<DynamicObject>` |
| Tenant-dependent repeated object schema                                                 | `DynamicField<DynamicArray>` |
| Primitive repeated values inside dynamic schema                                         | `PrimitiveArray` |
| Periodic events                                                                         | `@PollingTrigger` returning `List<O>` |
| Immediate protocol events                                                               | `@RealTimeTrigger` returning a `Subscription` |
| Long-lived connections or persistent resources such as Redis, WebSocket, RPC clients, and SQL connection pools | `LongLivedConnection` plus authentication `getConnectionClass()` |
| One request/response only                                                               | Connector-owned ordinary client; no long-lived SDK abstraction required |

## 24. LLM/project-generator correctness checklist

- [ ] Connector extends `AbstractCustomClass`, is public, and has an accessible no-arg constructor.
- [ ] Every model instantiated by the Agent is public with an accessible no-arg constructor.
- [ ] Each exposed method is public, declared on the connector, and has exactly one method annotation.
- [ ] Every action, polling-trigger, real-time-trigger, and nested data model extends `CustomClassData`.
- [ ] Polling logic reads Agent-injected `PollingInfo`; output records do not set a last-polled value.
- [ ] Polling trigger returns `List<Output>`.
- [ ] Batch actions use parameterized `List<Input>` and `List<Output>`.
- [ ] Static fields use only source-supported types and are not final.
- [ ] Dynamic members are initialized, top-level, and exactly `DynamicDropdown` or `DynamicField<DynamicObject|DynamicArray>`.
- [ ] `@DependsOn` names only populated static fields or dropdowns; no dynamic-field dependency or cycle exists.
- [ ] `load()` returns schema/options at configuration time; runtime output uses `create()`.
- [ ] Any connector-owned `load()` cache is bounded, expiring, authentication-scoped, dependency-complete, thread-safe, and returns fresh SDK objects.
- [ ] Input dynamic values are read, never mutated; output dynamic values are created once.
- [ ] Stable IDs are JSON keys; labels are display text.
- [ ] Raw JSON passthrough is used only for canonical, schema-matching JSON.
- [ ] Authentication is declared when needed and long-lived auth overrides `getConnectionClass()`.
- [ ] Subscription C, I, and O types resolve to concrete classes (direct declaration or through a parameterized chain; unresolved type variables are rejected).
- [ ] Connector never calls framework lifecycle bridges.
- [ ] Customer-owned clients/helpers are clearly separated from SDK APIs.
- [ ] Transient vs permanent failures use the intended `CustomClassException` factory.
