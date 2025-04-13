
/// @description Gets the current time as the number of milliseconds since the epoch
/// @returns Real
/// // Required for uuid v1, v2, and v6
/// thanks to Meseta (@mesetatron) for this
function js_timestamp_now() {
    var old_timezone = date_get_timezone();
    date_set_timezone(timezone_utc);
    var timestamp = floor((date_current_datetime() - 25569) * 86400 * 1000);
    date_set_timezone(old_timezone);
    return timestamp;
}

function js_timestamp_to_delphi(ms,local_timezone=true) {
    var old_timezone = date_get_timezone();
    if (local_timezone) {
        date_set_timezone(timezone_local);
    } else {
        date_set_timezone(timezone_utc);
    }
    var timestamp = ms / 86400000 + 25569;
    date_set_timezone(old_timezone);
    return timestamp;
    
}

/// @description Generates `num` random bytes to fill an array
/// @arg {Array} arr Array to fill
/// @arg {Real} num Maximum array length
function fill_random_bytes(arr,num) {
    for (var i=array_length(arr);i<num;i++) {
        array_push(arr,irandom_range(0,255));
    }
    return arr;
}

/// @description Batches random numbers for UUID generation
function uuid_random() {
    static length = 256;
    static rnd = fill_random_bytes([],length);
    if (array_length(rnd) < length) {
        fill_random_bytes(rnd,length);
    }
    return rnd;
}

function byte_to_hex(num) {
    var hex = string(ptr(num));
    return string_copy(hex,string_length(hex)-1,2);
}

function hex_to_bytes(hex) {
    var bytes = array_create(string_length(hex)/2,0);
    var idx = 0;
    for (var i=1;i<=string_length(hex);i+=2) {
        var byte = real("0x"+string_copy(hex,i,2));
        bytes[idx++] = byte;
    }
    return bytes;
}

/// @description Converts an array of bytes to a UUID
function stringify_uuid(bytes) {
    //"xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    var uuid = "";
    var index = 0;
    repeat(4) {
        uuid += byte_to_hex(bytes[index++]);
    }
    uuid += "-";
    repeat(2) {
        uuid += byte_to_hex(bytes[index++]);
    }
    uuid += "-";
    repeat(2) {
        uuid += byte_to_hex(bytes[index++]);
    }
    uuid += "-";
    repeat(2) {
        uuid += byte_to_hex(bytes[index++]);
    }
    uuid += "-";
    repeat(6) {
        uuid += byte_to_hex(bytes[index++]);
    }
    
    return uuid;
}



/// @description Generates a UUID v1 (MAC + datetime)
/// The spec states MAC address, but allows for random values
/// if the 48th (multicast) bit of the host address is 1

function generate_uuidv1() {
    static state = {
        node: undefined,
        sequence: 0,
        ms: -infinity,
        ns: 0,
    }
    
    
    // Update timestamp
    //show_message(state);
    var now = js_timestamp_now();
    
    if (now == state.ms) {
        state.ns += 1;
        if (state.ns >= 10000) {
            state.node = undefined;
            state.ns = 0;
        }
    } else if (now > state.ms) {
        state.ns = 0;
    } else {
        // clock went backwards?
        state.node = undefined;
    }
    
    if (state.node == undefined) {
        state.node = [];
        array_copy(state.node,0,uuid_random(),10,6);
        array_delete(uuid_random(),10,6);
        state.node[0] |= 0x01;
        state.sequence = (uuid_random()[8] << 8 | uuid_random()[9]) & 0x3fff;
    }
    state.ms = now;
    
    
    var bytes = array_create(16,0);   // 16 bytes
    var index = 0;
    
    // Gregorian epoch offset
    var ms = state.ms;
    ms += 12219292800000;
    var ns = state.ns;
    
    
    // time-low 
    var time_low = ((ms & 0xfffffff) * 1000 + ns) % 0x100000000;
    
    bytes[index++] = (time_low >> 24) & 0xff;
    bytes[index++] = (time_low >> 16) & 0xff;
    bytes[index++] = (time_low >> 8) & 0xff;
    bytes[index++] = time_low & 0xff;
    
    // time-mid 
    var time_mid = ((ms / 0x100000000) & 0xfffffff);
    bytes[index++] = (time_mid >> 8) & 0xff;
    bytes[index++] = time_mid & 0xff;
    
    
    // time-high & version
    bytes[index++] = ((time_mid >> 24) & 0xf) | 0x10;
    bytes[index++] = ((time_mid >> 16)) & 0xff;
    
    
    // sequence high & variant
    bytes[index++] = (state.sequence >> 8) | 0x80;
    
    // sequence low
    bytes[index++] = (state.sequence) & 0xff;
    
    array_copy(bytes,index,state.node,0,6);
    
    return stringify_uuid(bytes);
    
    
    
}

/// @description Generates a UUIDv3 (namespaced/MD5)
/// @argument {String} value UUID value
/// @argument {String | Real} namespace Namespace ID or Namespace UUID
/// @return {String} a namespaced UUIDv5
/// 
function generate_uuidv3(value,namespace) {
    return generate_namespaced_uuid(0x30,value,namespace);
}

/// @description Returns a UUID v4 (mostly random)
/// @returns {String}

function generate_uuidv4(seed=undefined) {
    var bytes = array_create(16);
    array_copy(bytes,0,uuid_random(),0,16);
    array_delete(uuid_random(),0,16);
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    return stringify_uuid(bytes);
}

/// @description Generates a UUIDv5 (namespaced/SHA1)
/// @argument {String} value UUID value
/// @argument {String | Real} namespace Namespace ID or Namespace UUID
/// @return {String} a namespaced UUIDv5
function generate_uuidv5(value,namespace) {
    return generate_namespaced_uuid(0x50,value,namespace);
}

enum UUID_NAMESPACE {
    DNS,
    URL,
    OID,
    X500
}
/// @description Internal function; generates either a UUIDv3 or 5 based on the version parameter (either 0x30 or 0x50)
/// @argument {Real} version UUID version byte
/// @argument {String} value UUID value
/// @argument {String | Real} namespace Namespace ID or UUID
/// @returns {String} a UUID v3 or v5
function generate_namespaced_uuid(version,value,namespace) {
    static namespace_dns =  [107, 167, 184, 16, 157, 173, 17, 209, 128, 180, 0, 192, 79, 212, 48, 200];
    static namespace_url =  [107, 167, 184, 17, 157, 173, 17, 209, 128, 180, 0, 192, 79, 212, 48, 200];
    static namespace_oid =  [107, 167, 184, 18, 157, 173, 17, 209, 128, 180, 0, 192, 79, 212, 48, 200];
    static namespace_x500 = [107, 167, 184, 20, 157, 173, 17, 209, 128, 180, 0, 192, 79, 212, 48, 200];
    static buff = buffer_create(array_length(namespace_dns),buffer_grow,1);
    buffer_seek(buff,buffer_seek_start,0);
    
    var arr = namespace_dns;
    if (is_int64(namespace)) {
        if (namespace == UUID_NAMESPACE.DNS) {
            arr = namespace_dns;
        } else if (namespace == UUID_NAMESPACE.URL) {
            arr = namespace_url;
        } else if (namespace == UUID_NAMESPACE.OID) {
            arr = namespace_oid;
        } else if (namespace == UUID_NAMESPACE.X500) {
            arr = namespace_x500;
        }
    } else {
        arr = hex_to_bytes(string_replace_all(namespace,"-",""));
    }
    
    for (var i=0;i<array_length(arr);i++) {
        buffer_write(buff,buffer_u8,arr[i]);
    }
    buffer_write(buff,buffer_text,value);
    
    var hash = "";
    if (version == 0x30) {
        hash = buffer_md5(buff,0,buffer_tell(buff));
    } else {
        hash = buffer_sha1(buff,0,buffer_tell(buff));
    }
    var bytes = hex_to_bytes(hash);
    bytes[6] = (bytes[6] & 0x0f) | version;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    return stringify_uuid(bytes);
    
    
    
}

//function generate_uuidv6() {
    //
//}


/// @description Returns a UUID v7 (timestamp + random bytes)
/// @return {String} a UUID string
function generate_uuidv7() {
    static state = {
        ms: -infinity,
        sequence: 0,
    }
    
    var now = js_timestamp_now();
    
    
    var rnd = array_create(16,0);
    array_copy(rnd,0,uuid_random(),0,16);
    array_delete(uuid_random(),0,16);
    
    if (now > state.ms) {
        state.sequence = (rnd[6] << 23) | (rnd[7] << 16) | (rnd[8] << 8) | (rnd[9]);
        state.ms = now;
    } else {
        state.sequence = (state.sequence + 1 ) | 0;
        if (state.sequence == 0) {
            state.ms += 1;
        }
    }
    
    
    var bytes = array_create(16,0);
    var index = 0;
    
    
    // timestamp bytes
    bytes[index++] = (state.ms / 0x10000000000) & 0xff;
    bytes[index++] = (state.ms / 0x100000000) & 0xff;
    bytes[index++] = (state.ms / 0x1000000) & 0xff;
    bytes[index++] = (state.ms / 0x10000) & 0xff;
    bytes[index++] = (state.ms / 0x100) & 0xff;
    bytes[index++] = (state.ms & 0xff);
    
    
    // version / sequence 28-31 (4 bits)
    bytes[index++]= 0x70 | ((state.sequence >> 28) & 0x0f);
    
    // sequence 20-27 (8 bits)
    bytes[index++] = (state.sequence >> 20) & 0xff;
    
    // variant / sequence 14-19 (6 bits)
    bytes[index++] = 0x80 | ((state.sequence >> 14) & 0x3f);
    
    
    // sequence 6-13 (8 bits)
    bytes[index++] = (state.sequence >> 6) & 0xf
    
    // sequence 0-5 | random
    bytes[index++] = ((state.sequence << 2) & 0xff) | (rnd[10] & 0x03)
    
    // random bytes
    bytes[index++] = rnd[11];
    bytes[index++] = rnd[12];
    bytes[index++] = rnd[13];
    bytes[index++] = rnd[14];
    bytes[index++] = rnd[15];
    
    return stringify_uuid(bytes);
}


function uuid_nil() {
    static uuid = "00000000-0000-0000-0000-000000000000";
    return uuid;
}

function uuid_max() {
    static uuid = "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF";
}
