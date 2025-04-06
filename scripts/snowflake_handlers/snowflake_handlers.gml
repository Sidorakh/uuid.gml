
function create_snowflake_parser(epoch) {
    var struct = {epoch};
    return method(struct,function(snowflake){
        var ms = snowflake >> 22;
        return ms + epoch;
    });
}


function create_snowflake_generator(epoch, max_nodes=128) {
    var struct = {epoch,nodes: array_create(max_nodes), ms: -infinity};
    
    return method(struct,function(node_id=0,timestamp=undefined){
        timestamp ??= js_timestamp_now();
        timestamp -= epoch;
        if (ms < timestamp) {
            ms = timestamp;
            nodes[node_id] = 0;
        }
        var snowflake = timestamp << 22;
        
        var node_seq = (node_id << 10) | (nodes[node_id]);
        snowflake = snowflake | node_seq;
        nodes[node_id] += 1;
        return snowflake;
    })
}

function discord_snowflake_get_time(snowflake) {
    static epoch = 1420070400000;
    static parser = create_snowflake_parser(epoch)
    return parser(snowflake);
}

function discord_snowflake_get_metadata(snowflake) {
    var worker_id = (snowflake & 0x3E0000) >> 17;
    var process_id = (snowflake & 0x1F000) > 12;
    var increment = (snowflake & 0xFFF);
    return [worker_id,process_id,increment];
}

function twitter_snowflake_get_time(snowflake) {
    static epoch = 1288834974657;
    static parser = create_snowflake_parser(epoch);
    return parser(snowflake);
}

function twitter_snowflake_get_metadata(snowflake) {
    var node_id = (snowflake & 0x3FFFFF) >> 12;
    var increment = (snowflake & 0xFFF);
    return [node_id,snowflake];
}

function generate_discord_snowflake(node_id=0,timestamp=undefined) {
    static epoch = 1420070400000;
    static generator = create_snowflake_generator(epoch);
    return generator(node_id,timestamp);
}

function generate_twitter_snowflake(node_id=0,timestamp=undefined) {
    static epoch = 1288834974657;
    static generator = create_snowflake_generator(epoch);
    return generator(node_id,timestamp);
}