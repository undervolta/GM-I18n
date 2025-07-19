/// @description Languages & Menus

// Store instance IDs
menu_list = [];
btn_list = [];

page = 1;
version = "v1.0.0";

// Create menu
var inst_layer = layer_get_id("Instances");

for (var i = 0; i < 6; i++) {
	var menu = instance_create_layer(216, 176 + (i * 72), inst_layer, oMenu, {
		ui_id : id,
		num : i + 1,
		key : string($"menu_{i + 1}.title")
	});
	array_push(menu_list, menu);
}

// Create docs button
instance_create_layer(room_width - 154, (os_browser == browser_not_a_browser) ? 80 : 63, inst_layer, oBtnDocs);

// Create locale/language switcher
var locales = i18n_get_locales_code();

for (var i = 0; i < array_length(locales); i++) {
	var btn = instance_create_layer(room_width - 154, 178 + (i * 108), inst_layer, oBtnLocale, {
		ui_id : id,
		num : i + 1,
		locale : locales[i]
	});
	array_push(btn_list, btn);
}


// Create messages with different style
// Issue
bug_1 = i18n_create_ref_message("bug_1", "bug");

// Menu 1 (Translation)
menu_1_head_1 = i18n_get_messages("menu_1.head_1", , "en");
menu_1_desc_1 = i18n_get_messages("menu_1.desc_1", , "en");
menu_1_head_2 = i18n_create_ref_message("menu_1_head_2", "menu_1.head_2");
menu_1_desc_2 = i18n_create_ref_message("menu_1_desc_2", "menu_1.desc_2");

// Menu 2 (Interpolation)
menu_2 = {
	head_1 : i18n_create_ref_message("menu_2.head_1", "menu_2.head_1"),
	desc_1 : i18n_create_ref_message("menu_2.desc_1", "menu_2.desc_1"),
	head_2 : i18n_create_ref_message("menu_2.head_2", "menu_2.head_2"),
	desc_2 : i18n_create_ref_message("menu_2.desc_2", "menu_2.desc_2"),
	head_3 : i18n_create_ref_message("menu_2.head_3", "menu_2.head_3"),
	desc_3 : i18n_create_ref_message("menu_2.desc_3", "menu_2.desc_3")
}

// Menu 3 (Pluralization)
menu_3 = [
	i18n_create_ref_message("menu_3.0", "menu_3.head_1"),
	i18n_create_ref_message("menu_3.1", "menu_3.desc_1"),
	i18n_create_ref_message("menu_3.2", "menu_3.head_2"),
	i18n_create_ref_message("menu_3.3", "menu_3.desc_2")
]

my_val = 0;
menu_3_test = i18n_create_ref_message("menu_3_test", "menu_3.test_1", {
	qty : my_val,
	plural : function (val) {
		var result = (val <= 1) ? val : 2;
		self.qty = val;
		
		return result;
	},
	plural_value : my_val
});

// Menu 4 (Dictionary)
menu_4 = {
	head : i18n_create_ref_message("menu_4.head", "menu_4.head_1"),
	desc : i18n_create_ref_message("menu_4.desc", "menu_4.desc_1"),
	test : i18n_create_ref_message("menu_4.test", "menu_4.test_1", {
		qty : my_val,
		plural : function (val) {
			var result = (val <= 1) ? val : 2;
			self.qty = val;
			
			return result;
		},
		plural_value : my_val
	}),
}

// Menu 5 (Drawing)
global.menu_5 = [
	i18n_create_ref_message("global.menu_5.0", "menu_5.head_1"),
	i18n_create_ref_message("global.menu_5.1", "menu_5.desc_1"),
	i18n_create_ref_message("global.menu_5.2", "menu_5.head_2"),
	i18n_create_ref_message("g.menu_5.3", "menu_5.desc_2"),
	i18n_create_ref_message("g.menu_5.4", "menu_5.head_3"),
	i18n_create_ref_message("g.menu_5.5", "menu_5.desc_3")
]

// Menu 6 (Localized Asset)
global.menu = {
	menu_6 : {
		head_1 : i18n_create_ref_message("global.menu.menu_6.head_1", "menu_6.head_1"),
		desc_1 : i18n_create_ref_message("g.menu.menu_6.desc_1", "menu_6.desc_1"),
		test_1 : i18n_create_ref_message("global.menu.menu_6.test_1", "menu_6.test_1")
	}
};

menu_6_spr = i18n_create_ref_asset("menu_6_spr", {
	en: sSplashEn,
	idn: sSplashId,
	ja: sSplashJa,
	ko: sSplashKo
});

menu_6_snd = i18n_create_ref_asset("menu_6_snd", {
	en: soVoiceEn,
	idn: soVoiceId,
	ja: soVoiceJa,
	ko: soVoiceKo
});

/*from_ui = i18n_create_ref_message("from_ui", "lang")
global.ui_text = i18n_create_ref_message("g.ui_text", "goodbye")
global.ui_text = i18n_create_ref_message("g.ui_text", "menu.start")*/