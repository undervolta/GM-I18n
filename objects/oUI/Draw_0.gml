/// @description UI

i18n_draw_message(41, 80, "@:title", , "title", "en");
draw_set_color(#CCCCCC);
draw_set_valign(fa_bottom);
draw_text_transformed(410, 106, version, 0.6, 0.6, 0);

if (oI18n.refreshed && os_browser != browser_not_a_browser) {
	draw_set_halign(fa_right);
	draw_set_font(i18n_get_drawings_data("desc", I18N_DRAWING.FONT));
	draw_text_transformed(room_width - 35, 111, bug_1, 0.4, 0.4, 0);
}

// Draw the description based on the active menu number
var messages, w, preset;
var sep = 32;
var y_add = 0;

switch (page) {
	case 1:		// Translation
		messages = [menu_1_head_1, menu_1_desc_1, menu_1_head_2, menu_1_desc_2];
	
		for (var i = 0; i < array_length(messages); i++) {
			preset = ((i % 2 == 0) ? "header" : "desc");
			
			i18n_draw_message(432, 176 + y_add, messages[i], , preset, ((i <= 1) ? "en" : ""));
			
			sep = i18n_get_drawings_data(preset, I18N_DRAWING.SEP);
			w = i18n_get_drawings_data(preset, I18N_DRAWING.WIDTH);
			
			y_add += string_height_ext(messages[i], sep, w) - 30 + ((i % 2 == 1) * 30);
		}
	break;
	case 2:		// Interpolation
		messages = [menu_2.head_1, menu_2.desc_1, menu_2.head_2, menu_2.desc_2, menu_2.head_3, menu_2.desc_3];
	
		for (var i = 0; i < array_length(messages); i++) {
			preset = ((i % 2 == 0) ? "header" : "desc");

			i18n_draw_message(432, 176 + y_add, messages[i], , preset);
			
			w = i18n_get_drawings_data(preset, I18N_DRAWING.WIDTH);
			
			y_add += string_height_ext(messages[i], sep, w) - 30 + ((i % 2 == 1) * 30);
		}
	break;
	case 3:		// Pluralization
		messages = menu_3;
	
		for (var i = 0; i < array_length(messages); i++) {
			preset = ((i % 2 == 0) ? "header" : "desc");

			i18n_draw_message(432, 176 + y_add, messages[i], , preset);
			
			w = i18n_get_drawings_data(preset, I18N_DRAWING.WIDTH);
			
			y_add += string_height_ext(messages[i], sep, w) - 30 + ((i % 2 == 1) * 30);
		}
	
		i18n_draw_message(432, 176 + y_add, menu_3_test, , "desc");
		y_add += string_height(menu_3_test) - 30;
	
		i18n_draw_message(432, 176 + y_add, "@:plural_guide", , "desc");
	break;
	case 4:		// Dictionary
		messages = [menu_4.head, menu_4.desc];
	
		for (var i = 0; i < array_length(messages); i++) {
			preset = ((i % 2 == 0) ? "header" : "desc");

			i18n_draw_message(432, 176 + y_add, messages[i], , preset);
			
			w = i18n_get_drawings_data(preset, I18N_DRAWING.WIDTH);
			
			y_add += string_height_ext(messages[i], sep, w) - 30 + ((i % 2 == 1) * 30);
		}
	
		i18n_draw_message(432, 176 + y_add, menu_4.test, , "desc");
		y_add += string_height(menu_4.test) - 30;
	
		i18n_draw_message(432, 176 + y_add, "@:plural_guide", , "desc");
	break;
	case 5:		// Drawing
		for (var i = 0; i < array_length(global.menu_5); i++) {
			preset = ((i % 2 == 0) ? "header" : "desc");

			i18n_draw_message(432, 176 + y_add, global.menu_5[i], , preset);
			
			w = i18n_get_drawings_data(preset, I18N_DRAWING.WIDTH);
			
			y_add += string_height_ext(global.menu_5[i], sep, w) - 30 + ((i % 2 == 1) * 30);
		}
	break;
	case 6:		// Localized Asset
		messages = [global.menu.menu_6.head_1, global.menu.menu_6.desc_1];
	
		for (var i = 0; i < array_length(messages); i++) {
			preset = ((i % 2 == 0) ? "header" : "desc");

			i18n_draw_message(432, 176 + y_add, messages[i], , preset);
			
			w = i18n_get_drawings_data(preset, I18N_DRAWING.WIDTH);
			
			y_add += string_height_ext(messages[i], sep, w) - 30 + ((i % 2 == 1) * 30);
		}
		
		draw_sprite(menu_6_spr, 0, 745, 251 + y_add);
		y_add += 182;
		
		i18n_draw_message(432, 176 + y_add, global.menu.menu_6.test_1, , "desc");
	break;
}
