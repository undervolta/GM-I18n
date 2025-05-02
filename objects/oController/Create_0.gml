/// @description Global I18n

global.i18n = i18n_create("g.i18n", "en", [
	new I18nLocaleInit("en", "English"),
	new I18nLocaleInit("jp", "Japanese", "~/langs/jp.json"),
	new I18nLocaleInit("arb", "Arabic", ["~/langs/arb1.json", "~/langs/arb2.json"]),
], {
	hashed: false		
});

