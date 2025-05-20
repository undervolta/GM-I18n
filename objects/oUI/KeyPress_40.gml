/// @description Reduces plural value

if (my_val > 0) {
	my_val--;
}

i18n_update_plurals("menu_3_test", my_val);
i18n_update_plurals("menu_4.test", my_val, true);
