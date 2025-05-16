/// @description UI

i18n_draw_message(41, 80, "@:title", , "title", "en");

// Draw the description based on the active menu number
var y_add = 0;

switch (page) {
	case 1:		// Translation
		var messages = [menu_1_head_1, menu_1_desc_1, menu_1_head_2, menu_1_desc_2];
	
		for (var i = 0; i < array_length(messages); i++) {
			var preset = ((i % 2 == 0) ? "header" : "desc");

			i18n_draw_message(432, 176 + y_add, messages[i], , preset, ((i <= 1) ? "en" : ""));
			
			var sep = i18n_get_drawings_data(preset, I18N_DRAWING.SEP);
			var w = i18n_get_drawings_data(preset, I18N_DRAWING.WIDTH);
			
			y_add += string_height_ext(messages[i], sep, w) - 30 + ((i % 2 == 1) * 30);
		}
	break;
}
