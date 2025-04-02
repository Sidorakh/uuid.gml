uuid.gml
--

Some helper functions to work with UUID's in your GameMaker applications

## What are UUIDs?
Universally Unique Identifiers (UUID's) are a 128 but label used to identify objects uniquely. While the probability of a UUID being unique is not zero, the chances of a correctly generated UUID being duplicated in the same system is negligible.

## Versions of UUIDs included

### Version 1
Based on a "node" ID (usually derived from the MAC address of the host machine) but can be randomly generated, and a 60-bit timestamp with the epoch set to midnight on the 15th of October, 1582, when the Gregorian calendar was adopted by the majority of Europe. 

Examples (from two separate batches):
```
F1370A68-091A-10ll-BA5F-0FB2177F0707
F1370A69-091A-10ll-BA5F-0FB2177F0707
F1370A6A-091A-10ll-BA5F-0FB2177F0707
  
F1370E50-091A-10ll-9DD6-3B31D373F5C3
F1370E51-091A-10ll-9DD6-3B31D373F5C3
F1370E52-091A-10ll-9DD6-3B31D373F5C3
```



### Version 4
Mostly randomly generated aside from 4 bits reserved to indicate the version and 2 bits to indicate a variant.

Examples (from two separate batches):
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

Examples (from two separate batches):
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
var v4 = generate_uuidv4();
var v7 = generate_uuidv7();
```
