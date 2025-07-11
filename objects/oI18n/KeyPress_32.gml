/// @description Testing
//show_debug_message(global.i18n);
/*var hello = i18n_get_messages("hello", , , , true);
var potion = i18n_get_messages("items.potion", , "en", true);
var welcome = i18n_get_messages("welcome", ["GM-I18n", "Dev"], , , true);

var dev = "Developer";
var welcome2 = i18n_get_messages("welcome", {
	name: dev	
}, "idn", , true);

var this_lang = i18n_get_messages("this_lang", {}, , , true);
/*var npc3 = i18n_get_messages("dialog.npc_3", {
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
	num: "Num 1",
	child: {
		locale: choose("id", "ja", "ar", "cn", "kr"),
		child: {
			error_code: "1.23.456"
		}
	}	
})
var cond = i18n_get_messages("cond", {
	plural: function(x) {
		var result = (x < 5) ? 0 : 1;
		return result;
	},
	plural_value: 5
});*/

/*show_debug_message($"hello = {hello}")
show_debug_message($"potion = {potion}")
show_debug_message($"welcome = {welcome}")
show_debug_message($"welcome2 = {welcome2}")
show_debug_message($"letter = {letter}")
show_debug_message($"this_lang = {this_lang}")
show_debug_message($"npc3 = {npc3}")
show_debug_message($"error = {error}")
show_debug_message($"error_num = {error_num}")
show_debug_message($"cond = {cond}")*/
//show_debug_message($"ref_npc_6 = {ref_npc_6}")

/*show_debug_message($"data = {global.i18n.refs.messages.data}")
show_debug_message($"ref_npc_5 old = {ref_npc_5}")

i18n_update_plurals("ref_npc_5", 1)
i18n_update_refs()
show_debug_message($"ref_npc_5 new = {ref_npc_5}")*/

// nested message data
/*var welcome = i18n_get_messages("welcome", {
	village: "Sukamakan",
	name: "Bro"
});

var npc1 = i18n_get_messages("dialog.npc_1", {});
var npc2 = i18n_get_messages("dialog.npc_2", {
	child_item_apple_trait: {
		adj: "Bad"
	},
	child: {
		adj: "Shiny"
	}
});

var npc3 = i18n_get_messages("dialog.npc_3", {
	child: ["Fresh"]
});

var buyable = i18n_get_messages("shop.buyable", {
	plural: function(x) {
		return (x == 0) ? 0 : 1;
	},
	plural_value: 10,
	suffix: "s",
	
	child: {
		count: 10,
		item: i18n_get_messages("item.apple")
	}
});

var confirm2 = i18n_get_messages("shop.confirm_2", {
	plural: function(x) {
		return (x == 0) ? 0 : 1;
	},
	plural_value: 10,
	
	child: {
		name: "apple",
		
		plural: function(x) {
			return (x == 0) ? 0 : 1;
		},
		plural_value: 10,
		suffix: "s",
		
		child: {
			count: 10,
			item: "apple"
		}
	}
});

var not_owned = i18n_get_messages("item.not_owned", {
	item: "Shiny Bamboo",
	
	child: {
		plural: function(x) {
			return (x == 0) ? 0 : 1;
		},
		plural_value: 10,
		
		child: {
			name: "Shiny Bamboo",
			plural: function(x) {
				return (x == 0) ? 0 : 1;
			},
			plural_value: 10,
			suffix: "s",
			
			child: {
				count: 10,
				item: "Shiny Bamboo"
			}
		}
	}
});

var npc4 = i18n_get_messages("dialog.npc_4.num_1", {
	child: {
		child_welcome : {
			village: "Sukamakan",
			name: "John"
		}
	}
});

var npc5  = i18n_get_messages("dialog.npc_5", {
	plural: function(x) {
		return (x > 500) ? 1 : 0;
	},
	plural_value: 400,
	
	resc: "Copper Coin",
	
	child_item_bamboo_trait: {
		adj: "Premium"
	},
	
	child: {
		adj: "Legendary"
	}
});

show_debug_message(welcome);
show_debug_message(npc1);
show_debug_message(npc2);
show_debug_message(npc3);
show_debug_message(buyable);
show_debug_message(confirm2);
show_debug_message(not_owned);
show_debug_message(npc4);
show_debug_message(npc5);*/

/*i18n_update_plurals("not_owned.child", 0)
show_debug_message(not_owned);*/

// dictionaries
/*var ask1 = i18n_get_messages("ask", {
	item: "apple"
}, "idn");

var ask2 = i18n_get_messages("ask_2", {
	item: "apple"
}, "idn");

show_debug_message(ask1);
show_debug_message(ask2);
show_debug_message(npc1);
show_debug_message(my_struct.npc2);

i18n_update_plurals("global.npc3", oUI.my_val, true);
show_debug_message(global.npc3);
show_debug_message(global.gb_struct.npc4);
show_debug_message(global.gb_struct.arr[0]);
*/
var choose_test = i18n_choose({
	en: "Test",
	idn: "Tes"	
}, , false)
show_debug_message($"choose = {choose_test}")

show_debug_message($"cache.ids = {global.i18n.cache.ids}")
show_debug_message($"title cache id = {i18n_get_cache_id("title", , "en")}")
show_debug_message($"npc1 variable cache id = {i18n_get_cache_id_from_ref("npc1", instance_id_get(self))}")

i18n_update_cache(i18n_get_cache_id("title", , "en"), "Cihuy!")
