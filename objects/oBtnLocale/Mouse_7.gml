/// @description Toggle the active locale

if (!active) {
	i18n_set_locale(locale);
	
	for (var i = 0; i < array_length(ui_id.btn_list); i++) {
		ui_id.btn_list[i].in_use();
	}
}
