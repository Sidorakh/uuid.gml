/// @description 
if (keyboard_check_pressed(vk_space)) {
    var str = "";
    repeat (30000) {
        str += generate_uuidv7() + "\n";
    }
    show_message("Done");
    clipboard_set_text(str);
}