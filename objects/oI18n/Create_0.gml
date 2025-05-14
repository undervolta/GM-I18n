/// @description Global I18n

// Initialize i18n
global.i18n = i18n_create("g.i18n", "en", [
	new I18nLocaleInit("en", "English", "~/langs/en.json"),
	new I18nLocaleInit("ja", "日本語", "~/langs/ja.json"),
	new I18nLocaleInit("ar", "عربى", ["~/langs/ar1.json", "~/langs/ar2.json"]),
], {
	hashed: false,
	time: [0, 0.5, 0.2, 0.3]
});



/*i18n_add_messages("en", {
	lang: "English",
	this_lang: "[[lang]] is currently in use. [[hello]]",
	hello: "Hello world!",
	goodbye: "Goodbye world!",
	welcome: "Welcome to {0}, {1}!",
	cond: "Noooo! | Yesssss!",
	items: {
		sword: "Sword",
		shield: "Shield",
		potion: "Potion",
		letter: "Message:\n'[[dialog.npc_4]]'",
		sp_sword: "{trait} Sword",
		sp_shield: "{trait} Shield",
	},
	dialog: {
		npc_1: "Help me, I'm trapped!",
		npc_2: "I'm being held captive by a monster. Please save me!",
		npc_3: "Hello, {name}! [[welcome]]",
		npc_4: "He said, \"Welcome to our {0} village, {1}! That's all, now save my friend.\"",
		npc_5: "Thanks! | Thank you!",
		npc_6: "Do you want this [[items.sp_sword]] and [[items.sp_shield]]?"
	},
	menu: {
		start: "Start Game",
		options: "Options"
	},
	error_num: "${num}. [[error_check]]",
	error_check: "I18n - lang {locale} - [[error_message]]",
	error_message: "An error occurred: {error_code}"
})

i18n_add_locales(["id", "kr", "cn"]);*/
 
// i18n_add_drawings("en", "preset1", new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, #FFFFFF, 1, 0, 1));
// i18n_add_drawings(["en", "id"], "preset2", new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, , , 1));
/*i18n_add_drawings("en",  ["preset1", "preset2"], [
	new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, #FFFFFF, 1, 0, 1),
	new I18nDrawings(fNotoSansArbSemiBold, fa_center, fa_middle, #000000, 1, 0, 1),
]);*/
/*i18n_add_drawings(["en", "id"],  ["preset1", "preset2"], [
	new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, #FFFFFF, 1, 0, 1),
	new I18nDrawings(fNotoSansArbSemiBold, fa_center, fa_middle, #000000, 1, 0, 1),
]);*/

/*i18n_add_dictionaries("en", [
	["1", "剣"],
	["Num", "日本語"]
])*/

/*hello_text = i18n_create_ref_message("hello_text", "hello")
hello_arr = [
	i18n_create_ref_message("hello_arr.0", "goodbye"),
	i18n_create_ref_message("hello_arr.1", "items.sword")
]
global.my_struct = {
	stc: i18n_get_messages(["hello", "lang"]),
	dyn: i18n_create_ref_message("g.my_struct.dyn", "lang"),
	arr: ["0", "1", i18n_create_ref_message("global.my_struct.arr.2", "hello")],
	nested: {
		n_dyn: i18n_create_ref_message("global.my_struct.nested.n_dyn", "hello"),
		n_arr: [i18n_create_ref_message("g.my_struct.nested.n_arr.0", "goodbye")],
	}
}*/

/*show_debug_message($"hello_text = {hello_text}")
show_debug_message($"refs = {global.i18n.refs}")*/

/*ref_welcome = i18n_create_ref_message("ref_welcome", "welcome", [
	"GM-I18n", "Dev"
])
ref_text = i18n_create_ref_message("ref_text", "dialog.npc_3", {
	name: "Dev"	
})
ref_arr = [
	i18n_create_ref_message("ref_arr.0", "hello"),
	i18n_create_ref_message("ref_arr.1", "goodbye"),
	i18n_create_ref_message("ref_arr.2", "dialog.npc_5", 0)
]
ref_npc_5 = i18n_create_ref_message("ref_npc_5", "dialog.npc_5", 0);
ref_npc_6 = i18n_create_ref_message("ref_npc_6", "dialog.npc_6", {
	child: {
		trait: "Broken"
	},
	child_items_sp_sword: {
		trait: "Legendary"
	},
});

global.ref_struct = {
	dyn: i18n_create_ref_message("g.ref_struct.dyn", "lang"),
	arr: ["0", "1", i18n_create_ref_message("global.ref_struct.arr.2", "this_lang", {})],
	nested: {
		n_dyn: i18n_create_ref_message("global.ref_struct.nested.n_dyn", "error_num", {
			num: 1,
			child: {
				locale: choose("id", "ja", "ar", "cn", "kr"),
				child: {
					error_code: "1.23.456"
				}
			}	
		}),
		n_arr: [i18n_create_ref_message("g.ref_struct.nested.n_arr.0", "items.letter", {
			child: ["Old", "Adventurer"]	
		})],
	}
}*/