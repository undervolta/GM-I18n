/// @description Languages & Menus

// Store instance IDs
menu_list = [];
btn_list = [];


// Create menu
var inst_layer = layer_get_id("Instances");

for (var i = 0; i < 6; i++) {
	var menu = instance_create_layer(216, 176 + (i * 72), inst_layer, oMenu, {
		num : i + 1,
		key : string($"menu_{i + 1}.title")
	});
	array_push(menu_list, menu);
}


// Create locale/language switcher
var langs = i18n_get_locales_name();

for (var i = 0; i < array_length(langs); i++) {
	var btn = instance_create_layer(room_width - 154, 178 + (i * 108), inst_layer, oBtnLocale, {
		num : i + 1,
		text : langs[i]
	});
	array_push(btn_list, btn);
}


/*from_ui = i18n_create_ref_message("from_ui", "lang")
global.ui_text = i18n_create_ref_message("g.ui_text", "goodbye")
global.ui_text = i18n_create_ref_message("g.ui_text", "menu.start")*/