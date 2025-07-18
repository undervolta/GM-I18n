/// @description Global I18n

// Initialize i18n
global.i18n = i18n_create("g.i18n", "en", [
	new I18nLocaleInit("en", "English", "~/langs/en.json"),
	new I18nLocaleInit("idn", "Bhs Indonesia", "~/langs/id.json"),
	new I18nLocaleInit("ja", "日本語", "~/langs/ja.json"),
	new I18nLocaleInit("ko", "한국어", "~/langs/ko.json") 
	//new I18nLocaleInit("ar", "عربى", ["~/langs/ar1.json", "~/langs/ar2.json"]),
], {
	debug: false,
	hashed: true,
	cached: true,
	time: 0.5
});

// Add hardcoded messages to en locale. Great for mandatory initial messages.
i18n_add_messages("en", {
	lang: "English",
	title: "GM-I18n Demo",
	bug: "There are some issues with HTML5 platform",
	plural_guide: "Press arrow up or down to change the plural value",
	menu_1: {
		title: "Translation",
		head_1: "Static Text Translation",
		desc_1: "This sentence is static. It will be translated to the selected locale. Changing the locale won't affect this sentence.",
		head_2: "Dynamic Text Translation",
		desc_2: "This sentence is dynamic. It will be translated to the selected locale by default. Changing the locale will affect this sentence. If the passed key message doesn't exist in the selected locale, it will use the default locale instead.",
	},
	menu_2: {
		title: "Interpolation",
	},
	menu_3: {
		title: "Pluralization",
	},
	menu_4: {
		title: "Dictionary",
	},
	menu_5: {
		title: "Drawing",
	},
	menu_6: {
		title: "Localized Assets"
	}
});


// Create non-latin fonts
if (os_browser == browser_not_a_browser) {
	global.font_ja = font_add(working_directory + "fonts/NotoSansJP-Medium.ttf", 32, 0, 0, 32, 127);
	global.font_ko = font_add(working_directory + "fonts/NotoSansKR-Medium.ttf", 32, 0, 0, 32, 127);
} else {
	// For HTML5
	global.font_ja = font_add("fonts/NotoSansJP-Medium.ttf", 32, 0, 0, 32, 127);
	global.font_ko = font_add("fonts/NotoSansKR-Medium.ttf", 32, 0, 0, 32, 127);
}

refreshed = false;
var fonts = [fNotoSansMedium, fNotoSansSemiBold]

// Add drawing presets for each locale
i18n_add_drawings(["en", "idn"], ["title", "button", "header", "desc"], [
	new I18nDrawings("fNotoSansSemiBold", fa_left, fa_middle, #FFFFFF, 1.14, 0, 1),
	new I18nDrawings("fNotoSansSemiBold", fa_center, fa_middle, #000000, 0.65, 0, 1),
	new I18nDrawings("fNotoSansSemiBold", fa_left, fa_middle, #FFFFFF, 0.65, 0, 1),
	new I18nDrawings("fNotoSansMedium", fa_left, fa_top, #CCCCCC, 0.49, 0, 1, -1, 1198)
]);

i18n_add_drawings("ja", ["button", "header", "desc"], [
	new I18nDrawings(global.font_ja, fa_center, fa_middle, #000000, 0.65, 0, 1),
	new I18nDrawings(global.font_ja, fa_left, fa_middle, #FFFFFF, 0.65, 0, 1),
	new I18nDrawings(global.font_ja, fa_left, fa_top, #CCCCCC, 0.49, 0, 1, -1, 1198)
]);

i18n_add_drawings("ko", ["button", "header", "desc"], [
	new I18nDrawings(global.font_ko, fa_center, fa_middle, #000000, 0.65, 0, 1),
	new I18nDrawings(global.font_ko, fa_left, fa_middle, #FFFFFF, 0.65, 0, 1),
	new I18nDrawings(global.font_ko, fa_left, fa_top, #CCCCCC, 0.49, 0, 1, -1, 1198)
]);

// Refresh the drawing preset if it's running on browser
if (os_browser != browser_not_a_browser) {
	//alarm_set(0, game_get_speed(gamespeed_fps) * 2);	// delay in seconds
}

// Add dictionaries
i18n_add_dictionaries("en", [
	["1", "one"],
	["2", "two"],
	["3", "three"],
	["4", "four"],
	["5", "five"],
	["6", "six"],
	["7", "seven"],
	["8", "eight"],
	["9", "nine"],
	["10", "ten"]
]);

i18n_add_dictionaries("idn", [
	["1", "satu"],
	["2", "dua"],
	["3", "tiga"],
	["4", "empat"],
	["5", "lima"],
	["6", "enam"],
	["7", "tujuh"],
	["8", "delapan"],
	["9", "sembilan"],
	["10", "sepuluh"]
]);

i18n_add_dictionaries("ja", [
	["1", "一"],
	["2", "二"],
	["3", "三"],
	["4", "四"],
	["5", "五"],
	["6", "六"],
	["7", "七"],
	["8", "八"],
	["9", "九"],
	["10", "十"]
]);

i18n_add_dictionaries("ko", [
	["1", "하나"],
	["2", "둘"],
	["3", "셋"],
	["4", "넷"],
	["5", "다섯"],
	["6", "여섯"],
	["7", "일곱"],
	["8", "여덟"],
	["9", "아홉"],
	["10", "십"]
]);

i18n_add_dictionaries("en", [
    ["item.map", "Village Map"],
    ["apple_box", "box of apples"],
	["Will of the Adventurer", "A skill that increases the user's attack power by 10% for 30 seconds"],
]);

i18n_add_dictionaries("idn", [
    ["ticket", "tiket"],
	["apple", "apel"],
    ["item.map", "Peta Desa"],
    ["apple_box", "kotak apel"],
	["Will of the Adventurer", "Sebuah skill yang meningkatkan kekuatan serangan pengguna sebesar 10% selama 30 detik"]
]);


/*i18n_add_drawings("ar", ["button", "header", "desc"], [
	new I18nDrawings(font_add(working_directory + "fonts/NotoSansArabic-SemiBold.ttf", 32, 0, 0, 32, 127), fa_center, fa_middle, #000000, 0.65, 0, 1),
	new I18nDrawings(fNotoSansARSemiBold, fa_left, fa_middle, #FFFFFF, 0.65, 0, 1),
	new I18nDrawings(fNotoSansARMedium, fa_left, fa_top, #CCCCCC, 0.49, 0, 1, -1, 410)
]);*/


i18n_add_messages("en", {
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
	error_message: "An error occurred: {error_code}",
	
	welcome: "Welcome to {village} village, {name}! [[welcome_2]]",
    welcome_2: "Hope you enjoy your stay in this village!",
    shop: {
        template_1: "Are you sure you want to buy this {count} {item}",
        cant_buy: "You can't afford this {name}.",
        buyable: "[[shop.template_1]]? | [[shop.template_1]]{suffix}?",
        confirm: "[[shop.cant_buy]] | [[shop.buyable]]",
        confirm_2: "[[shop.cant_buy]] | [[shop.buyable]] [[shop.confirm_resc]]",
        confirm_resc: "Your {0} is {1}."
    },
    item: {
        owned: "You already have {count} {item}.",
        not_owned: "You don't have this {item}. [[shop.confirm]]",
        apple: "Apple",
        apple_trait: "{adj} Apple",
        bamboo: "Bamboo",
        bamboo_trait: "{adj} Bamboo",
        potion: "Potion",
        potion_trait: "{adj} Potion",
        chicken: "Chicken",
        chicken_trait: "{0} Chicken",
        duck: "Duck",
        duck_trait: "{0} Duck"
    },
 	dialog: {
        npc_1: "Do you have 20 [[item.apple]]s? How about trading them with me for 5 [[item.bamboo]]s?",
        npc_2: "Welcome to my shop! Take a look at this [[item.apple_trait]], [[item.bamboo_trait]], and [[item.potion_trait]]. Do you want to buy any of them?",
        npc_3: "Ah, how about [[item.chicken_trait]] and [[item.duck_trait]] then?",
		npc_4: {
            num_1: "Is this your first time to visit our village? [[dialog.npc_4.num_2]]",
            num_2: "Huh, really?\nThen, [[welcome]]",
        },
		npc_5: "Sorry, your {resc}s is not enough to buy this [[item.bamboo_trait]]. | Do you want to buy [[item.bamboo_trait]] for {plural_value} {resc}s, sir? I'll add a [[item.apple_trait]] for you as a bonus!"
    },

	greet: "Hello, {name}!",
    ask: "Do you want this ${item}?",
	dialog: {
        npc_1: "Please ask ${chief_name} for help.",
        npc_2: "Is it your first time here, {name}? Let me show you around. Here's a ${item} for you.",
        npc_3: "You need at least {count} ${item}{suffix} to enter the cave. | Spend {plural_value} ${item}{suffix} to enter the cave?",
        npc_4: "My brother was trapped in the cave. I need to find him. Can you help me? [[dialog.npc_5]]",
        npc_5: "I'll reward you with a ${sp_item} if you can find him.",
		npc_6: "Take this \"{item}\" skill book. It's ${item}."
    }
})

i18n_add_messages("idn", {
	greet: "Halo, {name}!",
    ask: "Apakah kamu ingin {item} ini?",
    ask_2: "Apakah kamu ingin ${item} ini?",
    dialog: {
        npc_1: "Harap tanyakan bantuan kepada ${chief_name}.",
        npc_2: "Ini pertama kalinya kamu di sini, {name}? Mari saya tunjukkan sekeliling. Ini ${item} untukmu.",
        npc_3: "Kamu butuh setidaknya {count} ${item} untuk masuk ke gua. | Habiskan {plural_value} ${item} untuk masuk ke gua?",
        npc_4: "Saudaraku terjebak di dalam gua. Aku perlu menemukannya. Bisakah kamu membantuku? [[dialog.npc_5]]",
        npc_5: "Aku akan memberimu ${sp_item} jika kamu bisa menemukannya.",
		npc_6: "Ambil buku keterampilan \"{item}\" ini. Ini ${item}."
    }
})

player_name = "John";


npc1 = i18n_create_ref_message("npc1", "dialog.npc_1", {
	chief_name : "Budi"
})

my_struct = {
	npc2 : i18n_create_ref_message("my_struct.npc2", "dialog.npc_2", {
		name : player_name,
		item : "item.map"
	})
}

global.npc3 = i18n_create_ref_message("global.npc3", "dialog.npc_3", {
	plural : function(val) {
		return (val >= 3) ? 1 : 0;
	},
	plural_value : 0,

	item : "ticket",
	count : 3,
	suffix : "s"
})

global.gb_struct = {
	npc4 : i18n_create_ref_message("g.gb_struct.npc4", "dialog.npc_4", {
		child : {
			sp_item : "apple_box"
		}
	}),
	arr : [
		i18n_create_ref_message("global.gb_struct.arr.0", "dialog.npc_6", {
			item : "Will of the Adventurer"
		})
	]
}

//i18n_add_locales(["id", "kr", "cn"]);
 
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