/// @description Insert description here
//show_debug_message(global.i18n);
var hello = i18n_get_messages("hello");
var potion = i18n_get_messages("items.potion", , "ja");
var welcome = i18n_get_messages("welcome", ["GM-I18n", "Dev"]);

var dev = "Developer";
var welcome2 = i18n_get_messages("welcome", {
	name: dev	
}, "ar");

var this_lang = i18n_get_messages("this_lang", {});
var npc3 = i18n_get_messages("dialog.npc_3", {
	name: dev,
	child: ["GM-I18n", "Dev"]
});
var letter = i18n_get_messages("items.letter", {
	child: ["Old", "Adventurer"]
})
var error = i18n_get_messages("error_check", {
	locale: i18n_get_locale(),
	child: {
		error_code: "1.23.456"
	}
})
var error_num = i18n_get_messages("error_num", {
	num: choose(1, 2, 3, 4),
	child: {
		locale: choose("id", "ja", "ar", "cn", "kr"),
		child: {
			error_code: "1.23.456"
		}
	}	
})

show_debug_message($"hello = {hello}")
show_debug_message($"potion = {potion}")
show_debug_message($"welcome = {welcome}")
show_debug_message($"welcome2 = {welcome2}")
show_debug_message($"letter = {letter}")
show_debug_message($"this_lang = {this_lang}")
show_debug_message($"npc3 = {npc3}")
show_debug_message($"error = {error}")
show_debug_message($"error_num = {error_num}")
