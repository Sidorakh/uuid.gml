uuid.gml
--

Some helper functions to work with UUIDs and Snowflakes in your GameMaker applications

## installation / updating
1. If updating, delete the `uuid.gml` folder in your project
2. Download the latest .yymps file from [Releases](https://github.com/Sidorakh/uuid.gml/releases)
3. Drag the .yymps file into your GameMaker IDE and import the scripts in the `uuid.gml` folder
4. You're done


## What are UUIDs?
Universally Unique Identifiers (UUID's) are a 128 but label used to identify objects uniquely. While the probability of a UUID being unique is not zero, the chances of a correctly generated UUID being duplicated in the same system is negligible.

## Versions of UUIDs included

### Version 1
Based on a "node" ID (usually derived from the MAC address of the host machine) but can be randomly generated, and a 60-bit timestamp with the epoch set to midnight on the 15th of October, 1582, when the Gregorian calendar was adopted by the majority of Europe. 

Example:
```js
repeat (6) {
    show_debug_message(generate_uuidv1());
}
```
Output:
```
F1370A68-091A-10ll-BA5F-0FB2177F0707
F1370A69-091A-10ll-BA5F-0FB2177F0707
F1370A6A-091A-10ll-BA5F-0FB2177F0707
F1370E50-091A-10ll-9DD6-3B31D373F5C3
F1370E51-091A-10ll-9DD6-3B31D373F5C3
F1370E52-091A-10ll-9DD6-3B31D373F5C3
```


### Versions 3 and 5
Generated from a namespace and string, concatenated and hashed. Version 3 uses the MD5 hash while version 5 uses a truncated SHA1 hash.
Namespaces are all UUID strings, default values are for DNS, URL, OID, and X500. `generate_uuidv3` and `generate_uuidv5` both take the same parameters, as below

Parameters: 
| Parameter | Type | Description |
| - | - | - |
| value | `String` | The value for the UUID to be derived from |
| namespace | `String` \| `Enum.UUID_NAMESPACE` | The namespace ID enum element (as below) or UUID to derive the final UUID from |


`Enum.UUID_NAMESPACE`:
| Element | Value |
| - | - |
| DNS | Represents a DNS value |
| URL | Represents a URL value |
| OID | Represents an OID value |
| X500 | Represents an X500 value |

Example:
```js
var uuidv3 = generate_uuidv3("a-value",UUID_NAMESPACE.DNS);
var uuidv5 = generate_uuidv5("another-value",UUID_NAMESPACE.X500);
```



### Version 4
Mostly randomly generated aside from 4 bits reserved to indicate the version and 2 bits to indicate a variant.

Example:
```js
repeat (6) {
    show_debug_message(generate_uuidv4());
}
```
Output:
```
E2C7A232-26D5-4185-802F-2930E62751CE
75ll2033-4E7D-4FDC-A681-5838434DCBAE
49FB72F8-DD4A-4E46-837E-D2210F3A8564
C1D17575-D63E-4C7F-A00A-D9E1B36F01F9
6ADBC645-C14F-4294-8360-25CD43F3E2D0
6DE27BF9-F6E2-4FE8-A35D-81B32BEBF1F9
```



### Version 7
Designed for keys in distributed systems or other high load databases, combines a timestamp with a random value

Example:
```js
repeat (6) {
    show_debug_message(generate_uuidv7());
}
```
Output: 
```
FEFEA770-3A1D-71F9-A60C-C6E13E3E5EDC
FEFEA770-3A1D-71F9-A60C-C88F3DA07FFA
FEFEA770-3A1D-71F9-A60C-CF50E5205674
FEFEA770-3A1D-71F9-A60D-0B6A95A2C82D
FEFEA770-3A1D-71F9-A60D-0CF06B6E3B9A
FEFEA770-3A1D-71F9-A60D-12036F8E3073
```


## Usage

To generate a UUID

```gml
var v1 = generate_uuidv1();
var v3_dns = generate_uuidv3("value",UUID_NAMESPACE.DNS);
var v3_cust = generate_uuidv3("value","49FB72F8-DD4A-4E46-837E-D2210F3A8564");
var v4 = generate_uuidv4();
var v5_x500 = generate_uuidv5("value",UUID_NAMESPACE.X500);
var v5_cust = generate_uuidv5("value","49FB72F8-DD4A-4E46-837E-D2210F3A8564");
var v7 = generate_uuidv7();
```
## What are Snowflakes?

Snowflakes are 64-bit ID's based on a timestamp with a custom epoch, a machine ID, and a sequence number.

### `create_snowflake_parser`
This function returns a function that parses specific types of Snowflakes and returns a datetime in the format of milliseconds since 1st January, 1970 (Unix epoch, in milliseconds). For example, this code creates a parser for Twitter-style snowflakes and stores it in a static variable:
```js
function twitter_snowflake_get_time(snowflake) {
    static epoch = 1288834974657;
    static parser = create_snowflake_parser(epoch);
    return parser(snowflake);
}
```

### `create_snowflake_generator`
This function returns a generator that creates snowflake IDs. For example, this code creates a custom generator for Twitter-style snowflakes and stores it in a static variable:
```js
function generate_twitter_snowflake(node_id=0,timestamp=undefined) {
    static epoch = 1288834974657;
    static generator = create_snowflake_generator(epoch);
    return generator(node_id,timestamp);
}
```
And to generate a snowflake with the generator function defined above (assume `js_timestammp_now` returns the current time as milliseconds from Jan 1st, 1970):
```js
var snowflake = generate_twitter_snowflake(node_id,js_timestamp_now());

```

