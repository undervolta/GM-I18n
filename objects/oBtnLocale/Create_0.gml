/// @description Locale switcher button

image_xscale = 2.65;
image_yscale = 0.79;

active = false;

// Check if this locale is in use
in_use = function() {
	image_blend = #FFFFFF;
	active = false;
	
	if (locale == i18n_get_locale()) {
		image_blend = #B3B3B3;
		active = true;
	}
}

in_use();
