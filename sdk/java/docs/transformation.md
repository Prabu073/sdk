# Zoho Flow Java POJO–JSON Transformation Reference

## 1. Scope

This document describes how connector developers convert ordinary customer POJOs to and from JSON using:

- `com.zoho.agent.flow.transformation.JSONSerializer`
- `com.zoho.agent.flow.transformation.JSONDeserializer`
- `com.zoho.agent.flow.transformation.JsonUtil`
- customer-facing annotations in `com.zoho.agent.flow.transformation.annotation`

The behavior documented here is based on the inspected Java source. Examples use only the customer-supported scalar types and the `List`/`ArrayList` collection contract.

## 2. Basic usage

### POJO to JSON

```java
import com.zoho.agent.flow.transformation.JSONSerializer;
import org.json.JSONObject;

Customer customer = new Customer();
customer.name = "Asha";
customer.active = true;

JSONObject json = (JSONObject) JSONSerializer.convert(customer);
```

Result:

```json
{
  "name": "Asha",
  "active": true
}
```

### JSON to POJO

```java
import com.zoho.agent.flow.transformation.JSONDeserializer;

String payload = "{\"name\":\"Asha\",\"active\":true}";
Customer customer = JSONDeserializer.convert(payload, Customer.class);
```

### Minimal customer model

```java
public final class Customer {
    public String name;
    public boolean active;

    public Customer() {}
}
```

JSON property names are Java field names. Transformation annotations can include, exclude, or format values, but they do not rename fields.

## 3. Public conversion API

### `JSONSerializer`

```java
public static Object convert(Object value) throws Exception;
```

The returned type depends on the input:

| Java input | Returned value |
|---|---|
| POJO | `org.json.JSONObject` |
| Java array | `org.json.JSONArray` |
| `List<?>` or `ArrayList<?>` | `org.json.JSONArray` |
| supported scalar | corresponding JSON scalar |
| `null` | `null` |

### `JSONDeserializer`

```java
public static <T> T convert(String payload, Class<T> type) throws Exception;
public static <T> List<T> convertList(String payload, Class<T> elementType) throws Exception;
```

`convert` expects a JSON object when converting a POJO. `convertList` expects a JSON array and returns an `ArrayList` through its declared `List<T>` return type.

```java
Customer customer = JSONDeserializer.convert(objectJson, Customer.class);

ArrayList<Customer> customers = new ArrayList<>(
    JSONDeserializer.convertList(arrayJson, Customer.class)
);
```

`convert` returns `null` when its payload string is `null` or empty. `convertList` requires a non-null, non-empty JSON array string. Malformed or shape-incompatible JSON throws an exception from the JSON parser.

### `JsonUtil`

```java
public static final DateTimeFormatter DEFAULT_DATE_FMT;
public static boolean isSimpleType(Class<?> type);
public static String resolveClassName(Class<?> type, boolean array);
```

`DEFAULT_DATE_FMT` is ISO-8601 instant format in UTC. `isSimpleType` reports whether the supplied class belongs to the supported scalar model. `resolveClassName` returns the lower-case SDK field-type name and throws `IllegalArgumentException` for unsupported classes.

## 4. Supported customer data model

### Scalar fields

Only these scalar Java types are supported in customer POJOs:

| SDK family | Java types | Typical JSON |
|---|---|---|
| String | `String` | `"text"` |
| Boolean | `boolean`, `Boolean` | `true` |
| Integer | `int`, `Integer` | `1000` |
| Long | `long`, `Long` | `100000` |
| Float | `float`, `Float` | `10.5` |
| Double | `double`, `Double` | `10.5` |
| Date-time | exact `java.util.Date` | `"2026-08-20T07:30:00Z"` |

### Nested POJOs

Nested customer classes are supported as JSON objects. Each nested class must follow the same field, accessor, constructor, and type rules.

```java
public final class Order {
    public String id;
    public Address shippingAddress;
    public Order() {}
}

public final class Address {
    public String city;
    public String postalCode;
    public Address() {}
}
```

```json
{
  "id": "o-100",
  "shippingAddress": {
    "city": "Chennai",
    "postalCode": "600001"
  }
}
```

### Arrays

One-dimensional arrays of supported scalars or customer POJOs are supported.

```java
public String[] tags;
public LineItem[] items;
```

Avoid multidimensional arrays. A JSON null element cannot be assigned to an array with a primitive component type.

### Collections

Customer collection fields may be declared as `List<T>` or `ArrayList<T>`. Deserialization creates an `ArrayList` runtime value in both cases. `T` must be a concrete supported scalar class or concrete customer POJO class.

```java
public List<String> labels;
public ArrayList<String> tags;
public ArrayList<LineItem> items;
```

Do not declare customer fields as `Collection`, `LinkedList`, `Set`, another collection implementation, a raw `List`/`ArrayList`, or a nested generic such as `ArrayList<ArrayList<String>>`.

## 5. POJO construction requirements

The deserializer creates each POJO with:

```java
type.getDeclaredConstructor().newInstance();
```

Therefore every deserialized class must:

- be concrete;
- be accessible to the SDK;
- provide an accessible no-argument constructor;
- use non-final data fields;
- use supported fields only.

Recommended model:

```java
public final class CreateContactInput {
    private String name;
    private Boolean active;

    public CreateContactInput() {}

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}
```

Public fields may be used instead of accessors. Avoid field hiding across a class hierarchy because both the subclass and superclass fields are inspected.

## 6. Getter resolution and naming standard

The converter applies the method-name resolution defined by `AccessorUtil`. Customer code does not call that package-level utility directly; POJO classes must follow its naming rules.

The serializer first looks for a public getter. If no recognized public getter exists, it reads the field directly only when the field is public.

Only public methods are resolved, including inherited public methods. A private, protected, or package-private getter is not used.

### Non-boolean fields

For a field named `name`, the recognized getter is:

```java
public String getName();
```

Pattern:

```text
field: fieldName
getter: get + uppercase(first character) + remaining characters
```

### Boolean fields

For a field named `active` of type `boolean` or `Boolean`, getter candidates are checked in this order:

```java
public boolean isActive();
public boolean getActive();
```

The getter's return type should match the field type.

### Boolean fields beginning with `is`

For a field literally named `isActive`, candidates are checked in this order:

```java
public boolean isActive();
public boolean getIsActive();
public boolean isIsActive();
```

This naming shape is easy to misread. Prefer a field named `active` with `isActive()` or `getActive()`.

### Recommended getter standard

```java
private String name;
private boolean active;

public String getName() { return name; }
public boolean isActive() { return active; }
```

Do not add parameters to getters. The resolver searches for a public zero-argument method with the expected name.

## 7. Setter resolution and naming standard

The deserializer applies the corresponding `AccessorUtil` setter rules. It performs three deterministic lookup passes over the same setter-name candidates:

1. the exact declared field type;
2. the primitive/wrapper counterpart, when one exists;
3. the `List`/`ArrayList` counterpart, when one exists.

Only public methods are considered, including inherited public methods. If no recognized setter exists, the deserializer writes directly only when the field is public.

### Non-boolean fields

For a field named `name` of type `String`:

```java
public void setName(String name);
```

### Boolean fields

For a primitive `boolean active` field, lookup order is:

```java
public void setActive(boolean active);
public void setIsActive(boolean active);
public void setActive(Boolean active);
public void setIsActive(Boolean active);
```

For a `Boolean active` field, the wrapper signatures are checked first, followed by the primitive signatures.

For a primitive field literally named `boolean isActive`, lookup order is:

```java
public void setIsActive(boolean active);
public void setActive(boolean active);
public void setIsActive(Boolean active);
public void setActive(Boolean active);
```

The same counterpart rule applies to `int`/`Integer`, `long`/`Long`, `float`/`Float`, and `double`/`Double`.

### `List` and `ArrayList` fields

For `ArrayList<T> items`, lookup order is:

```java
public void setItems(ArrayList<T> items); // exact type
public void setItems(List<T> items);      // counterpart
```

For `List<T> items`, the order is reversed:

```java
public void setItems(List<T> items);      // exact type
public void setItems(ArrayList<T> items); // counterpart
```

Generic type arguments are erased during method lookup. The POJO field must still declare a concrete `T` so that its JSON elements can be deserialized.

### Recommended setter standard

```java
private String name;
private boolean active;

public void setName(String name) { this.name = name; }
public void setActive(boolean active) { this.active = active; }
```

Using the exact field type remains the recommended convention. Primitive/wrapper and `List`/`ArrayList` counterparts are supported when an existing model requires them.

## 8. Field visibility and inheritance

All declared fields in the POJO and its superclasses are inspected.

| Field/accessor shape | Serialization | Deserialization |
|---|---|---|
| Public field, no accessor | Read directly | Written directly |
| Private field with public getter/setter | Getter is used | Setter is used |
| Private field without accessor | Omitted | Not populated |
| Final field | Omitted | Not populated |
| Inherited field | Included | Populated |

Static non-final fields are not automatically excluded. Customer POJOs should contain instance data fields only. `transient` alone does not exclude a field; use `@Ignore` when exclusion is required.

## 9. Serialization behavior

For a POJO, the serializer:

1. walks fields declared on the class and its superclasses;
2. skips final and excluded fields;
3. obtains each value through a recognized getter or public field;
4. omits a field when its value is `null`;
5. uses the Java field name as the JSON key;
6. serializes nested POJOs recursively;
7. serializes arrays and `List`/`ArrayList` values as JSON arrays.

### Date-time format

`java.util.Date` is serialized as an ISO-8601 instant in UTC:

```json
"2026-08-20T07:30:00Z"
```

### Cyclic references

The serializer detects an object encountered again along the active object path. It logs the cyclic reference and returns `null` for that repeated object. Because null-valued POJO fields are omitted, a cyclic object property is normally absent from the resulting JSON.

Do not design customer payloads with cyclic object graphs.

## 10. Deserialization behavior

For a POJO, the deserializer:

1. parses the payload as a JSON object;
2. selects a concrete class when polymorphism is configured;
3. invokes its accessible no-argument constructor;
4. walks its fields and inherited fields;
5. ignores unknown JSON keys;
6. converts each known value;
7. calls a recognized setter or writes a public field.

Missing fields retain their constructor or Java default values. JSON null is assigned as Java null to wrapper, string, date, nested POJO, array, and collection fields. JSON null for a primitive field or primitive-array element throws `IllegalArgumentException`.

Invalid numeric, boolean, date, or enum input throws `IllegalArgumentException` with the field or element location and expected type. Boolean input must be a JSON Boolean or a case-insensitive `"true"`/`"false"` string.

For an optional reference field, either omit the property to preserve its initialized value or send JSON null to clear it.

## 11. Transformation annotations

All annotations below target fields and are evaluated at runtime.

### `@Ignore`

Excludes a customer-owned field from both serialization and deserialization.

```java
@Ignore
public String localCacheKey;
```

### `@InternalKey`

Marks framework-owned state. The field is excluded from customer metadata and from normal serialization/deserialization. The Agent populates it through an explicit lifecycle method instead of trusting customer JSON. SDK internals use this for `PollingInfo`, authentication identity, and dynamic lifecycle references; connector developers should not use it as a replacement for `@Ignore`.

`@Ignore` and `@InternalKey` have similar JSON exclusion behavior but different ownership: `@Ignore` belongs to the connector model, while `@InternalKey` is reserved for Agent-managed state.

### `@ReadOnly`

The field is serialized but ignored during deserialization. Use it for output-only values.

```java
@ReadOnly
public String generatedId;
```

### `@WriteOnly`

The field can be deserialized but is excluded from serialization. Use it for input-only secrets or commands.

```java
@WriteOnly
public String password;
```

### `@Mandatory`

During deserialization, a missing annotated field throws `IllegalArgumentException` identifying the POJO and field.

```java
@Mandatory
public String customerId;
```

`@Mandatory` checks key presence, not whether the value is non-null or non-empty. A present key whose value is JSON null satisfies the presence check; it clears a reference field and is rejected for a primitive field.

### `@ToString`

During serialization, converts a supported scalar value to a JSON string with `String.valueOf`.

```java
@ToString
public Long accountId;
```

```json
{"accountId":"10001"}
```

Deserialization does not use `@ToString`; it follows the declared Java field type.

### `@IgnoreIf`

Excludes the annotated field when another field's value matches the configured string.

```java
public String mode;

@IgnoreIf(field = "mode", value = "summary")
public String details;
```

The comparison is case-sensitive and uses `referencedValue.toString()`. If the referenced field is missing, the annotated field is not excluded.

### `@IncludeIf`

Includes the annotated field only when another field's value matches the configured string.

```java
public String mode;

@IncludeIf(field = "mode", value = "detailed")
public String details;
```

The comparison is case-sensitive. If the referenced field does not exist or cannot be read, the annotated field is excluded.

### `@IgnoreOn`

Excludes the annotated field when its own value matches the configured string.

```java
@IgnoreOn("internal")
public String visibility;
```

### `@IncludeOn`

Includes the annotated field only when its own value matches the configured string.

```java
@IncludeOn("public")
public String visibility;
```

All conditional annotations affect serialization only. Reference and annotated fields must be readable through the accessor rules in sections 6 and 8.

## 12. Polymorphic deserialization

`@Polymorphism` is placed on a discriminator field in the declared base class. Its mappings select a concrete subclass from the discriminator's JSON value.

```java
import com.zoho.agent.flow.transformation.annotation.PolymorphicIf;
import com.zoho.agent.flow.transformation.annotation.Polymorphism;

public abstract class Payment {
    @Polymorphism({
        @PolymorphicIf(value = "card", clazz = CardPayment.class),
        @PolymorphicIf(value = "bank", clazz = BankPayment.class)
    })
    public String type;

    public Payment() {}
}

public final class CardPayment extends Payment {
    public String lastFourDigits;
    public CardPayment() {}
}

public final class BankPayment extends Payment {
    public String reference;
    public BankPayment() {}
}
```

```java
Payment payment = JSONDeserializer.convert(payload, Payment.class);
```

The mapped class must be assignable to the declared base class and must have an accessible no-argument constructor. If the discriminator is missing, null, unmatched, or mapped to an incompatible class, the declared class is used. When that declared class is abstract, conversion returns `null`.

Use only one discriminator field in a class hierarchy. The value comparison is case-sensitive.

## 13. Complete example

```java
import com.zoho.agent.flow.transformation.JSONDeserializer;
import com.zoho.agent.flow.transformation.JSONSerializer;
import com.zoho.agent.flow.transformation.annotation.Ignore;
import com.zoho.agent.flow.transformation.annotation.IncludeIf;
import com.zoho.agent.flow.transformation.annotation.Mandatory;
import com.zoho.agent.flow.transformation.annotation.ReadOnly;
import com.zoho.agent.flow.transformation.annotation.WriteOnly;
import java.util.ArrayList;
import java.util.Date;
import org.json.JSONObject;

public final class Contact {
    @Mandatory
    private String id;

    private String name;
    private Boolean active;
    private Date createdTime;
    private ArrayList<String> tags;

    @WriteOnly
    private String accessToken;

    @ReadOnly
    private String status;

    @Ignore
    private String localNote;

    private String view;

    @IncludeIf(field = "view", value = "detailed")
    private String description;

    public Contact() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    public Date getCreatedTime() { return createdTime; }
    public void setCreatedTime(Date createdTime) { this.createdTime = createdTime; }
    public ArrayList<String> getTags() { return tags; }
    public void setTags(ArrayList<String> tags) { this.tags = tags; }
    public String getAccessToken() { return accessToken; }
    public void setAccessToken(String accessToken) { this.accessToken = accessToken; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getLocalNote() { return localNote; }
    public void setLocalNote(String localNote) { this.localNote = localNote; }
    public String getView() { return view; }
    public void setView(String view) { this.view = view; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}

Contact contact = JSONDeserializer.convert(inputJson, Contact.class);
JSONObject output = (JSONObject) JSONSerializer.convert(contact);
```

## 14. Common mistakes

| Symptom | Cause | Fix |
|---|---|---|
| Field metadata is missing or rejected | Unsupported scalar, map, set, arbitrary Java time type, raw collection, or nested generic was declared | Use the supported scalar table and one-dimensional arrays or `List<T>`/`ArrayList<T>` with concrete elements |
| Deserialization cannot instantiate a model | The class or no-argument constructor is inaccessible | Make every deserialized class and its no-arg constructor public |
| A field is never written | It is `final`, or a private field lacks a compatible public setter | Use non-final public fields or standard public getters/setters |
| Boolean property is skipped | Getter/setter naming does not follow the supported `isX`/`getX`/`setX` patterns | Rename accessors to the conventions in sections 6 and 7 |
| An unexpected setter is selected | Multiple compatible setters exist | Provide one exact-type setter and remove ambiguous overloads |
| JSON uses the wrong property name | A label or annotation was expected to rename a field | Use the exact Java field name as the JSON key |
| Primitive conversion fails on null | JSON null was supplied for a primitive field or primitive-array element | Use a wrapper type when null is meaningful, or supply a value |
| Mandatory validation behaves unexpectedly | Missing-key validation was confused with null/empty validation | `@Mandatory` requires presence; validate non-null/non-empty domain rules separately |
| Conditional annotation does not match | Comparison uses different case or text | Use the exact case-sensitive annotation value |
| Serialization silently cuts a branch | The POJO graph contains a cycle | Use an acyclic DTO graph and identifiers for back-references |
| Inherited value is ambiguous | A subclass hides a superclass field with the same name | Use unique field names throughout the hierarchy |
| A transient value is still serialized | Java `transient` was treated as an SDK exclusion rule | Apply `@Ignore` explicitly |

## 15. Customer checklist

- [ ] Every deserialized class is concrete, accessible, and has an accessible no-argument constructor.
- [ ] Every scalar field uses one of the supported Java types in section 4.
- [ ] Every collection field is a `List<T>` or `ArrayList<T>` with a concrete supported element class.
- [ ] Arrays are one-dimensional and use supported scalar or POJO components.
- [ ] Data fields are instance fields and are not final.
- [ ] Private fields have public standard getters and setters.
- [ ] Boolean accessors follow the `active` / `isActive()` / `setActive(...)` convention.
- [ ] Setters use the exact field type when possible; otherwise only a supported primitive/wrapper or `List`/`ArrayList` counterpart is used.
- [ ] JSON null is used only when a reference field should be cleared; primitive fields and primitive-array elements never receive null.
- [ ] Inclusion/exclusion annotations match the intended direction.
- [ ] Conditional fields reference readable fields and use exact case-sensitive values.
- [ ] Polymorphic mappings point to assignable, constructible concrete classes.
- [ ] POJO graphs contain no cycles.
- [ ] JSON keys match Java field names exactly.
