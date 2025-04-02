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