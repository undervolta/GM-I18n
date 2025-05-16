/// @description Toggle the active menu

if (!active) {
	ui_id.page = num;
	
	for (var i = 0; i < array_length(ui_id.menu_list); i++) {
		ui_id.menu_list[i].in_use();
	}
	
	// Update the i18n references
	i18n_update_refs();
}
