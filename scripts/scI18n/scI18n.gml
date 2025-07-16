/**
 * name: GM-I18n
 * desc: A powerful, open-source internationalization (i18n) library for GameMaker 2.3+
 * author: @undervolta
 * version: 1.0.0
 * date: 2025-07-16
 * 
 * repo: https://github.com/undervolta/GM-I18n
 * docs: https://gm-i18n.lefinitas.com
 * license: MIT
 * 
 * dependencies: None
 * compatibility: GameMaker 2.3+ - All platforms
 */


/// feather ignore GM1041
/// feather ignore GM1044
/// feather ignore GM1045
/// feather ignore GM1063


global.i18n_name = "";

enum I18N_DRAWING {
	FONT,
	HALIGN,
	VALIGN,
	COLOR,
	SCALE,
	ROTATION,
	ALPHA,
	SEP,
	WIDTH
}

enum I18N_DRAW_TEXT {
	NORMAL,
	EXTENDED,
	COLORED,
	TRANSFORMED,
	EXT_COLORED,
	EXT_TRANSFORMED,
	TRANSFORMED_COLORED,
	EXT_TRANSFORMED_COLORED
}

enum I18N_REF {
	ALL,
	MESSAGES,
	ASSETS
}


/**
 * @desc Struct constructor for initializing a locale
 * @param {String} lang_code Locale code (e.g. "en").
 * @param {String} lang_name Locale name (e.g. "English").
 * @param {String | Array<String>} [lang_file]="" Path to locale file(s), which will be loaded on initialization automatically (e.g. "~/langs/en.json").
 */
function I18nLocaleInit(lang_code, lang_name, lang_file = "") constructor {
	// Guard clause
	if (!is_string(lang_code)) {
		show_debug_message($"I18n ERROR - I18nLocaleInit({lang_code}, {lang_name}, {lang_file}) - `lang_code` must be a string");
		exit;
	}
	if (!is_string(lang_name)) {
		show_debug_message($"I18n ERROR - I18nLocaleInit({lang_code}, {lang_name}, {lang_file}) - `lang_name` must be a string");
		exit;
	}

	// Struct members
	code = lang_code;
	name = lang_name;

	if (lang_file != "") {
		if (!(is_string(lang_file) || is_array(lang_file))) {
			show_debug_message($"I18n ERROR - I18nLocaleInit({lang_code}, {lang_name}, {lang_file}) - `lang_file` must be a string or an array of strings");
			exit;
		}
		file = lang_file;
	} 
}


/**
 * @desc (INTERNAL) Struct constructor for loading locale files
 * @param {Real | Array<Real> | Undefined} interval Time interval in seconds to load the next file.
 * @param {Struct.i18n_create | Bool} [i18n_struct]=false I18n struct reference.
 */
function I18nLoad(interval, i18n_struct = false) constructor {
	// Guard clause
	if (!(is_numeric(interval) || is_array(interval))) {
		show_debug_message($"I18n ERROR - I18nLoad({interval}) - `interval` must be numeric");
		exit;
	}
	
	i18n = i18n_struct;
	if (!(is_struct(i18n_struct) || is_bool(i18n_struct))) {
		show_debug_message($"I18n ERROR - I18nLoad({interval}) - `i18n_struct` must be a i18n struct");
		exit;
	} else if (is_bool(i18n_struct)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Struct members
	time = interval;
	step = 0;
	max_step = 0;
	step_time = [];
	step_index = 0;

	files = [];
	files_locale = [];
	for (var i = 0; i < array_length(i18n.locales); i++) {
		if (!struct_exists(i18n.locales[i], "file")) {
			continue;
		}
		
		if (!is_array(i18n.locales[i].file)) {
			i18n.locales[i].file = [i18n.locales[i].file];
		}

		files = array_concat(files, i18n.locales[i].file);
		for (var j = 0; j < array_length(i18n.locales[i].file); j++) {
			array_push(files_locale, i18n.locales[i].code);
		}
	}
	
	if (time == 0) {				// Load all files later in i18n_update_loader() if interval is not set
		time = [-1];	
		max_step = 1;
	} else if (!is_array(time)) {	// Interval is set
		time = [time];
	}

	// Fill the missing intervals or remove the extra intervals
	if (array_length(time) < array_length(files)) {
		repeat (array_length(files) - array_length(time)) {
			array_push(time, time[array_length(time) - 1]);
		}
	} else if (array_length(time) > array_length(files)) {
		repeat (array_length(time) - array_length(files)) {
			array_pop(time);
		}
	}
	
	// Shift zero interval and the files to the start
	var sorted_time = [[], []];							// [[zeros], [non-zeros]]
	var sorted_files = [[], []];
	var sorted_files_locale = [[], []];
	
	for (var i = 0; i < array_length(time); i++) {
		array_push(sorted_time[(time[i] > 0)], time[i]);
		array_push(sorted_files[(time[i] > 0)], files[i]);
		array_push(sorted_files_locale[(time[i] > 0)], files_locale[i]);
    }
	
	time = array_concat(sorted_time[0], sorted_time[1]);
	files = array_concat(sorted_files[0], sorted_files[1]);
	files_locale = array_concat(sorted_files_locale[0], sorted_files_locale[1]);
	
	// Calculate max step and step time	
	for (var i = 0; i < array_length(files); i++) {
		if (time[i] == 0) {
			time[i] = 0.01;
		}
		max_step += ceil(time[i] * game_get_speed(gamespeed_fps));
	}

	for (var i = 0; i < array_length(files); i++) {
		array_push(step_time, (i == 0)
							? ceil(time[i] * game_get_speed(gamespeed_fps))
							: ceil(step_time[i - 1] + (time[i] * game_get_speed(gamespeed_fps))));
	}

	
	static dt = function() {
		return ((delta_time/1000000) / (1/60));
	}
	
	static update = function(use_delta_time = false) {
		if (time[0] == -1) {								// Load all files at once if interval was not set
			for (var i = 0; i < array_length(files); i++) {
				time[i] = 0;
				load(files[i], files_locale[i]);
			}
		} else if (time[0] > 0) {							// Load each file
			step += (use_delta_time) ? dt() : 1;

			if (floor(step) >= step_time[step_index]) {
				load(files[step_index], files_locale[step_index]);
				step_index++;
			}
		}
	}

	static load = function(filename, locale) {
		// Guard clauses
		if (!is_string(filename)) {
			show_debug_message($"I18n ERROR - I18nLoad.load({filename}, {locale}) - `filename` must be a string");
			exit;
		}

		if (string_pos(".json", filename) == 0) {
			show_debug_message($"I18n ERROR - I18nLoad.load({filename}, {locale}) - \"{filename}\" is not a valid JSON file");
			exit;
		}

		// Load file
		var root = "";
		var file_loc;

		if (string_pos("~/", filename) == 1) {
			root = working_directory;
		}

		file_loc = root + string_copy(filename, 3, string_length(filename) - 2);

		if (!file_exists(file_loc)) {
			show_debug_message($"I18n ERROR - I18nLoad.load({filename}, {locale}) - \"{filename}\" JSON file does not exist");
			exit;
		}
		
		var file = file_text_open_read(file_loc);
		if (file == -1) {
			show_debug_message($"I18n ERROR - I18nLoad.load({filename}, {locale}) - Could not open \"{filename}\" JSON file");
			exit;
		}

		var json_string = "";
		while (!file_text_eof(file)) {
			json_string += file_text_read_string(file);
			file_text_readln(file);
		}
		
		file_text_close(file);
		
		
		try {
			var json_struct = json_parse(json_string);
			flatten(json_struct, i18n, locale);
			if (i18n.debug) {
				show_debug_message($"I18n SUCCESS - I18nLoad.load({filename}, {locale}) - Successfully loaded \"{filename}\" JSON file");
			}
		} catch (e) {
			show_debug_message($"I18n ERROR - I18nLoad.load({filename}, {locale}) - Failed to parse \"{filename}\" JSON file: " + string(e));
			exit;
		}
	}

	static flatten = function(struct, i18n, locale = "", prefix = "") {
		var names = struct_get_names(struct);
		
		for (var i = 0; i < array_length(names); i++) {
			var name = names[i];
			var value = struct[$ name];
			var key = (prefix == "") ? name : string($"{prefix}.{name}");
			
			if (is_struct(value)) {
				flatten(value, i18n, locale, key);
			} else {
				if (!i18n.hashed) {
					i18n.data[$ locale].messages[$ key] = value;
				} else {
					struct_set_from_hash(i18n.data[$ locale].messages, variable_get_hash(key), value);
				}
			}
		}
	}
}


/**
 * @desc Struct constructor for I18nDrawings
 * @param {String | Asset.GMFont} [draw_font] Font asset. If a string is provided, it will be converted to an asset index.
 * @param {Constant.HAlign} [draw_halign] Horizontal alignment.
 * @param {Constant.VAlign} [draw_valign] Vertical alignment .
 * @param {Constant.Colour | Array<Constant.Colour> | Real | Array<Real>} [draw_color] Drawing or text color.
 * @param {Real} [draw_scale] Drawing or text scale.
 * @param {Real} [draw_rotation] Drawing or text rotation.
 * @param {Real} [draw_alpha] Drawing or text opacity.
 * @param {Real} [text_sep] Text separation.
 * @param {Real} [text_width] Text width.
 */
function I18nDrawings(draw_font = undefined, draw_halign = undefined, draw_valign = undefined, draw_color = undefined, draw_scale = undefined, draw_rotation = undefined, draw_alpha = undefined, text_sep = undefined, text_width = undefined, is_template = false) constructor  {
	font = (asset_get_type(draw_font) == asset_font || is_string(draw_font)) ? draw_font : undefined;
	halign = draw_halign;
	valign = draw_valign;
	color = draw_color;
	alpha = is_real(draw_alpha) ? draw_alpha : undefined;
	scale = is_real(draw_scale) ? draw_scale : (is_template ? undefined : 1);
	rotation = is_real(draw_rotation) ? draw_rotation : (is_template ? undefined : 0);
	sep = is_real(text_sep) ? text_sep : (is_template ? undefined : -1);
	width = is_real(text_width) ? text_width : (is_template ? undefined : room_width);

	// Member validation
	if (!(halign == fa_left || halign == fa_center || halign == fa_right)) {
		if (!is_template) {
			show_debug_message($"I18n WARNING - I18nDrawings({draw_font}, {draw_halign}, {draw_valign}, {draw_color}, {draw_scale}, {draw_rotation}, {draw_alpha}, {text_sep}, {text_width}, {is_template}) - `draw_halign` must be a valid horizontal alignment constant, defaulting to `fa_left`");
		}
		halign = is_template ? undefined : fa_left;
	}
	if (!(valign == fa_top || valign == fa_middle || valign == fa_bottom)) {
		if (!is_template) {
			show_debug_message($"I18n WARNING - I18nDrawings({draw_font}, {draw_halign}, {draw_valign}, {draw_color}, {draw_scale}, {draw_rotation}, {draw_alpha}, {text_sep}, {text_width}, {is_template}) - `draw_valign` must be a valid vertical alignment constant, defaulting to `fa_top`");
		}
		valign = is_template ? undefined : fa_top;
	}
	if (!(is_numeric(color) || is_array(color))) {
		if (!is_template) {
			show_debug_message($"I18n WARNING - I18nDrawings({draw_font}, {draw_halign}, {draw_valign}, {draw_color}, {draw_scale}, {draw_rotation}, {draw_alpha}, {text_sep}, {text_width}, {is_template}) - `draw_color` must be a valid color constant or array, defaulting to `c_white`");
		}
		color = is_template ? undefined : c_white;
	}
	if (is_array(color)) {
		if (array_length(color) > 0 && array_length(color) < 4) {
			if (!is_template) {
				show_debug_message($"I18n WARNING - I18nDrawings({draw_font}, {draw_halign}, {draw_valign}, {draw_color}, {draw_scale}, {draw_rotation}, {draw_alpha}, {text_sep}, {text_width}, {is_template}) - `draw_color` array must have 4 elements, filling the missing elemnts with the last color");
				repeat (4 - array_length(color)) {
					array_push(color, color[array_length(color) - 1]);
				}
			}
		} else {
			color = [c_white, c_white, c_white, c_white];
		}
	}

	// Set draw type
	draw_type = I18N_DRAW_TEXT.NORMAL;

	if (!(is_undefined(sep) || is_undefined(width))) {
		draw_type = I18N_DRAW_TEXT.EXTENDED;
	}

	if (!(is_undefined(color) || is_undefined(alpha))) {
		if (!is_template) {
			if (is_undefined(color)) {
				color = c_white;
			}
			if (is_undefined(alpha)) {
				alpha = 1;
			}
		}

		if (is_array(color)) {
			switch (draw_type) {
				case I18N_DRAW_TEXT.NORMAL: draw_type = I18N_DRAW_TEXT.COLORED; break;
				case I18N_DRAW_TEXT.EXTENDED: draw_type = I18N_DRAW_TEXT.EXT_COLORED; break;
			}
		}
	}

	if (!(is_undefined(rotation) || is_undefined(scale))) {
		switch (draw_type) {
			case I18N_DRAW_TEXT.NORMAL: draw_type = I18N_DRAW_TEXT.TRANSFORMED; break;
			case I18N_DRAW_TEXT.COLORED: draw_type = I18N_DRAW_TEXT.TRANSFORMED_COLORED; break;
			case I18N_DRAW_TEXT.EXTENDED: draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED; break;
			case I18N_DRAW_TEXT.EXT_COLORED: draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED; break;
		}
	}
}


/** 
 * @desc Search the target value index in array using binary search
 * @param {Array<Any>} array Array to search
 * @param {Any} target Target value to search
 * @return {Real}
 */
function binary_search(array, target) {
	// Guard clause
	if (!is_array(array)) {
		show_debug_message($"ERROR - binary_search({array}, {target}) - `array` must be array");
		return -1;
	}
	if (array_length(array) == 0) {
		return -1;
	}

	// Binary search
    var left = 0;
    var right = array_length(array) - 1;
    
    while (left <= right) {
        var mid = left + floor((right - left) / 2);
        
        if (array[mid] == target) {
            return mid;
        }
        else if (array[mid] < target) {
            left = mid + 1;
        }
        else {
            right = mid - 1;
        }
    }
    
    return -1;
}


/** 
 * @desc Search the index where target value should be inserted using binary search
 * @param {Array<any>} array Array to search
 * @param {Any} target Target value to search
 * @return {Real}
 */
function binary_search_insert_pos(array, target) {
	// Guard clause
	if (!is_array(array)) {
		show_debug_message($"ERROR - binary_search_insert_pos({array}, {target}) - `array` must be array");
		return -1;
	}
	if (array_length(array) == 0) {
		return -1;
	}

	// Binary search
    var left = 0;
    var right = array_length(array);
    
    while (left < right) {
        var mid = left + (right - left) / 2;
        
        if (array[mid] < target) {
            left = mid + 1;
        }
        else {
            right = mid;
        }
    }
    
    return left;
}


/**
 * @desc Create an i18n struct and initialize it
 * @param {String} var_name Variable name that will be assigned to the i18n struct (e.g. "i18n", "global.i18n").
 * @param {String} default_locale Default locale code (e.g. "en").
 * @param {Array<Struct.I18nLocaleInit>} locales Array of I18nLocaleInit structs (e.g. [new I18nLocaleInit("en", "English")]).
 * @param {Bool | Struct} [options]=false Optional struct with additional options (e.g. {hashed: true, time: 1}).
 * @returns {Struct.i18n_create} 
 */
function i18n_create(var_name, default_locale, locales, options = false) {
	// Guard clause
	if (!(is_string(var_name) && is_string(default_locale))) {
		show_debug_message($"I18n ERROR - i18n_create({var_name}, {default_locale}, {locales}, {options}) - `var_name` and `default_locale` must be strings");
		exit;
	}

	if (!is_array(locales)) {
		show_debug_message($"I18n ERROR - i18n_create({var_name}, {default_locale}, {locales}, {options}) - `locales` must be an array of I18nLocaleInit structs");
		exit;
	}

	if (!(is_bool(options || is_struct(options)))) {
		show_debug_message($"I18n ERROR - i18n_create({var_name}, {default_locale}, {locales}, {options}) - `options` must be a struct");
		exit;
	}

	// Initialize struct members
	var i18n = {
		name: var_name,
		scope: "instance",
		default_locale: default_locale,
		locale: default_locale,
		locales: locales,
		drawing_presets: [],
		data: {},
		refs: {
			messages: {
				inst: [],
				refs: [],
				keys: [],
				data: []
			},
			assets: {
				inst: [],
				refs: [],
				assets: []
			}
		},
		cache: {
			ids: [],
			values: [],
			keys: [],
			data: [],
			locales: []
		},
		debug: false,
		hashed: true,
		cached: false,
		default_message: "",
		plural_delimiter: "|",
		plural_start_at: 0,
		linked_start: "[",
		linked_end: "]",
	}

	// Set scope
	if (string_pos("global.", var_name) > 0 || string_pos("g.", var_name) > 0) {
		i18n.scope = "global";
		i18n.name = string_copy(i18n.name, string_pos(".", i18n.name) + 1, string_length(i18n.name) - string_pos(".", i18n.name));
		variable_global_set("i18n_name", i18n.name);
	}

	// Set options
	if (is_struct(options)) {
		var names = struct_get_names(options);
		for (var i = 0; i < array_length(names); i++) {
			i18n[$ names[i]] = options[$ names[i]];
		}
	}
	if (i18n.cached && os_browser != browser_not_a_browser) {
		if (i18n.debug) {
			show_debug_message($"I18n WARNING - i18n_create({var_name}, {default_locale}, {locales}, {options}) - Message caching is not supported in the browser, disabling it");
		}
		i18n.cached = false;
	}

	// Initialize data
	for (var i = 0; i < array_length(locales); i++) {
		if (!struct_exists(i18n.data, locales[i].code)) {
			i18n_add_locales(locales[i].code, i18n);
		}

		if (struct_exists(locales[i], "file")) {
			// Initialize loader
			if (!is_array(locales[i].file)) {
				locales[i].file = [locales[i].file];
			}
			
			if (!struct_exists(i18n, "loader")) {
				i18n.loader = new I18nLoad((struct_exists(i18n, "time") ? i18n.time : 0), i18n);
			}
		}
	}
	
	return i18n;
}


/**
 * @desc Update i18n loader
 * @param {Bool} [use_delta_time]=false Use time-based increment instead of frame-based increment. 
 * @param {Struct.i18n_create | Bool} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_loader(use_delta_time = false, i18n = false) {
	// Guard clause
	if (!is_bool(use_delta_time)) {
		show_debug_message($"I18n ERROR - i18n_update_loader({use_delta_time}) - `use_delta_time` must be boolean");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_update_loader({use_delta_time}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	
	if (!struct_exists(i18n, "loader")) {
		exit;
	}
	
	
	var to_delete = false;

	// Update the loader
	if (struct_exists(i18n, "time")) {									// Interval or time is set
		if (i18n.loader.step < i18n.loader.max_step) {
			i18n.loader.update(use_delta_time);
		} else {														// Remove the loader after all files are loaded
			to_delete = true;
		}
	} else if (i18n.loader.time[0] == -1) {								// Load all files and then remove the loader if interval or time isn't set
		for (var i = 0; i < array_length(i18n.loader.files); i++) {
			i18n.loader.load(i18n.loader.files[i], i18n.loader.files_locale[i]);
		}
		
		to_delete = true;
	}

	// Check the fonts in the drawing presets
	var langs = struct_get_names(i18n.data);
	var presets = [];
	var font_index = -1;
	
	if (array_length(i18n.drawing_presets) == 0) {			// If the drawing presets are not initialized, initialize them
		for (var i = 0; i < array_length(langs); i++) {
			presets = struct_get_names(i18n.data[$ langs[i]].drawings);
			
			for (var j = 0; j < array_length(presets); j++) {
				array_push(i18n.drawing_presets, i18n.data[$ langs[i]].drawings[$ presets[j]]);
				
				if (is_string(i18n.data[$ langs[i]].drawings[$ presets[j]].font)) {
					font_index = asset_get_index(i18n.data[$ langs[i]].drawings[$ presets[j]].font);
					
					if (font_index != -1) {
						i18n.data[$ langs[i]].drawings[$ presets[j]].font = font_index;
						
						if (to_delete) {
							to_delete = false;				// If the font is not found, do not delete the loader
						} 
					} 
				}
			}
		}
	} else {			// If the drawing presets are initialized, check the fonts
		for (var i = 0; i < array_length(i18n.drawing_presets); i++) {
			if (is_string(i18n.drawing_presets[i].font)) {
				font_index = asset_get_index(i18n.drawing_presets[i].font);
				show_debug_message("cek")
				if (font_index != -1) {
					i18n.drawing_presets[i].font = font_index;
					
					if (to_delete) {
						to_delete = false;				// If the font is not found, do not delete the loader
					} 
				} 
			}
		}
	}

	// Remove the loader and drawing presets initialization if all locale files are loaded
	if (to_delete) {
		if (struct_exists(i18n, "time")) {
			i18n.time = i18n.loader.time;
		} else {
			i18n.loader.time[0] = 0;
		}

		struct_remove(i18n, "loader");
		struct_remove(i18n, "drawing_presets");
	}
}


/**
 * @desc Add localized messages to a locale in the i18n struct
 * @param {String} locale Locale code (e.g. "en").
 * @param {Struct} data Localized messages struct (e.g. {key: "value", ...}).
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @param {String} [prefix]="" = (INTERNAL) Prefix to add to the message keys
 */
function i18n_add_messages(locale, data, i18n = false, prefix = "") {
	// Guard clause
	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_add_messages({locale}, {data}) - `locale` must be a string");
		exit;
	}

	if (!is_struct(data)) {
		show_debug_message($"I18n ERROR - i18n_add_messages({locale}, {data}) - `data` must be a struct");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_add_messages({locale}, {data}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}	

	if (!struct_exists(i18n.data, locale)) {
		show_debug_message($"I18n ERROR - i18n_add_messages({locale}, {data}) - \"{locale}\" locale does not exist");
		exit;
	}

	// Set data
	var names = struct_get_names(data);
	
	for (var i = 0; i < array_length(names); i++) {
		var name = names[i];
		var value = data[$ name];
		var key = (prefix == "") ? name : string($"{prefix}.{name}");
		
		if (is_struct(value)) {
			i18n_add_messages(locale, value, i18n, key);
		} else {
			if (!i18n.hashed) {
				i18n.data[$ locale].messages[$ key] = value;
			} else {
				struct_set_from_hash(i18n.data[$ locale].messages, variable_get_hash(key), value);
			}
		}
	}
}


/**
 * @desc Add localized dictionaries to a locale in the i18n struct
 * @param {String} locale Locale code (e.g. "en").
 * @param {Array<Any> | Array<Array<Any>>} data Localized dictionaries array (e.g. ["key", "value"] or [["key1", "value1"], ["key2", "value2"], ...]).
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_add_dictionaries(locale, data, i18n = false) {
	// Guard clause
	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_add_dictionaries({locale}, {data}) - `locale` must be a string");
		exit;
	}

	if (!is_array(data)) {
		show_debug_message($"I18n ERROR - i18n_add_dictionaries({locale}, {data}) - `data` must be an array of strings or an array of arrays of strings");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_add_dictionaries({locale}, {data}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!struct_exists(i18n.data, locale)) {
		show_debug_message($"I18n ERROR - i18n_add_dictionaries({locale}, {data}) - \"{locale}\" locale does not exist");
		exit;
	}

	if (!is_array(data[0])) {
		data = [data];
	}
	
	// Add dictionaries	
	for (var i = 0; i < array_length(data); i++) {
		var valid = true;
		
		for (var j = 0; j < array_length(data[i]); j++) {
			if (!is_string(data[i][j])) {
				valid = false;
				break;
			}
		}
		
		if (valid) {
			struct_set_from_hash(i18n.data[$ locale].dictionaries, variable_get_hash(data[i][0]), data[i][1]);
		}
	}
}


/**
 * @desc Add localized drawing presets to a locale in the i18n struct
 * @param {String | Array<String>} locale Locale code (e.g. "en").
 * @param {String | Array<String>} preset_name Drawing preset name (e.g "title").
 * @param {Struct.I18nDrawings | Array<Struct.I18nDrawings>} data Struct of I18nDrawings or array of these structs (e.g. new I18nDrawings(...)).
 * @param {Bool} [use_ref]=true Use the first I18nDrawings struct as a reference, instead of creating a new one. Only works if locale is an array.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_add_drawings(locale, preset_name, data, use_ref = true, i18n = false) {
	// Guard clause
	if (!(is_string(locale) || is_array(locale))) {
		show_debug_message($"I18n ERROR - i18n_add_drawings({locale}, {preset_name}, {data}, {use_ref}) - `locale` must be a string or array of strings");
		exit;
	}

	if (!(is_string(preset_name) || is_array(preset_name))) {
		show_debug_message($"I18n ERROR - i18n_add_drawings({locale}, {preset_name}, {data}, {use_ref}) - `preset_name` must be a string or array of strings");
		exit;
	}

	if (!(is_struct(data) || is_array(data))) {
		show_debug_message($"I18n ERROR - i18n_add_drawings({locale}, {preset_name}, {data}, {use_ref}) - `data` must be a struct from `I18nDrawings` or array of `I18nDrawings`");
		exit;
	}

	if (!is_bool(use_ref)) {
		show_debug_message($"I18n ERROR - i18n_add_drawings({locale}, {preset_name}, {data}, {use_ref}) - `use_ref` must be a boolean");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_add_drawings({locale}, {preset_name}, {data}, {use_ref}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!is_array(preset_name)) {
		preset_name = [preset_name];
	}

	if (!is_array(data)) {
		data = [data];
	}

	if (array_length(preset_name) != array_length(data)) {
		if (i18n.debug) {
			show_debug_message($"I18n ERROR - i18n_add_drawings({locale}, {preset_name}, {data}, {use_ref}) - `preset_name` and `data` must be the same lengthname and data must be the same length");
		}
		exit;
	}

	// Set data
	if (!is_array(locale)) {
		locale = [locale];
	}

	for (var i = 0; i < array_length(locale); i++) {
		// Guard clauses
		if (!struct_exists(i18n.data, locale[i])) {
			show_debug_message($"I18n ERROR - i18n_add_drawings({locale}, {preset_name}, {data}, {use_ref}) - \"{locale[i]} Locale does not exist");
			break;
		}

		if (i == 0 || (i > 0 && !use_ref)) {						// Create new struct if locale is first or use_ref is false
			for (var j = 0; j < array_length(preset_name); j++) {
				var names = struct_get_names(data[j]);
				
				if (!struct_exists(i18n.data[$ locale[i]].drawings, preset_name[j])) {
					i18n.data[$ locale[i]].drawings[$ preset_name[j]] = {};
				}
				
				for (var k = 0; k < array_length(names); k++) {
					i18n.data[$ locale[i]].drawings[$ preset_name[j]][$ names[k]] = data[j][$ names[k]];
				}
			}
		} else {													// Use first struct as a reference
			for (var j = 0; j < array_length(preset_name); j++) {
				i18n.data[$ locale[i]].drawings[$ preset_name[j]] = i18n.data[$ locale[0]].drawings[$ preset_name[j]];
			}
		}
	}
}


/**
 * @desc Add locale(s) with empty data to the i18n struct
 * @param {String | Array<String>} code Locale code (e.g. "en").
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_add_locales(code, i18n = false) {
	// Guard clause
	if (!(is_string(code) || is_array(code))) {
		show_debug_message($"I18n ERROR - i18n_add_locales({code}) - `code` must be a string or an array of strings");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_add_locales({code}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!is_array(code)) {
		code = [code];
	}

	// Create locale templates
	for (var i = 0; i < array_length(code); i++) {
		i18n.data[$ code[i]] = {
			messages: {},
			dictionaries: {},
			drawings: {}
		};
	}
}


/**
 * @desc Check if i18n is loaded
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Bool} 
 */
function i18n_is_ready(i18n = false) {
	// Guard clause
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_is_ready() - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return (!struct_exists(i18n, "loader"));
}


/**
 * @desc Check if locale exists
 * @param {String} locale Locale code (e.g. "en").
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Bool} 
 */
function i18n_locale_exists(locale, i18n = false) {
	// Guard clause
	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_locale_exists({locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_locale_exists({locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return struct_exists(i18n.data, locale);
}


/**
 * @desc Check if a message key is exists in the current locale
 * @param {String} key Message key (e.g. "hello").
 * @param {String} [locale]="" Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Bool} 
 */
function i18n_message_exists(key, locale = "", i18n = false) {
	// Guard clause
	if (!is_string(key)) {
		show_debug_message($"I18n ERROR - i18n_message_exists({key}, {locale}) - `key` must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_message_exists({key}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_message_exists({key}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}
	
	return ((i18n.hashed) ? struct_get_from_hash(i18n.data[$ locale].messages, variable_get_hash(key)) : struct_exists(i18n.data[$ locale].messages, key));
}


/**
 * @desc Get current locale
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {String} 
 */
function i18n_get_locale(i18n = false) {
	// Guard clause
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_locale() - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return i18n.locale;
}


/**
 * @desc Get all initialized locales
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Array<Struct.I18nLocaleInit>} 
 */
function i18n_get_locales(i18n = false) {
	// Guard clause
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_locales() - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return i18n.locales;
}


/**
 * @desc Get all locales code
 * @param {Bool} [include_non_init]=false Include non initialized locales.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Array<String>} 
 */
function i18n_get_locales_code(include_non_init = false, i18n = false) {
	// Guard clause
	if (!is_bool(include_non_init)) {
		show_debug_message($"I18n ERROR - i18n_get_locales_code({include_non_init}) - `include_non_init` must be a boolean");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_locales_code({include_non_init}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	var result = [];

	if (!include_non_init) {
		var locales = i18n_get_locales(i18n);

		for (var i = 0; i < array_length(locales); i++) {
			array_push(result, locales[i].code);
		}
	} else {
		result = struct_get_names(i18n.data);
	}

	return result;
}


/**
 * @desc Get all initialized locales name
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Array<String>} 
 */
function i18n_get_locales_name(i18n = false) {
	// Guard clause
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_locales_name() - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	var result = [];
	var locales = i18n_get_locales(i18n);

	for (var i = 0; i < array_length(locales); i++) {
		array_push(result, locales[i].name);
	}

	return result;
}


/**
 * @desc Get localized message(s) based on key(s)
 * @param {String | Array<String>} key The message key that you want to get (e.g. "hello").
 * @param {Array<Any> | Struct | Real | Undefined} [data] The additional data for the message. Array (index-based) = [val1, val2, ...], or Struct (name-based) = {key1: val1, key2: val2, ... [, child: {key1: val1, ...}]} (child struct need to be set if it's an interpolation and it have additional data), or Real (pluralization) = number.
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @param {Bool} [create_cache]=false (INTERNAL) Skip cache if it's true.
 * @returns {String | Array<String> | Any} 
 */
function i18n_get_messages(key, data = undefined, locale = "", i18n = false, create_cache = false) {
	// Guard clauses
	if (!(is_string(key) || is_array(key))) {
		show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - `key` must be a string");
		exit;
	}

	if (!is_undefined(data) && !(is_array(data) || is_struct(data) || is_real(data))) {
		show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - `data` must be an array, struct, or real");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Use current locale if empty
	if (locale == "") {
		locale = i18n.locale;
	}

	if (!is_array(key)) {
		key = [key];
	}

	var result = [];

	// Get message(s)
	var cache_name = "";
	var cache_id = -1;
	var full_cache = true;

	for (var i = 0; i < array_length(key); i++) {
		// Get message from locale, from cached data first
		full_cache = false;
		
		if (i18n.cached) {
			cache_name = string("{0}_{1}_{2}", locale, key[i], data);
			cache_id = variable_get_hash(cache_name);
			
			if (array_contains(i18n.cache.ids, cache_id)) {				// with data
				array_push(result, i18n_use_cache(cache_id, i18n));
				full_cache = true;
				continue;
			} else {
				cache_name = string("{0}_{1}", locale, key[i]);
				cache_id = variable_get_hash(cache_name);

				if (array_contains(i18n.cache.ids, cache_id)) {			// without data
					array_push(result, i18n_use_cache(cache_id, i18n));
				} else {
					cache_id = -1;
				}
			}
		} 
	
		if (cache_id == -1) {
			if (struct_exists(i18n.data[$ locale].messages, key[i])) {
				cache_name = "1";
				array_push(result, (!i18n.hashed)
									? i18n.data[$ locale].messages[$ key[i]]
									: struct_get_from_hash(i18n.data[$ locale].messages, variable_get_hash(key[i])));
			} else if (struct_exists(i18n.data[$ i18n.default_locale].messages, key[i])) {
				cache_name = "2";
				array_push(result, (!i18n.hashed) 
									? i18n.data[$ i18n.default_locale].messages[$ key[i]] 
									: struct_get_from_hash(i18n.data[$ i18n.default_locale].messages, variable_get_hash(key[i])));
				if (i18n.debug) {
					show_debug_message($"I18n WARNING - i18n_get_messages({key}, {data}, {locale}) - \"{key[i]}\" message key doesn't exists in \"{locale}\" locale, using default locale instead");
				}
			} else {
				array_push(result, i18n.default_message);
				if (i18n.debug) {
					show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - \"{key[i]}\" message key doesn't exists in \"{locale}\" locale");
				}
			}

			// Create cache if possible
			if (i18n.cached && create_cache && (cache_name == "1" || cache_name == "2")) {
				cache_name = string("{0}_{1}_{2}", locale, key[i], data);
				cache_id = variable_get_hash(cache_name);
				
				if (cache_id <= 2147483647) {			// full cache
					i18n_create_cache(key[i], data, locale, undefined, i18n);

					if (i18n.debug) {
						show_debug_message($"I18n SUCCESS - i18n_get_messages({key[i]}, {data}, {locale}) - Message fully cached with id = {variable_get_hash(cache_name)}");
					}
				} else {													// partial cache
					cache_name = string("{0}_{1}", locale, key[i]);
					cache_id = variable_get_hash(cache_name);

					if (cache_id <= 2147483647) {
						i18n_create_cache(key[i], undefined, locale, undefined, i18n);

						if (i18n.debug) {
							show_debug_message($"I18n SUCCESS - i18n_get_messages({key[i]}, {data}, {locale}) - Message partially cached with id = {variable_get_hash(cache_name)}");
						}
					}
				}
			}
		}
		
		if (!full_cache) {
			// Use selected pluralization
			var raw_plural = string_split(result[i], i18n.plural_delimiter);

			if (array_length(raw_plural) > 1) {
				if (is_real(data)) {					// Pluralization by index
					result[i] = string_trim(raw_plural[max(i18n.plural_start_at, floor(data - i18n.plural_start_at))]);

					if (i18n.debug && (data < i18n.plural_start_at || data > array_length(raw_plural) - 1 + i18n.plural_start_at)) {
						show_debug_message($"I18n WARNING - i18n_get_messages({key}, {data}, {locale}) - Pluralization index out of range");
					}
				} else if (is_struct(data)) {			// Pluralization by struct (need "plural" key (e.g {plural: 1}, {plural: function(number) {return number}, plural_value: 1}, ...))
					if (struct_exists(data, "plural")) {
						if (is_real(data.plural)) {
							result[i] = string_trim(raw_plural[max(i18n.plural_start_at, floor(data.plural - i18n.plural_start_at))]);
							
							if (i18n.debug && (data.plural < i18n.plural_start_at || data.plural > array_length(raw_plural) - 1 + i18n.plural_start_at)) {
								show_debug_message($"I18n WARNING - i18n_get_messages({key}, {data}, {locale}) - Pluralization index out of range");
							}
						} else if (is_callable(data.plural) && struct_exists(data, "plural_value")) {
							var plural_result = data.plural(data.plural_value);

							if (is_real(plural_result)) {
								result[i] = string_trim(raw_plural[max(i18n.plural_start_at, floor(plural_result - i18n.plural_start_at))]);

								if (i18n.debug && (plural_result < i18n.plural_start_at || plural_result > array_length(raw_plural) - 1 + i18n.plural_start_at)) {
									show_debug_message($"I18n WARNING - i18n_get_messages({key}, {data}, {locale}) - Pluralization index out of range");
								}
							} else if (i18n.debug) {
								show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - Pluralization method must return a real number");
							}
						} else if (i18n.debug) {
							show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - Pluralization struct doesn't have a 'plural_value' key");
						}
					} else if (i18n.debug) {
						show_debug_message($"I18n WARNING - i18n_get_messages({key}, {data}, {locale}) - Pluralization struct doesn't have a 'plural' key");
					}
				} else if (i18n.debug) {
					show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - Pluralization data must be a real number or a struct");
				}
			}
			

			// Parse and replace placeholders and key interpolations
			if (!is_undefined(data)) {
				var intp_type = [];			// 1 = {placeholder} | ${with_dict}, 2 = [[interpolation]]
				var start_at = [];
				var end_at = [];

				if (is_array(data)) {
					result[i] = string_ext(result[i], data);
				} else if (is_struct(data)) {
					// Get placeholders and key interpolations
					for (var j = 1; j <= string_length(result[i]); j++) {
						// Placeholder
						if (string_char_at(result[i], j) == "{") {
							array_push(start_at, j);
							array_push(intp_type, 1);
							
							// Check if it's a dictionary placeholder
							if (string_char_at(result[i], j - 1) == "$") {
								start_at[array_length(start_at) - 1] -= 1;
							}
						} else if (string_char_at(result[i], j) == "}" && intp_type[array_length(intp_type) - 1] == 1) {
							array_push(end_at, j);
						}
						
						// Key interpolation
						if (string_char_at(result[i], j) == i18n.linked_start)  {
							if (j+1 <= string_length(result[i]) && array_length(start_at) == array_length(end_at)) {
								if (string_char_at(result[i], j+1) == i18n.linked_start) {
									array_push(start_at, j);
									array_push(intp_type, 2);
								}
							}
						} else if (string_char_at(result[i], j) == i18n.linked_end && intp_type[array_length(intp_type) - 1] == 2) {
							if (j+1 <= string_length(result[i])) {
								if (string_char_at(result[i], j+1) == i18n.linked_end) {
									array_push(end_at, j+1);
								}
							}
						}
					}

					// Replace placeholders and key interpolations
					for (var j = 0; j < array_length(end_at); j++) {
						var current_str = "";
						var placeholder = "";
						var result_str = "";
						
						if (intp_type[j] == 1) {				// Placeholder
							var is_dict = string_starts_with(string_copy(result[i], start_at[j], end_at[j] - start_at[j] - 1), "$");
							
							current_str = string_copy(result[i], start_at[j] + 1 + is_dict, end_at[j] - start_at[j] - 1 - is_dict);
							placeholder = (is_dict) ? string("${" + current_str + "}") : string("{" + current_str + "}");
							
							if (struct_exists(data, current_str)) {		
								result_str = data[$ current_str];

								if (!is_dict) {					// Simple placeholder
									// Update the position of the next placeholder
									for (var k = j+1; k < array_length(end_at); k++) {
										start_at[k] += string_length(result_str) - string_length(placeholder);
										end_at[k] += string_length(result_str) - string_length(placeholder);
									}
								} else {						// Dictionary placeholder
									var current_locale = (locale == "") ? i18n.locale : locale;

									// Replace result with the dictionary
									var replace_str = result_str;
									
									if (struct_exists_from_hash(i18n.data[$ current_locale].dictionaries, variable_get_hash(replace_str))) {
										result_str = string_replace(result_str, replace_str, struct_get_from_hash(i18n.data[$ current_locale].dictionaries, variable_get_hash(replace_str)));
									} else if (i18n.debug) {
										show_debug_message($"I18n WARNING - i18n_get_messages({key}, {data}, {locale}) - \"{replace_str}\" dictionary doesn't exists in \"{current_locale}\" locale");
									}
									
									// Update the position of the next placeholder
									for (var k = j+1; k < array_length(end_at); k++) {
										start_at[k] += string_length(result_str) - string_length(placeholder);
										end_at[k] += string_length(result_str) - string_length(placeholder);
									}
								}

								result[i] = string_replace(result[i], placeholder, result_str);
							} else if (i18n.debug) {
								show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - \"{current_str}\" placeholder doesn't exists in \"{locale}\" locale");
							}
							
						} else if (intp_type[j] == 2) {			// Key interpolation
							current_str = string_copy(result[i], start_at[j] + 2, end_at[j] - start_at[j] - 3);
							placeholder = string_repeat(i18n.linked_start, 2) + current_str + string_repeat(i18n.linked_end, 2);
							
							var child = struct_exists(data, "child_" + string_replace_all(current_str, ".", "_")) 
										? data[$ "child_" + string_replace_all(current_str, ".", "_")]
										: (struct_exists(data, "child") ? data.child : undefined);
							
							if (struct_exists(i18n.data[$ i18n.locale].messages, current_str)) {
								result_str = i18n_get_messages(current_str, child, i18n.locale, i18n, create_cache);
								
								for (var k = j+1; k < array_length(end_at); k++) {
									start_at[k] += string_length(result_str) - string_length(placeholder);
									end_at[k] += string_length(result_str) - string_length(placeholder);
								}
								result[i] = string_replace(result[i], placeholder, result_str);
							} else if (struct_exists(i18n.data[$ i18n.default_locale].messages, current_str)) {
								result_str = i18n_get_messages(current_str, child, i18n.default_locale, i18n, create_cache);
								
								for (var k = j+1; k < array_length(end_at); k++) {
									start_at[k] += string_length(result_str) - string_length(placeholder);
									end_at[k] += string_length(result_str) - string_length(placeholder);
								}
								result[i] = string_replace(result[i], placeholder, result_str);
								
								if (i18n.debug) {
									show_debug_message($"I18n WARNING - i18n_get_messages({key}, {data}, {locale}) - \"{current_str}\" message key doesn't exists in \"{locale}\" locale, using default locale instead");
								}
							} else if (i18n.debug) {
								show_debug_message($"I18n ERROR - i18n_get_messages({key}, {data}, {locale}) - \"{current_str}\" message key doesn't exists in \"{locale}\" locale");
							}
						}
					}
				}
			}
		}
	}

	return ((array_length(result) == 1) ? result[0] : result);
}


/**
 * @desc Get all drawing presets name from a locale
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Array | Array<String>} 
 */
function i18n_get_drawing_presets(locale = "", i18n = false) {
	// Guard clause
	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_drawing_presets({locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_drawing_presets({locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Use current locale if empty
	if (locale == "") {
		locale = i18n.locale;
	}

	if (struct_exists(i18n.data[$ locale], "drawings")) {
		return struct_get_names(i18n.data[$ locale].drawings);
	}

	show_debug_message($"I18n ERROR - i18n_get_drawing_presets({locale}) - \"{locale}\" locale doesn't exists");
	return [];
}


/**
 * @desc Update a drawing preset
 * @param {String} preset_name Drawing preset name (e.g "title").
 * @param {Array<Any> | Struct} data The data to update the drawing preset with (e.g. ["font", fArial], [["font", fArial], ["alpha", 1], ...], {font: fArial, alpha: 1, ...}).
 * @param {String} [locale]="" Locale (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_drawings(preset_name, data, locale = "", i18n = false) {
	// Guard clause
	if (!is_string(preset_name)) {
		show_debug_message($"I18n ERROR - i18n_update_drawings({preset_name}, {data}, {locale}) - `preset_name` must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_update_drawings({preset_name}, {data}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_array(data) || is_struct(data))) {
		show_debug_message($"I18n ERROR - i18n_update_drawings({preset_name}, {data}, {locale}) - `data` must be an array or a struct");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_update_drawings({preset_name}, {data}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}


	if (locale == "") {
		locale = i18n.locale;
	}
	
	if (!struct_exists(i18n.data[$ locale].drawings, preset_name)) {
		show_debug_message($"I18n ERROR - i18n_update_drawings({preset_name}, {data}, {locale}) - \"{preset_name}\" drawing preset doesn't exists");
		exit;
	}

	// Update the drawing preset
	if (is_struct(data)) {
		var names = struct_get_names(data);

		for (var i = 0; i < array_length(names); i++) {
			i18n.data[$ locale].drawings[$ preset_name][names[i]] = data[$ names[i]];
		}
	} else {
		if (!is_array(data[0])) {
			data = [data];
		}

		for (var i = 0; i < array_length(data); i++) {
			if (!is_string(data[i][0])) {
				show_debug_message($"I18n ERROR - i18n_update_drawings({preset_name}, {data}, {locale}) - {data[i][0]} is not a string, skipping this data");
				continue;
			}

			i18n.data[$ locale].drawings[$ preset_name][data[i][0]] = data[i][1];
		}
	}
}


/**
 * @desc Get drawing preset(s) struct from a locale
 * @param {String | Array<String>} preset_name Drawing preset name (e.g "title").
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Struct.I18nDrawings}
 */
function i18n_get_drawings(preset_name, locale = "", i18n = false) {
	// Guard clause
	if (!(is_string(preset_name) || is_array(preset_name))) {
		show_debug_message($"I18n ERROR - i18n_get_drawings({preset_name}, {locale}) - `preset_name` must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_drawings({preset_name}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_drawings({preset_name}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Use current locale if empty
	if (locale == "") {
		locale = i18n.locale;
	}

	if (!is_array(preset_name)) {
		preset_name = [preset_name];
	}

	var result = [];

	if (struct_exists(i18n.data, locale)) {
		for (var i = 0; i < array_length(preset_name); i++) {
			if (struct_exists(i18n.data[$ locale].drawings, preset_name[i])) {
				array_push(result, i18n.data[$ locale].drawings[$ preset_name[i]]);
			} else if (struct_exists(i18n.data[$ i18n.default_locale].drawings, preset_name[i])) {
				if (i18n.debug) {
					show_debug_message($"I18n WARNING - i18n_get_drawings({preset_name[i]}, {locale}) - \"{preset_name[i]}\" drawing preset doesn't exists in current locale, using default locale instead");
				}
				
				array_push(result, i18n.data[$ i18n.default_locale].drawings[$ preset_name[i]]);
			} else {
				if (i18n.debug) {
					show_debug_message($"I18n WARNING - i18n_get_drawings({preset_name[i]}, {locale}) - \"{preset_name[i]}\" drawing preset doesn't exists, using default drawing preset instead");
				}

				array_push(result, new I18nDrawings());
			}
		}

		return ((array_length(result) == 1) ? result[0] : result);
	}
	
	show_debug_message($"I18n ERROR - i18n_get_drawings({preset_name}, {locale}) - \"{locale}\" locale doesn't exists");
	return (new I18nDrawings());
}


/**
 * @desc Get drawing data from a preset
 * @param {String} preset_name Drawing preset name (e.g "title").
 * @param {Constant.I18N_DRAWING} type Drawing data type (e.g I18N_DRAWING.FONT).
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Any}
 */
function i18n_get_drawings_data(preset_name, type, locale = "", i18n = false) {
	// Guard clause
	if (!is_string(preset_name)) {
		show_debug_message($"I18n ERROR - i18n_get_drawings_data({preset_name}, {type}, {locale}) - `preset_name` must be a string");
		exit;
	}

	if (!is_numeric(type)) {
		show_debug_message($"I18n ERROR - i18n_get_drawings_data({preset_name}, {type}, {locale}) - `type` must be a I18N_DRAWING constant");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_drawings_data({preset_name}, {type}, {locale}) - `locale` must be a string");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_drawings_data({preset_name}, {type}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}
	
	// Return the drawing data
	var names = ["font", "halign", "valign", "color", "scale", "rotation", "alpha", "sep", "width"];
	type = min(array_length(names) - 1, round(type));

	if (struct_exists(i18n.data[$ locale].drawings, preset_name)) {
		return i18n.data[$ locale].drawings[$ preset_name][$ names[type]];
	} else if (struct_exists(i18n.data[$ i18n.default_locale].drawings, preset_name)) {
		if (i18n.debug) {
			show_debug_message($"I18n WARNING - i18n_get_drawings_data({preset_name}, {type}, {locale}) - \"{preset_name}\" drawing preset doesn't exists in current locale, using default locale instead");
		}

		return i18n.data[$ locale].drawings[$ i18n.default_locale][$ names[type]];
	} else {
		show_debug_message($"I18n ERROR - i18n_get_drawings_data({preset_name}, {type}, {locale}) - \"{preset_name}\" drawing preset doesn't exists");
		return;
	}
}


/**
 * @desc Create a reference to a message for a dynamic translations
 * @param {String} var_name This variable name (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {String} key Message key (e.g. "hello").
 * @param {Array<Any> | Struct | Real | Undefined} [data] The additional data for the message. Array (index-based) = [val1, val2, ...], or Struct (name-based) = {key1: val1, key2: val2, ... [, child: {key1: val1, ...}]} (child struct need to be set if it's an interpolation and it have additional data), or Real (pluralization) = number.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {String}
 */
function i18n_create_ref_message(var_name, key, data = undefined, i18n = false) {
	// Guard clause
	if (!is_string(var_name)) {
		show_debug_message($"I18n ERROR - i18n_create_ref_message({var_name}, {key}, {data}) - `var_name` must be a string");
		exit;
	}

	if (!is_string(key)) {
		show_debug_message($"I18n ERROR - i18n_create_ref_message({var_name}, {key}, {data}) - `key` must be a string");
		exit;
	}
	
	if (!is_undefined(data) && !(is_real(data) || is_array(data) || is_struct(data))) {
		show_debug_message($"I18n ERROR - i18n_create_ref_message({var_name}, {key}, {data}) - `data` must be an integer, an array, or a struct");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_create_ref_message({var_name}, {key}, {data}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}
										
	// Check if it's a global variable
	var name_split = string_split(var_name, ".", true);	

	if (name_split[0] == "global" || name_split[0] == "g") {
		array_push(i18n.refs.messages.inst, "global");
	} else {
		array_push(i18n.refs.messages.inst, id);
	}

	// Push the reference data
	array_push(i18n.refs.messages.refs, var_name);
	array_push(i18n.refs.messages.keys, key);
	array_push(i18n.refs.messages.data, data);

	return i18n_get_messages(key, data, i18n.locale, i18n, true);
}


/**
 * @desc Create a reference to an asset for an unique asset for each locale
 * @param {String} var_name This variable name (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {Struct} locale_asset Struct of localized asset (e.g. {en: sprSplashEn, fr: sprSplashFr, ...}).
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Any}
 */
function i18n_create_ref_asset(var_name, locale_asset, i18n = false) {
	// Guard clause
	if (!is_string(var_name)) {
		show_debug_message($"I18n ERROR - i18n_create_ref_asset({var_name}, {locale_asset}) - `var_name` must be a string");
		exit;
	}

	if (!is_struct(locale_asset)) {
		show_debug_message($"I18n ERROR - i18n_create_ref_asset({var_name}, {locale_asset}) - `locale_asset` must be a struct");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_create_ref_message({var_name}, {locale_asset}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Check if the locale asset is valid
	var asset_keys = struct_get_names(locale_asset);
	var asset_type = asset_unknown;

	for (var i = 0; i < array_length(asset_keys); i++) {
		if (asset_type == asset_unknown) {
			asset_type = asset_get_type(locale_asset[$ asset_keys[i]]);
		}
		
		if (asset_type != asset_get_type(locale_asset[$ asset_keys[i]])) {
			show_debug_message($"I18n ERROR - i18n_create_ref_asset({var_name}, {locale_asset}) - All assets must be the same asset type");
			exit;
		}
	}
										
	// Check if it's a global variable
	var name_split = string_split(var_name, ".", true);	

	if (name_split[0] == "global" || name_split[0] == "g") {
		array_push(i18n.refs.assets.inst, "global");
	} else {
		array_push(i18n.refs.assets.inst, id);
	}

	// Push the reference data
	array_push(i18n.refs.assets.refs, var_name);
	array_push(i18n.refs.assets.assets, locale_asset);

	return ((struct_exists(locale_asset, i18n.locale)) ? locale_asset[$ i18n.locale] : ((struct_exists(locale_asset, i18n.default_locale)) ? locale_asset[$ i18n.default_locale] : noone));
}


/**
 * @desc (INTERNAL) Get a reference to a message 
 * @param {Real} index The index of the reference.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Any}
 */
function i18n_get_ref_message(index, i18n = false) {
	// Guard clause
	if (!is_real(index)) {
		show_debug_message($"I18n ERROR - i18n_get_ref_message({index}) - `index` must be a real");
		exit;
	}
	index = round(index);

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_create_ref_message({index}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}
	
	// Track the message reference based on the index
	var root_ref = i18n.refs.messages.inst[index];
	var current_ref = root_ref;
	var name_split = string_split(i18n.refs.messages.refs[index], ".", true);
	var to_update = name_split[array_length(name_split) - 1];

	for (var i = ((root_ref == "global")); i < (array_length(name_split) - 1); i++) {
		if (string_digits(name_split[i]) != "" && string_letters(name_split[i]) == "") {
			show_debug_message($"I18n ERROR - i18n_get_ref_message({index}) - An array is only supported at the last reference level");
			break;
		}
		
		if (root_ref == "global") {					// e.g ref = "global.text"
			if (!is_struct(current_ref)) {
				if (!variable_global_exists(name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message({index}) - \"{name_split[i]}\" global variable doesn't exist");
					break;
				}
			} else {
				if (!struct_exists(current_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message({index}) - \"{name_split[i]}\" member doesn't exist in the \"{current_ref}\" struct");
					break;
				}
			}

			current_ref = (i == 1) ? variable_global_get(name_split[i]) : current_ref[$ name_split[i]];
		} else {
			if (!is_struct(current_ref)) {
				if (!variable_instance_exists(root_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message({index}) - \"{name_split[i]}\" variable doesn't exist in the \"{root_ref}\" instance");
					break;
				}
			} else {
				if (!struct_exists(current_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message({index}) - \"{name_split[i]}\" member doesn't exist in the \"{current_ref}\" struct");
					break;
				}
			}
			
			current_ref = (i == 0) ? variable_instance_get(root_ref, name_split[i]) : current_ref[$ name_split[i]];
		}
	}

	return current_ref;
}


/**
 * @desc (INTERNAL) Get a reference to an asset
 * @param {Real} index The index of the reference.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Any}
 */
function i18n_get_ref_asset(index, i18n = false) {
	// Guard clause
	if (!is_real(index)) {
		show_debug_message($"I18n ERROR - i18n_get_ref_asset({index}) - `index` must be a real");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_ref_asset({index}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Track the asset reference based on the index
	var root_ref = i18n.refs.assets.inst[index];
	var current_ref = root_ref;
	var name_split = string_split(i18n.refs.assets.refs[index], ".", true);
	var to_update = name_split[array_length(name_split) - 1];

	for (var i = ((root_ref == "global")); i < (array_length(name_split) - 1); i++) {
		if (string_digits(name_split[i]) != "" && string_letters(name_split[i]) == "") {
			show_debug_message($"I18n ERROR - i18n_get_ref_asset({index}) - An array is only supported at the last reference level");
			break;
		}

		if (root_ref == "global") {					// e.g ref = "global.text"
			if (!is_struct(current_ref)) {
				if (!variable_global_exists(name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_asset({index}) - \"{name_split[i]}\" global variable doesn't exist");
					break;
				}
			} else {
				if (!struct_exists(current_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_asset({index}) - \"{name_split[i]}\" member doesn't exist in the \"{current_ref}\" struct");
					break;
				}
			}

			current_ref = (i == 1) ? variable_global_get(name_split[i]) : current_ref[$ name_split[i]];
		} else {
			if (!is_struct(current_ref)) {
				if (!variable_instance_exists(root_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_asset({index}) - \"{name_split[i]}\" variable doesn't exist in the \"{root_ref}\" instance");
					break;
				}
			} else {
				if (!struct_exists(current_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_asset({index}) - \"{name_split[i]}\" member doesn't exist in the \"{current_ref}\" struct");
					break;
				}
			}
			
			current_ref = (i == 0) ? variable_instance_get(root_ref, name_split[i]) : current_ref[$ name_split[i]];
		}
	}

	return current_ref;
}


/**
 * @desc Update all created references
 * @param {Constant.I18N_REF} [type]=I18N_REF.ALL The type of reference to update (e.g. I18N_REF.MESSAGES).
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_refs(type = I18N_REF.ALL, i18n = false) {
	// Guard clause
	if (!is_numeric(type)) {
		show_debug_message($"I18n ERROR - i18n_update_refs({type}) - `type` must be a I18N_REF constant");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_update_refs({type}) - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	var type_str = ["", "messages", "assets"];
	var types = (type == I18N_REF.ALL) ? struct_get_names(i18n.refs) : [type_str[type]];
	
	for (var i = 0; i < array_length(types); i++) {
		var to_delete = [];

		for (var j = 0; j < array_length(i18n.refs[$ types[i]].inst); j++) {
			var root_ref = i18n.refs[$ types[i]].inst[j];
			var current_ref = i18n.refs[$ types[i]].inst[j];
			var name_split = string_split(i18n.refs[$ types[i]].refs[j], ".", true);
			var to_update = name_split[array_length(name_split) - 1];
			var index = 0;

			// Guard clauses
			if (root_ref == "global") {						// e.g ref = "global.text"
				if (array_length(name_split) < 2) {
					show_debug_message($"I18n ERROR - i18n_update_refs({type}) - Global variable member hasn't been specified");
					array_push(to_delete, j);
					continue;
				}
			} else if (!instance_exists(root_ref)) {		// e.g ref = "text"
				array_push(to_delete, j);
				continue;
			}
			
			// Update references
			switch (types[i]) {
				case "messages":
					// Track valid references
					current_ref = i18n_get_ref_message(j, i18n);

					// Update all references with the new message
					var localized_message = i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n);

					if (root_ref == "global") {
						if (array_length(name_split) == 2) {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								show_debug_message($"I18n ERROR - i18n_update_refs({type}) - An array isn't supported as a global variable member");
								continue;
							}

							variable_global_set(to_update, localized_message);
						} else {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								index = real(to_update);
								current_ref[index] = localized_message;
							} else {
								current_ref[$ to_update] = localized_message;
							}
						}
					} else {
						if (array_length(name_split) == 1) {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								show_debug_message(name_split)
								show_debug_message($"I18n ERROR - i18n_update_refs({type}) - An array isn't supported as an instance variable member");
								continue;
							}

							variable_instance_set(root_ref, to_update, localized_message);
						} else {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								index = real(to_update);
								current_ref[index] = localized_message;
							} else {
								current_ref[$ to_update] = localized_message;
							}
						}
					}
					break;

				case "assets":
					// Track valid references
					current_ref = i18n_get_ref_asset(j, i18n);
					
					// Get the localized asset
					var localized_asset = (struct_exists(i18n.refs[$ types[i]].assets[j], i18n.locale)) ? i18n.refs[$ types[i]].assets[j][$ i18n.locale] : noone;

					if (localized_asset == noone) {
						if (struct_exists(i18n.refs[$ types[i]].assets[j], i18n.default_locale)) {
							localized_asset = i18n.refs[$ types[i]].assets[j][$ i18n.default_locale];

							if (i18n.debug) {
								show_debug_message($"I18n WARNING - i18n_update_refs({type}) - \"{i18n.refs[$ types[i]].refs[j]}\" ref doesn't have an asset for the \"{i18n.locale}\" locale, using \"{i18n.default_locale}\" locale instead");
							}
						} else if (i18n.debug) {
							show_debug_message($"I18n ERROR - i18n_update_refs({type}) - \"{i18n.refs[$ types[i]].refs[j]}\" ref doesn't have an asset for the \"{i18n.locale}\" and \"{i18n.default_locale}\" locales, skipping this reference");
							continue;
						}
					}

					// Update all references with the new asset
					if (root_ref == "global") {
						if (array_length(name_split) == 2) {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								show_debug_message($"I18n ERROR - i18n_update_refs({type}) - An array isn't supported as a global variable member");
								continue;
							}

							variable_global_set(to_update, localized_asset);
						} else {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								index = real(to_update);
								current_ref[index] = localized_asset;
							} else {
								current_ref[$ to_update] = localized_asset;
							}
						}
					} else {
						if (array_length(name_split) == 1) {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								show_debug_message(name_split)
								show_debug_message($"I18n ERROR - i18n_update_refs({type}) - An array isn't supported as an instance variable member");
								continue;
							}

							variable_instance_set(root_ref, to_update, localized_asset);
						} else {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								index = real(to_update);
								current_ref[index] = localized_asset;
							} else {
								current_ref[$ to_update] = localized_asset;
							}
						}
					}
					break;
			}
		}

		// Delete invalid refs
		for (var j = array_length(to_delete) - 1; j >= 0; j--) {
			array_delete(i18n.refs[$ types[i]].inst, to_delete[j], 1);
			array_delete(i18n.refs[$ types[i]].refs, to_delete[j], 1);

			if (struct_exists(i18n.refs[$ types[i]], "keys")) {
				array_delete(i18n.refs[$ types[i]].keys, to_delete[j], 1);
			}

			if (struct_exists(i18n.refs[$ types[i]], "data")) {
				array_delete(i18n.refs[$ types[i]].data, to_delete[j], 1);
			}

			if (struct_exists(i18n.refs[$ types[i]], "assets")) {
				array_delete(i18n.refs[$ types[i]].assets, to_delete[j], 1);
			}
		}
	}
}


/**
 * @desc Update pluralization value on reference(s)
 * @param {String} var_name Variable name based on the var_name in i18n_create_ref_message() (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {Real} value The new pluralization value (e.g. 1).
 * @param {Bool} [update_refs]=false Update i18n references.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_plurals(var_name, value, update_refs = false, i18n = false) {
	// Guard clause
	if (!is_string(var_name)) {
		show_debug_message($"I18n ERROR - i18n_update_plurals({var_name}, {value}, {update_refs}) - `var_name` must be a string");
		exit;
	}

	if (!is_real(value)) {
		show_debug_message($"I18n ERROR - i18n_update_plurals({var_name}, {value}, {update_refs}) - `value` must be a real");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_update_plurals({var_name}, {value}, {update_refs}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}
	
	// Check if reference(s) exists, and store the index of the reference
	var ref_index = -1;
	var ref_match = false;
	
	for (var i = 0; i < array_length(i18n.refs.messages.refs); i++) {
		if (string_pos(i18n.refs.messages.refs[i], var_name) != 0) {
			ref_index = i;

			if (i18n.refs.messages.refs[i] == var_name) {
				ref_match = true;
			}
			break;
		}
	}

	if (ref_index == -1) {
		show_debug_message($"I18n ERROR - i18n_update_plurals({var_name}, {value}, {update_refs}) - `{var_name}` reference doesn't exist");
		exit;
	}

	// Update pluralization value
	var target_ref = i18n.refs.messages.data[ref_index];

	if (is_real(target_ref)) {
		target_ref = value;
	} else if (is_struct(target_ref)) {
		if (struct_exists(target_ref, "plural")) {
			if (struct_exists(target_ref, "plural_value")) {	// Custom pluralization value (using method)
				target_ref.plural_value = value;
			} else {											// Default pluralization value (using index)
				target_ref.plural = value;
			}
		} else {
			show_debug_message($"I18n ERROR - i18n_update_plurals({var_name}, {value}, {update_refs}) - `{i18n.refs.messages.data[ref_index]}` struct doesn't have a plural member");
		}
	} else {
		show_debug_message($"I18n ERROR - i18n_update_plurals({var_name}, {value}, {update_refs}) - Data at index {ref_index} isn't a real or struct");
	}

	// Update i18n references
	if (update_refs) {
		i18n_update_refs(I18N_REF.MESSAGES, i18n);
	}
}


/**
 * @desc Get a static message that created using i18n_create_ref_message()
 * @param {String} var_name Variable name based on the var_name in i18n_create_ref_message() (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {String | Id.Instance | Asset.GMObject} [ref]="" Reference name or instance id based on the ref in i18n_create_ref_message() (e.g. "text"). Recommended to pass "global" if the reference is created in a global variable, or instance id if the reference is created in an instance.
 * @param {String} [locale]="" Locale code (e.g "en"). Leave it empty to get the message in the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {String}
 */
function i18n_get_message_from_ref(var_name, ref = "", locale = "", i18n = false) {
	// Guard clause
	if (!is_string(var_name)) {
		show_debug_message($"I18n ERROR - i18n_get_message_from_ref({var_name}, {ref}, {locale}) - `var_name` must be a string");
		exit;
	}

	if (!(is_string(ref) || typeof(ref) == "ref")) {
		show_debug_message($"I18n ERROR - i18n_get_message_from_ref({var_name}, {ref}, {locale}) - `ref` must be a string, instance id, or asset id");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_message_from_ref({var_name}, {ref}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_message_from_ref({var_name}, {ref}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}

	// Check if reference(s) exists, and store the index of the reference
	var ref_index = -1;

	if (is_string(ref)) {
		if (ref == "g") {
			ref = "global";
		} else if (asset_get_index(ref) != -1) {
			ref = asset_get_index(ref);
		} else {
			ref = "";

			if (i18n.debug) {
				show_debug_message($"I18n WARNING - i18n_get_message_from_ref({var_name}, {ref}, {locale}) - `{ref}` reference doesn't exist, using the first matching `var_name` instead");
			}
		}
	} else if (!instance_exists(ref)) {
		ref = "";

		if (i18n.debug) {
			show_debug_message($"I18n WARNING - i18n_get_message_from_ref({var_name}, {ref}, {locale}) - `{ref}` instance/asset doesn't exist, using the first matching `var_name` instead");
		}
	}
	
	for (var i = 0; i < array_length(i18n.refs.messages.refs); i++) {
		if (((ref == "") || (ref == i18n.refs.messages.inst[i])) && (var_name == i18n.refs.messages.refs[i])) {
			ref_index = i;
			break;
		}
	}

	if (ref_index == -1) {
		show_debug_message($"I18n ERROR - i18n_get_message_from_ref({var_name}, {ref}, {locale}) - `{var_name}` reference doesn't exist");
		return "";
	}

	// Return the message
	return i18n_get_messages(i18n.refs.messages.keys[ref_index], i18n.refs.messages.data[ref_index], locale, i18n);
}


/**
 * @desc Get a static asset that created using i18n_create_ref_asset()
 * @param {String} var_name Variable name based on the var_name in i18n_create_ref_asset() function (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {String | Id.Instance | Asset.GMObject} [ref]="" Reference name or instance id based on the ref in i18n_create_ref_asset() function. Recommended to pass "global" if the reference is created in a global variable, or instance id if the reference is created in an instance.
 * @param {String} [locale]="" Locale code (e.g "en"). Leave it empty to get the asset in the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Struct | undefined}
 */
function i18n_get_asset_from_ref(var_name, ref = "", locale = "", i18n = false) {
	// Guard clause
	if (!is_string(var_name)) {
		show_debug_message($"I18n ERROR - i18n_get_asset_from_ref({var_name}, {ref}, {locale}) - `var_name` must be a string");
		exit;
	}

	if (!(is_string(ref) || typeof(ref) == "ref")) {
		show_debug_message($"I18n ERROR - i18n_get_asset_from_ref({var_name}, {ref}, {locale}) - `ref` must be a string, instance id, or asset id");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_asset_from_ref({var_name}, {ref}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_asset_from_ref({var_name}, {ref}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}

	// Check if reference(s) exists, and store the index of the reference
	var ref_index = -1;
	
	if (is_string(ref)) {
		if (ref == "g") {
			ref = "global";
		} else if (asset_get_index(ref) != -1) {
			ref = asset_get_index(ref);
		} else {
			ref = "";

			if (i18n.debug) {
				show_debug_message($"I18n WARNING - i18n_get_asset_from_ref({var_name}, {ref}, {locale}) - `{ref}` reference doesn't exist, using the first matching `var_name` instead");
			}
		}
	} else if (!instance_exists(ref)) {
		ref = "";

		if (i18n.debug) {
			show_debug_message($"I18n WARNING - i18n_get_asset_from_ref({var_name}, {ref}, {locale}) - `{ref}` instance/asset doesn't exist, using the first matching `var_name` instead");
		}
	}
	
	for (var i = 0; i < array_length(i18n.refs.assets.refs); i++) {
		if (((ref == "") || (ref == i18n.refs.assets.inst[i])) && (var_name == i18n.refs.assets.refs[i])) {
			ref_index = i;
			break;
		}
	}

	if (ref_index == -1) {
		show_debug_message($"I18n ERROR - i18n_get_asset_from_ref({var_name}, {ref}, {locale}) - `{var_name}` reference doesn't exist");
		return undefined;
	}

	// Return the asset
	return i18n.refs.assets.assets[ref_index];
}


/**
 * @desc Set default message
 * @param {String} message Default message.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_set_default_message(message, i18n = false) {
	// Guard clause
	if (!is_string(message)) {
		show_debug_message($"I18n ERROR - i18n_set_default_message({message}) - `message` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_set_default_message({message}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	i18n.default_message = message;
}


/**
 * @desc Change current locale
 * @param {String} code Locale code (e.g. "en").
 * @param {Bool} [update_refs]=true Update i18n references.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_set_locale(code, update_refs = true, i18n = false) {
	// Guard clause
	if (!is_string(code)) {
		show_debug_message($"I18n ERROR - i18n_set_locale({code}, {update_refs}) - `code` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_set_locale({code}, {update_refs}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!struct_exists(i18n.data, code)) {
		show_debug_message($"I18n ERROR - i18n_set_locale({code}, {update_refs}) - \"{code}\" locale doesn't exists");
		exit;
	}

	// Update locale
	i18n.locale = code;

	// Update i18n references
	if (update_refs) {
		i18n_update_refs(I18N_REF.ALL, i18n);
	}
}


/**
 * @desc Use a drawing preset
 * @param {String} preset_name Drawing preset name (e.g "title").
 * @param {String} [locale]="" Locale code (e.g "en"). Leave it empty to mark it as dynamic locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Struct | undefined}
 */
function i18n_use_drawing(preset_name, locale = "", i18n = false) {
	// Guard clause
	if (!is_string(preset_name)) {
		show_debug_message($"I18n ERROR - i18n_use_drawing({preset_name}, {locale}) - `preset_name` must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_use_drawing({preset_name}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_use_drawing({preset_name}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}
	
	// Set available drawing type
	if (struct_exists(i18n.data[$ locale].drawings, preset_name)) {
		var preset = i18n.data[$ locale].drawings[$ preset_name];
		
		if (is_numeric(preset.font)) {
			if (font_exists(preset.font)) {
				draw_set_font(preset.font);
			}
		}

		if (!is_undefined(preset.halign)) {
			draw_set_halign(preset.halign);
		}

		if (!is_undefined(preset.valign)) {
			draw_set_valign(preset.valign);
		}

		if (!is_undefined(preset.color)) {
			draw_set_color(preset.color);
		}

		if (!is_undefined(preset.alpha)) {
			draw_set_alpha(preset.alpha);
		}

		return preset;
	} 

	show_debug_message($"I18n ERROR - i18n_use_drawing({preset_name}, {locale}) - \"{preset_name}\" drawing preset doesn't exists");

	return undefined;
}


/**
 * @desc Draw message with a drawing preset
 * @param {Real} x X position.
 * @param {Real} y Y position.
 * @param {String} text The text to draw. Can be any text, including message from i18n_get_message() (e.g. "Hello World!"), or a message reference variable (created by i18n_create_ref_message()). Use "@:" prefix to use this as message key (e.g. "@:hello").
 * @param {Real | Array<Any> | undefined} [data] Data to pass to the message (e.g. 1, ["Hello World!"]). Struct isn't supported in this function.
 * @param {String} [preset_name]="" Drawing preset name to use (e.g "title").
 * @param {String} [locale]="" Locale code (e.g "en"). Leave it empty to mark it as dynamic locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_draw_message(x, y, text, data = undefined, preset_name = "", locale = "", i18n = false) {
	// Guard clauses
	if (!(is_real(x) || is_real(y))) {
		show_debug_message($"I18n ERROR - i18n_draw_message({x}, {y}, {text}, {data}, {preset_name}, {locale}) - `x` and `y` must be a real");
		exit;
	}

	if (!is_string(text)) {
		show_debug_message($"I18n ERROR - i18n_draw_message({x}, {y}, {text}, {data}, {preset_name}, {locale}) - `text` must be a string");
		exit;
	}

	if (!is_undefined(data) && !(is_real(data) || is_array(data))) {
		show_debug_message($"I18n ERROR - i18n_draw_message({x}, {y}, {text}, {data}, {preset_name}, {locale}) - `data` must be a real or array");
		exit;
	}

	if (!is_string(preset_name)) {
		show_debug_message($"I18n ERROR - i18n_draw_message({x}, {y}, {text}, {data}, {preset_name}, {locale}) - `preset_name` must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_draw_message({x}, {y}, {text}, {data}, {preset_name}, {locale}) - `locale` must be a string");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_draw_message({x}, {y}, {text}, {data}, {preset_name}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}
	
	if (locale == "") {
		locale = i18n.locale;
	}

	// Get message text
	if (string_pos("@:", text) == 1) {
		var key = string_copy(text, 3, string_length(text) - 2);
		var cache_name = string("{0}_{1}_{2}", locale, key, data);
		var cache_id = variable_get_hash(cache_name);
		
		if (i18n.cached) {
			if (array_contains(i18n.cache.ids, cache_id)) {				// with data
				text = i18n_use_cache(cache_id, i18n);
			} else {
				cache_name = string("{0}_{1}", locale, key);
				cache_id = variable_get_hash(cache_name);

				if (array_contains(i18n.cache.ids, cache_id)) {			// without data
					text = i18n_use_cache(cache_id, i18n);
				} else {
					text = i18n_get_messages(key, data, locale, i18n, !struct_exists(i18n, "loader"));
				}
			}
		} else {
			text = i18n_get_messages(key, data, locale, i18n);
		}
	}

	// Apply drawing preset if provided
	var preset_data = -1;

	if (preset_name != "") {
		if (!struct_exists(i18n.data[$ locale].drawings, preset_name)) {
			show_debug_message($"I18n ERROR - i18n_draw_message({x}, {y}, {text}, {data}, {preset_name}, {locale}) - \"{preset_name}\" drawing preset doesn't exists, no drawing will be applied");
		} else {
			preset_data = i18n.data[$ locale].drawings[$ preset_name];
			
			if (is_numeric(preset_data.font)) {
				if (font_exists(preset_data.font)) {
					draw_set_font(preset_data.font);
				}
			}

			if (!is_undefined(preset_data.halign)) {
				draw_set_halign(preset_data.halign);
			}

			if (!is_undefined(preset_data.valign)) {
				draw_set_valign(preset_data.valign);
			}

			if (!is_undefined(preset_data.color)) {
				if (!is_array(preset_data.color)) {
					draw_set_color(preset_data.color);
				}
			}

			if (!is_undefined(preset_data.alpha)) {
				draw_set_alpha(preset_data.alpha);
			}
		}
	}
	
	// Draw message
	if (preset_data == -1) {
		draw_text(x, y, text);
	} else {
		switch (preset_data.draw_type) {
			case I18N_DRAW_TEXT.NORMAL:
				draw_text(x, y, text);
				break;
				
			case I18N_DRAW_TEXT.EXTENDED:
				draw_text_ext(x, y, text, 
					preset_data.sep, 
					preset_data.width
				);
				break;
				
			case I18N_DRAW_TEXT.COLORED:
				draw_text_colour(x, y, text, 
					preset_data.color[0], 
					preset_data.color[1], 
					preset_data.color[2], 
					preset_data.color[3], 
					(preset_data.is_template ? draw_get_alpha() : preset_data.alpha)
				);
				break;

			case I18N_DRAW_TEXT.TRANSFORMED:
				draw_text_transformed(x, y, text, 
					preset_data.scale, 
					preset_data.scale, 
					preset_data.rotation
				);
				break;
				
			case I18N_DRAW_TEXT.EXT_COLORED:
				draw_text_ext_colour(x, y, text, 
					preset_data.sep, 
					preset_data.width, 
					preset_data.color[0], 
					preset_data.color[1], 
					preset_data.color[2], 
					preset_data.color[3], 
					(preset_data.is_template ? draw_get_alpha() : preset_data.alpha)
				);
				break;
				
			case I18N_DRAW_TEXT.EXT_TRANSFORMED:
				draw_text_ext_transformed(x, y, text, 
					preset_data.sep, 
					preset_data.width,
					preset_data.scale, 
					preset_data.scale, 
					preset_data.rotation
				);
				break;

			case I18N_DRAW_TEXT.TRANSFORMED_COLORED:
				draw_text_transformed_colour(x, y, text, 
					preset_data.scale, 
					preset_data.scale, 
					preset_data.rotation,
					preset_data.color[0], 
					preset_data.color[1], 
					preset_data.color[2], 
					preset_data.color[3], 
					(preset_data.is_template ? draw_get_alpha() : preset_data.alpha)
				);
				break;

			case I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED:
				draw_text_ext_transformed_colour(x, y, text, 
					preset_data.sep, 
					preset_data.width,
					preset_data.scale, 
					preset_data.scale, 
					preset_data.rotation,
					preset_data.color[0], 
					preset_data.color[1], 
					preset_data.color[2], 
					preset_data.color[3], 
					(preset_data.is_template ? draw_get_alpha() : preset_data.alpha)
				);
				break;
		}
	}
}


/**
 * @desc Choose the correct data from a struct based on the locale
 * @param {Struct} data The available data to choose from (e.g. {en: "Choose me!", fr: "Choisissez-moi!"})
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool} [single_use]=false If true, delete the `data` struct after use.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @return {Any}
 */
function i18n_choose(data, locale = "", single_use = false, i18n = false) {
	// Guard clause
	if (!is_struct(data)) {
		show_debug_message($"I18n ERROR - i18n_choose({data}, {locale}, {single_use}) - `data` must be struct");
		return "";
	}
	if (!is_bool(single_use)) {
		show_debug_message($"I18n ERROR - i18n_choose({data}, {locale}, {single_use}) - `single_use` must be boolean");
		return "";
	}
	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_choose({data}, {locale}, {single_use}) - `locale` must be string");
		return "";
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_choose({name}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}

	// Choose the correct data
	if (!struct_exists(data, locale)) {
		if (struct_exists(data, i18n.default_locale)) {
			locale = i18n.default_locale;
			if (i18n.debug) {
				show_debug_message($"I18n WARNING - i18n_choose({data}, {locale}, {single_use}) - `{locale}` locale not found, using default locale `{i18n.default_locale}` instead");
			}
		} else {
			if (i18n.debug) {
				show_debug_message($"I18n WARNING - i18n_choose({data}, {locale}, {single_use}) - `{locale}` locale and `{i18n.default_locale}` default locale not found, returning empty string");
			}
			return "";
		}
	}

	if (single_use) {
		delete data;
	}
	
	return data[$ locale];
}


/**
 * @desc Check if cache exists in I18n system
 * @param {Real} cache_id Id of the cache (e.g. variable_get_hash("my_cache")).
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @return {Bool}
 */
function i18n_cache_exists(cache_id, i18n = false) {
	// Guard clause
	if (!is_numeric(cache_id)) {
		show_debug_message($"I18n ERROR - i18n_cache_exists({cache_id}) - `cache_id` must be a number");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_cache_exists({cache_id}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = i18n_global;
	}

	// Check if cache exists
	return array_contains(i18n.cache.ids, cache_id);
}


/**
 * @desc Get cache id for a message in I18n system
 * @param {String} key Message key used to access the cache (e.g. "hello").
 * @param {Array<Any> | Struct | Real | Undefined} [data] The additional data for the message. Array (index-based) = [val1, val2, ...], or Struct (name-based) = {key1: val1, key2: val2, ... [, child: {key1: val1, ...}]}, or Real (pluralization).
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Real}
 */
function i18n_get_cache_id(key, data = undefined, locale = "", i18n = false) {
	// Guard clause
	if (!is_string(key)) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id({key}, {data}, {locale}) - `key` must be a string");
		exit;
	}

	if (!is_undefined(data) && !(is_array(data) || is_struct(data) || is_real(data))) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id({key}, {data}, {locale}) - `data` must be an array, struct, or real");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id({key}, {data}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id({key}, {data}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return variable_get_hash(string("{0}_{1}_{2}", locale, key, data));
} 


/**
 * @desc Get the cache id for a message reference in I18n system
 * @param {String} var_name Variable name based on the var_name in i18n_create_ref_message() (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {String | Id.Instance | Asset.GMObject} [ref]="" Reference name or instance id based on the ref in i18n_create_ref_message() (e.g. "text"). Recommended to pass "global" if the reference is created in a global variable, or instance id if the reference is created in an instance.
 * @param {String} [locale]="" Locale code (e.g "en"). Leave it empty to get the message in the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Real}
 */
function i18n_get_cache_id_from_ref(var_name, ref = "", locale = "", i18n = false) {
	// Guard clauses
	if (!is_string(var_name)) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id_from_ref({var_name}, {ref}, {locale}) - `var_name` must be a string");
		exit;
	}

	if (!(is_string(ref) || typeof(ref) == "ref")) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id_from_ref({var_name}, {ref}, {locale}) - `ref` must be a string, instance id, or asset id");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id_from_ref({var_name}, {ref}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id_from_ref({var_name}, {ref}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}

	// Check if the reference exists, and store the index of the reference
	var ref_index = -1;

	if (is_string(ref)) {
		if (ref == "g") {
			ref = "global";
		} else if (asset_get_index(ref) != -1) {
			ref = asset_get_index(ref);
		} else {
			ref = "";

			if (i18n.debug) {
				show_debug_message($"I18n WARNING - i18n_get_cache_id_from_ref({var_name}, {ref}, {locale}) - `{ref}` asset doesn't exist, using the first matching `var_name` instead");
			}
		}
	} else if (!instance_exists(ref)) {
		ref = "";

		if (i18n.debug) {
			show_debug_message($"I18n WARNING - i18n_get_cache_id_from_ref({var_name}, {ref}, {locale}) - `{ref}` instance/asset doesn't exist, using the first matching `var_name` instead");
		}
	}
	
	for (var i = 0; i < array_length(i18n.refs.messages.refs); i++) {
		if (((ref == "") || (ref == i18n.refs.messages.inst[i])) && (var_name == i18n.refs.messages.refs[i])) {
			ref_index = i;
			break;
		}
	}

	if (ref_index == -1) {
		show_debug_message($"I18n ERROR - i18n_get_cache_id_from_ref({var_name}, {ref}, {locale}) - `{var_name}` reference doesn't exist");
		return 0;
	}

	// Return the cache id
	return variable_get_hash(string("{0}_{1}_{2}", locale, i18n.refs.messages.keys[ref_index], i18n.refs.messages.data[ref_index]));
}


/**
 * @desc Create message cache in I18n system
 * @param {String} key Message key used to access the cache (e.g. "hello").
 * @param {Array<Any> | Struct | Real | Undefined} [data] The additional data for the message. Array (index-based) = [val1, val2, ...], or Struct (name-based) = {key1: val1, key2: val2, ... [, child: {key1: val1, ...}]} (child struct need to be set if it's an interpolation and it have additional data), or Real (pluralization) = number.
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {String} value Direct value to set in cache (e.g. "Hello World!"). Leave it empty to get the value from the message.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_create_cache(key, data = undefined, locale = "", value = "", i18n = false) {
	// Guard clause
	if (!is_string(key)) {
		show_debug_message($"I18n ERROR - i18n_create_cache({key}, {data}, {locale}, {value}) - `key` must be a string");
		exit;
	}

	if (!is_undefined(data) && !(is_array(data) || is_struct(data) || is_real(data))) {
		show_debug_message($"I18n ERROR - i18n_create_cache({key}, {data}, {locale}, {value}) - `data` must be an array, struct, or real");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_create_cache({key}, {data}, {locale}, {value}) - `locale` must be a string");
		exit;
	}
	
	if (!is_string(value)) {
		show_debug_message($"I18n ERROR - i18n_create_cache({key}, {data}, {locale}, {value}) - `value` must be a string");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_create_cache({key}, {value}, {locale}, {value}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Create cache
	if (value = "") {
		value = i18n_get_messages(key, data, locale, i18n, false);
	}

	var cache_id = variable_get_hash(string("{0}_{1}_{2}", locale, key, data));
	
	if (array_length(i18n.cache.ids) == 0) {
		i18n.cache.ids = [cache_id];
		i18n.cache.values = [value];
		i18n.cache.keys = [key];
		i18n.cache.data = [data];
		i18n.cache.locales = [locale];
	} else {
		var index = -1;
		if (!array_contains(i18n.cache.ids, cache_id)) {
			index = binary_search_insert_pos(i18n.cache.ids, cache_id);
			
			array_insert(i18n.cache.ids, index, cache_id);
			array_insert(i18n.cache.values, index, value);
			array_insert(i18n.cache.keys, index, key);
			array_insert(i18n.cache.data, index, data);
			array_insert(i18n.cache.locales, index, locale);
		} else {
			index = array_get_index(i18n.cache.ids, cache_id);
			
			i18n.cache.ids[index] = cache_id;
			i18n.cache.values[index] = value;
			i18n.cache.keys[index] = key;
			i18n.cache.data[index] = data;
			i18n.cache.locales[index] = locale;
		}
	}
}


/**
 * @desc Use the cache in I18n system
 * @param {Real | Array<Real>} cache_id name Id of the cache (e.g. variable_get_hash("my_cache")).
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @return {String | Array<String>}
 */
function i18n_use_cache(cache_id, i18n = false) {
	// Guard clause
	if (!(is_numeric(cache_id) || is_array(cache_id))) {
		show_debug_message($"I18n ERROR - i18n_use_cache({cache_id}) - `cache_id` must be a number or array of number");
		exit;
	}
	if (is_array(cache_id)) {
		for (var i = 0; i < array_length(cache_id); i++) {
			if (!is_numeric(cache_id[i])) {
				show_debug_message($"I18n ERROR - i18n_use_cache({cache_id}) - index {i} of `cache_id` must be a number");
				exit;
			}
		}
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_use_cache({cache_id}, {value}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (is_numeric(cache_id)) {
		cache_id = [cache_id];
	}


	// Get the value
	var result = [];
	var index = 0;
	
	if (array_length(i18n.cache.ids) > 0) {
		for (var i = 0; i < array_length(cache_id); i++) {
			index = array_get_index(i18n.cache.ids, cache_id[i]); 
			array_push(result, index == -1 ? string("{0}_{1}", i18n.cache.locales[i], i18n.cache.keys[i]) : i18n.cache.values[index]);
	
			if (index == -1 && i18n.debug) {
				show_debug_message($"I18n WARNING - i18n_use_cache({cache_id}) - {cache_id[i]} not found in cache");
			}
		}
	}

	return array_length(result) == 1 ? result[0] : result;
}


/**
 * @desc Update the cache in I18n system
 * @param {Real} cache_id name Id of the cache (from i18n_get_cache_id()).
 * @param {String} [value]="" The new value to set in cache (e.g. "Hello World!"). Leave it empty to update the value based on the cached message key and data.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_cache(cache_id, value = "", i18n = false) {
	// Guard clause
	if (!is_numeric(cache_id)) {
		show_debug_message($"I18n ERROR - i18n_update_cache({cache_id}, {value}) - `cache_id` must be string");
		exit;
	}

	if (!is_string(value)) {
		show_debug_message($"I18n ERROR - i18n_update_cache({cache_id}, {value}) - `value` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_update_cache({cache_id}, {value}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Update cache
	var index = array_get_index(i18n.cache.ids, cache_id);

	if (index != -1) {
		if (value == "") {
			value = i18n_get_messages(i18n.cache.keys[index], i18n.cache.data[index], i18n.cache.locales[index], i18n);
		}

		i18n.cache.values[index] = value;

		if (i18n.debug) {
			show_debug_message($"I18n SUCCESS - i18n_update_cache({cache_id}, {value}) - {cache_id} updated in the cache");
		}
	} else if (i18n.debug) {
		show_debug_message($"I18n WARNING - i18n_update_cache({cache_id}, {value}) - {cache_id} not found in the cache, no update done");
	}
}


/**
 * @desc Clear all cache in the I18n system
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_clear_cache(i18n = false) {
	// Guard clause
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_clear_cache() - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	i18n.cache.ids = [];
	i18n.cache.values = [];
	i18n.cache.keys = [];
	i18n.cache.data = [];
	i18n.cache.locales = [];
}


/**
 * @desc Remove messages from the I18n system
 * @param {String | Array<String>} key The key(s) of the message(s) to remove (e.g. "hello" or ["hello", "goodbye"]).
 * @param {String | Array<String>} [locale]="" The locale(s) of the message(s) to remove (e.g. "en" or ["en", "fr"]). Leave it empty to use the current locale, or set it to "all" to remove from all locales.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_remove_messages(key, locale = "", i18n = false) {
	// Guard clause
	if (!(is_string(key) || is_array(key))) {
		show_debug_message($"I18n ERROR - i18n_remove_messages({key}, {locale}) - `key` must be a string or array of string");
		exit;
	}

	if (!(is_string(key) || is_array(key))) {
		show_debug_message($"I18n ERROR - i18n_remove_messages({key}, {locale}) - `locale` must be a string, array of string, or \"all\"");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_remove_messages({key}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Use current locale if empty
	if (locale == "") {
		locale = [i18n.locale];
	} else if (locale == "all") {
		locale = struct_get_names(i18n.data);
	}
	
	if (!is_array(key)) {
		key = [key];
	}
	if (!is_array(locale)) {
		locale = [locale];
	}

	
	for (var i = 0; i < array_length(locale); i++) {
		if (!struct_exists(i18n.data, locale[i])) {
			if (i18n.debug) {
				show_debug_message($"I18n WARNING - i18n_remove_messages({key}, {locale[i]}) - `{locale[i]}` locale not found");
			}
			continue;
		}

		for (var j = 0; j < array_length(key); j++) {
			if (!i18n.hashed) {
				if (struct_exists(i18n.data[$ locale[i]].messages, key[j])) {
					struct_remove(i18n.data[$ locale[i]].messages, key[j]);
				} else if (i18n.debug) {
					show_debug_message($"I18n WARNING - i18n_remove_messages({key[j]}, {locale[i]}) - `{key[j]}` key not found in `{locale[i]}` locale");
				}
			} else {
				if (struct_exists_from_hash(i18n.data[$ locale[i]].messages, variable_get_hash(key[j]))) {
					struct_remove_from_hash(i18n.data[$ locale[i]].messages, variable_get_hash(key[j]));
				} else if (i18n.debug) {
					show_debug_message($"I18n WARNING - i18n_remove_messages({key[j]}, {locale[i]}) - `{key[j]}` key not found in `{locale[i]}` locale");
				}
			}
		}
	}
}


/**
 * @desc Clear all messages in the I18n system for a specific locale or all locales
 * @param {String | Array<String>} [locale]="" The locale(s) to clear (e.g. "en" or ["en", "fr"]). Leave it empty to use the current locale, or set it to "all" to clear all locales.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_clear_messages(locale = "", i18n = false) {
	// Guard clause
	if (!(is_string(locale) || is_array(locale))) {
		show_debug_message($"I18n ERROR - i18n_clear_messages({locale}) - `locale` must be a string, array of string, or \"all\"");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_clear_messages({locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	// Use current locale if empty
	if (locale == "") {
		locale = [i18n.locale];
	} else if (locale == "all") {
		locale = struct_get_names(i18n.data);
	}
	
	if (!is_array(locale)) {
		locale = [locale];
	}

	for (var j = 0; j < array_length(locale); j++) {
		delete i18n.data[$ locale[j]].messages;
		i18n.data[$ locale[j]].messages = {};
		
		if (i18n.debug) {
			show_debug_message($"I18n SUCCESS - i18n_clear_messages({locale[j]}) - `{locale[j]}` locale cleared");
		}
	}
}


/**
 * @desc Flatten a struct into i18n messages
 * @param {Struct} data_struct The struct to flatten (e.g. {hello: "Hello", goodbye: "Goodbye"}).
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @param {String} [prefix]="" (Internal) The prefix to use for the keys (e.g. "greetings"). This is useful for nested structs.
 * @param {Bool} [direct_write]=true If true, write the messages directly to the i18n struct. If false, return the flattened struct.
 * @returns {Undefined | Array<String>}
 */
function i18n_flatten_keys(data_struct, locale = "", i18n = false, prefix = "", direct_write = true) {
	// guard clause
	if (!is_struct(data_struct)) {
		show_debug_message($"I18n ERROR - i18n_flatten_keys({data_struct}, {locale}, , {prefix}) - `data_struct` must be a struct");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_flatten_keys({data_struct}, {locale}, , {prefix}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_flatten_keys({data_struct}, {locale}, , {prefix}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!is_string(prefix)) {
		show_debug_message($"I18n ERROR - i18n_flatten_keys({data_struct}, {locale}, , {prefix}) - `prefix` must be a string");
		exit;
	}

	// Use current locale if empty
	if (locale == "") {
		locale = i18n.locale;
	}

	var names = struct_get_names(data_struct);
	var key = "";
	var result = [];
	
	for (var i = 0; i < array_length(names); i++) {
		key = (prefix == "") ? names[i] : string($"{prefix}.{names[i]}");
		
		if (direct_write) {
			if (is_struct(data_struct[$ names[i]])) {
				i18n_flatten_keys(data_struct[$ names[i]], locale, i18n, key, direct_write);
			} else {
				if (!i18n.hashed) {
					i18n.data[$ locale].messages[$ key] = data_struct[$ names[i]];
				} else {
					struct_set_from_hash(i18n.data[$ locale].messages, variable_get_hash(key), data_struct[$ names[i]]);
				}
			} 
		} else {
			if (is_struct(data_struct[$ names[i]])) {
				result = array_concat(result, i18n_flatten_keys(data_struct[$ names[i]], locale, i18n, key, direct_write));
			} else {
				array_push(result, key);
			}
		}
	}

	if (!direct_write) {
		return result;
	}
}


/**
 * @desc Load messages from JSON files into the I18n system
 * @param {String | Array<String>} file The JSON file(s) to load (e.g. "en.json" or ["en1.json", "en2.json"]).
 * @param {String} [locale]="" The locale that you want to load the messages for (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_load_messages(file, locale = "", i18n = false) {
	// Guard clause
	if (!(is_string(file) || is_array(file))) {
		show_debug_message($"I18n ERROR - i18n_load_messages({file}, {locale}) - `file` must be a string or array of string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_load_messages({file}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_load_messages({file}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!is_array(file)) {
		file = [file];
	}

	// Use current locale if empty
	if (locale == "") {
		locale = i18n.locale;
	}

	// Load messages
	var root = "";
	var file_handle = -1;
	var json_string = "";

	for (var i = 0; i < array_length(file); i++) {
		if (string_pos(".json", file[i]) == 0) {
			show_debug_message($"I18n ERROR - i18n_load_messages({file[i]}, {locale}) - \"{file[i]}\" is not a valid JSON file");
			continue;
		}

		root = "";
		if (string_pos("~/", file[i]) == 1) {
			root = working_directory;
			file[i] = string_copy(file[i], 3, string_length(file[i]) - 2);
		}

		if (!file_exists(root + file[i])) {
			show_debug_message($"I18n ERROR - i18n_load_messages({file[i]}, {locale}) - \"{file[i]}\" JSON file does not exist");
			continue;
		}

		file_handle = file_text_open_read(root + file[i]);
		json_string = "";

		while (!file_text_eof(file_handle)) {
			json_string += file_text_read_string(file_handle);
			file_text_readln(file_handle);
		}
		
		file_text_close(file_handle);

		try {
			var json_struct = json_parse(json_string);
			i18n_flatten_keys(json_struct, locale, i18n);

			if (i18n.debug) {
				show_debug_message($"I18n SUCCESS - i18n_load_messages({file[i]}, {locale}) - \"{file[i]}\" JSON file successfully loaded");
			}
		} catch (e) {
			show_debug_message($"I18n ERROR - i18n_load_messages({file[i]}, {locale}) - Failed to parse \"{file[i]}\" JSON file: " + string(e));
			exit;
		}
	}
}


/**
 * @desc Unload messages from JSON files in the I18n system
 * @param {String | Array<String>} file The JSON file(s) to unload (e.g. "en.json" or ["en1.json", "en2.json"]).
 * @param {String} [locale]="" The locale that you want to unload the messages for (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_unload_messages(file, locale = "", i18n = false) {
	// Guard clause
	if (!(is_string(file) || is_array(file))) {
		show_debug_message($"I18n ERROR - i18n_unload_messages({file}, {locale}) - `file` must be a string or array of string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message($"I18n ERROR - i18n_unload_messages({file}, {locale}) - `locale` must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message($"I18n ERROR - i18n_unload_messages({file}, {locale}) - `i18n` must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!is_array(file)) {
		file = [file];
	}

	// Use current locale if empty
	if (locale == "") {
		locale = i18n.locale;
	}

	// Unload messages
	var root = "";
	var file_handle = -1;
	var json_string = "";

	for (var i = 0; i < array_length(file); i++) {
		if (string_pos(".json", file[i]) == 0) {
			show_debug_message($"I18n ERROR - i18n_unload_messages({file[i]}, {locale}) - \"{file[i]}\" is not a valid JSON file");
			continue;
		}

		root = "";
		if (string_pos("~/", file[i]) == 1) {
			root = working_directory;
			file[i] = string_copy(file[i], 3, string_length(file[i]) - 2);
		}

		if (!file_exists(root + file[i])) {
			show_debug_message($"I18n ERROR - i18n_unload_messages({file[i]}, {locale}) - \"{file[i]}\" JSON file does not exist");
			continue;
		}

		file_handle = file_text_open_read(root + file[i]);
		json_string = "";

		while (!file_text_eof(file_handle)) {
			json_string += file_text_read_string(file_handle);
			file_text_readln(file_handle);
		}
		
		file_text_close(file_handle);

		try {
			var json_struct = json_parse(json_string);
			var names = i18n_flatten_keys(json_struct, locale, i18n, "", false);
			var keys = struct_get_names(i18n.data[$ locale].messages);
			
			for (var j = 0; j < array_length(names); j++) {
				if (!i18n.hashed) {
					if (struct_exists(i18n.data[$ locale].messages, names[j])) {
						struct_remove(i18n.data[$ locale].messages, names[j]);
					} else if (i18n.debug) {
						show_debug_message($"I18n WARNING - i18n_unload_messages({file[i]}, {locale}) - `{names[j]}` key not found in `{locale}` locale");
					}
				} else {
					if (struct_exists_from_hash(i18n.data[$ locale].messages, variable_get_hash(names[j]))) {
						struct_remove_from_hash(i18n.data[$ locale].messages, variable_get_hash(names[j]));
					} else if (i18n.debug) {
						show_debug_message($"I18n WARNING - i18n_unload_messages({file[i]}, {locale}) - `{names[j]}` key not found in `{locale}` locale");
					}
				}
			}

			if (i18n.debug) {
				show_debug_message($"I18n SUCCESS - i18n_unload_messages({file[i]}, {locale}) - \"{file[i]}\" JSON file successfully unloaded");
			}
		} catch (e) {
			show_debug_message($"I18n ERROR - i18n_unload_messages({file[i]}, {locale}) - Failed to parse \"{file[i]}\" JSON file: " + string(e));
			exit;
		}
	}
}
