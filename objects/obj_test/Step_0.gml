/// @description 
if (keyboard_check_pressed(ord("1"))) {
    var str = "";
    repeat (10) {
        str += generate_uuidv1() + "\n";
    }
    show_message("Done");
    clipboard_set_text(str);
}

if (keyboard_check_pressed(ord("4"))) {
    var str = "";
    repeat (10) {
        str += generate_uuidv4() + "\n";
    }
    show_message("Done");
    clipboard_set_text(str);
}

if (keyboard_check_pressed(ord("7"))) {
    var str = "";
    repeat (10) {
        str += generate_uuidv7() + "\n";
    }
    show_message("Done");
    clipboard_set_text(str);
}

if (keyboard_check_pressed(ord("D"))) { 
    // parse Discord snowflake
    var snowflake = get_string("Discord Snowflake","262834612932182025");
    var date = parse_discord_snowflake(int64(snowflake));
    show_message(date_datetime_string(js_timestamp_to_delphi(date)));
}
if (keyboard_check_pressed(ord("T"))) { 
    // parse Twitter snowflake
    var snowflake = get_string("Twitter Snowflake","262834612932182025");
    var date = parse_twitter_snowflake(int64(snowflake));
    show_message(date_datetime_string(js_timestamp_to_delphi(date)));
}

if (keyboard_check_pressed(ord("V"))) {
    var timestamp = 1743682075000;
    show_message(generate_discord_snowflake(0,timestamp))
}