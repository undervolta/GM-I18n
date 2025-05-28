/// @description Refresh the drawing preset font

var to_refresh = i18n_get_locales_code();
var font_locale = "font_";				// global.font_* that we declared before

for (var i = 0; i < array_length(to_refresh); i++) {
	var presets = struct_get_names(global.i18n.data[$ to_refresh[i]].drawings);
	
	for (var j = 0; j < array_length(presets); j++) {
		global.i18n.data[$ to_refresh[i]].drawings[$ presets[j]].font = (to_refresh[i] == "en" || to_refresh[i] == "idn") ? fNotoSansMedium : variable_global_get(font_locale + to_refresh[i]);
	}
}

//show_debug_message($"ja.drawings = {global.i18n.data.ja.drawings}")
