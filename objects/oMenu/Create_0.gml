image_alpha = 0;
image_xscale = 4;
image_yscale = 0.6;

x_mod = 0;			// simple x animation
active = false;

// Create dynamic text translation
ref_msg = i18n_create_ref_message("ref_msg", key);

// Check if this locale is in use
in_use = function() {
	active = false;
	
	if (ui_id.page == num) {
		active = true;
	}
}

in_use();
