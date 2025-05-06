/// @description Global I18n
// Feather ignore GM1041

global.i18n = i18n_create("g.i18n", "en", [
	new I18nLocaleInit("en", "English"),
	new I18nLocaleInit("ja", "Japanese", "~/langs/jp.json"),
	new I18nLocaleInit("ar", "Arabic", ["~/langs/arb1.json", "~/langs/arb2.json"]),
], {
	hashed: false,
	time: [0, 0.2, 0.3]
});

i18n_add_messages("en", {
	lang: "English",
	hello: "Hello world!",
	nested: {
		a: "Test A",
		b: "Test B"
	}
})

i18n_add_locales(["id", "kr", "cn"]);
 
// i18n_add_drawings("en", "preset1", new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, #FFFFFF, 1, 0, 1));
// i18n_add_drawings(["en", "id"], "preset2", new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, , , 1));
/*i18n_add_drawings("en",  ["preset1", "preset2"], [
	new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, #FFFFFF, 1, 0, 1),
	new I18nDrawings(fNotoSansArbSemiBold, fa_center, fa_middle, #000000, 1, 0, 1),
]);*/
i18n_add_drawings(["en", "id"],  ["preset1", "preset2"], [
	new I18nDrawings(fNotoSansMedium, fa_left, fa_middle, #FFFFFF, 1, 0, 1),
	new I18nDrawings(fNotoSansArbSemiBold, fa_center, fa_middle, #000000, 1, 0, 1),
]);


/*hello_text = i18n_create_ref_message("hello_text", "hello")
hello_arr = [
	i18n_create_ref_message("hello_arr.0", "hello"),
	i18n_create_ref_message("hello_arr.1", "nested.a")
]
my_struct = {
	stc: i18n_get_messages(["hello", "lang"]),
	dyn: i18n_create_ref_message("my_struct.dyn", "lang"),
	arr: ["0", "1", i18n_create_ref_message("my_struct.arr.2", "hello")],
	nested: {
		n_dyn: i18n_create_ref_message("my_struct.nested.n_dyn", "hello"),
		n_arr: [i18n_create_ref_message("my_struct.nested.n_arr.0", "goodbye")],
	}
}*/

hello_text = i18n_create_ref_message("hello_text", "hello")
hello_arr = [
	i18n_create_ref_message("hello_arr.0", "hello"),
	i18n_create_ref_message("hello_arr.1", "nested.a")
]
/*global.my_struct = {
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