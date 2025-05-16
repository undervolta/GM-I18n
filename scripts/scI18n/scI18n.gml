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


/// feather ignore GM1041
/**
 * @desc Struct for initializing a locale
 * @param {String} lang_code Locale code (e.g. "en").
 * @param {String} lang_name Locale name (e.g. "English").
 * @param {String | Array<String>} [lang_file]="" Path to locale file(s), which will be loaded on initialization automatically (e.g. "~/langs/en.json").
 */
function I18nLocaleInit(lang_code, lang_name, lang_file = "") constructor {
	// Guard clauses
	if (!is_string(lang_code)) {
		show_debug_message("I18n ERROR - I18nLocaleInit - Locale code must be a string");
		exit;
	}
	if (!is_string(lang_name)) {
		show_debug_message("I18n ERROR - I18nLocaleInit - Locale name must be a string");
		exit;
	}

	// Struct members
	code = lang_code;
	name = lang_name;

	if (lang_file != "") {
		if (!(is_string(lang_file) || is_array(lang_file))) {
			show_debug_message("I18n ERROR - I18nLocaleInit - Locale file must be a string or an array of strings");
			exit;
		}
		file = lang_file;
	} 
}


/**
 * @desc (INTERNAL) Struct for loading locale files
 * @param {Real | Array<Real> | Undefined} interval Time interval in seconds to load the next file.
 * @param {Struct.i18n_create | Bool} [i18n_struct]=false I18n struct reference.
 */
function I18nLoad(interval, i18n_struct = false) constructor {
	// Guard clauses
	if (!(is_numeric(interval) || is_array(interval))) {
		show_debug_message("I18n ERROR - I18nLoad - Load interval must be numeric");
		exit;
	}
	
	i18n = i18n_struct;
	if (!(is_struct(i18n_struct) || is_bool(i18n_struct))) {
		show_debug_message("I18n ERROR - I18nLoad - i18n must be a i18n struct");
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
			show_debug_message("I18n ERROR - I18nLoad.load() - JSON filename must be a string");
			exit;
		}

		if (string_pos(".json", filename) == 0) {
			show_debug_message($"I18n ERROR - I18nLoad.load() - \"{filename}\" is not a valid file");
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
			show_debug_message("I18n ERROR - I18nLoad.load() - JSON file does not exist: " + file_loc);
			exit;
		}
		
		var file = file_text_open_read(file_loc);
		if (file == -1) {
			show_debug_message("I18n ERROR - I18nLoad.load() - Could not open JSON file: " + file_loc);
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
				show_debug_message($"I18n SUCCESS - I18nLoad.load() - Successfully loaded JSON: {filename}");
			}
		} catch (e) {
			show_debug_message("I18n ERROR - I18nLoad.load() - Failed to parse JSON: " + string(e));
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
 * @desc Struct for I18nDrawings
 * @param {Asset.GMFont} [draw_font] Font asset.
 * @param {Constant.HAlign} [draw_halign] Horizontal alignment.
 * @param {Constant.VAlign} [draw_valign] Vertical alignment .
 * @param {Constant.Colour | Array<Constant.Colour> | Real | Array<Real>} [draw_color] Drawing or text color.
 * @param {Real} [draw_scale] Drawing or text scale.
 * @param {Real} [draw_rotation] Drawing or text rotation.
 * @param {Real} [draw_alpha] Drawing or text opacity.
 * @param {Real} [draw_sep] Text separation.
 * @param {Real} [draw_width] Text width.
 */
function I18nDrawings(draw_font = undefined, draw_halign = undefined, draw_valign = undefined, draw_color = undefined, draw_scale = undefined, draw_rotation = undefined, draw_alpha = undefined, draw_sep = undefined, draw_width = undefined) constructor  {
	font = ((asset_get_type(draw_font) == asset_font) ? draw_font : undefined);
	halign = draw_halign;
	valign = draw_valign;
	color = draw_color;
	scale = (is_real(draw_scale) ? draw_scale : undefined);
	rotation = (is_real(draw_rotation) ? draw_rotation : undefined);
	alpha = (is_real(draw_alpha) ? draw_alpha : undefined);
	sep = (is_real(draw_sep) ? draw_sep : -1);
	width = (is_real(draw_width) ? draw_width : room_width);

	// Set draw type
	draw_type = I18N_DRAW_TEXT.NORMAL;

	if (!(is_undefined(draw_sep) || is_undefined(draw_width))) {
		draw_type = I18N_DRAW_TEXT.EXTENDED;

		if (!(is_undefined(draw_color) || is_undefined(draw_alpha))) {
			draw_type = I18N_DRAW_TEXT.EXT_COLORED;

			if (!(is_undefined(draw_rotation) || is_undefined(draw_scale))) {
				draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED;
			}
		} else if (!(is_undefined(draw_rotation) || is_undefined(draw_scale))) {
			draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED;

			if (!(is_undefined(draw_color) || is_undefined(draw_alpha))) {
				draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED;
			}
		}
	} else if (!(is_undefined(draw_color) || is_undefined(draw_alpha))) {
		draw_type = I18N_DRAW_TEXT.COLORED;

		if (!(is_undefined(draw_sep) || is_undefined(draw_width))) {
			draw_type = I18N_DRAW_TEXT.EXT_COLORED;

			if (!(is_undefined(draw_rotation) || is_undefined(draw_scale))) {
				draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED;
			}
		} else if (!(is_undefined(draw_rotation) || is_undefined(draw_scale))) {
			draw_type = I18N_DRAW_TEXT.TRANSFORMED_COLORED;

			if (!(is_undefined(draw_sep) || is_undefined(draw_width))) {
				draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED;
			}
		}
	} else if (!(is_undefined(draw_rotation) || is_undefined(draw_scale))) {
		draw_type = I18N_DRAW_TEXT.TRANSFORMED;

		if (!(is_undefined(draw_color) || is_undefined(draw_alpha))) {
			draw_type = I18N_DRAW_TEXT.TRANSFORMED_COLORED;

			if (!(is_undefined(draw_sep) || is_undefined(draw_width))) {
				draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED;
			}
		} else if (!(is_undefined(draw_sep) || is_undefined(draw_width))) {
			draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED;

			if (!(is_undefined(draw_color) || is_undefined(draw_alpha))) {
				draw_type = I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED;
			}
		}
	}
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
	// Guard clauses
	if (!(is_string(var_name) && is_string(default_locale))) {
		show_debug_message("I18n ERROR - i18n_create() - var_name and default_locale must be strings");
		exit;
	}

	if (!is_array(locales)) {
		show_debug_message("I18n ERROR - i18n_create() - locales must be an array of I18nLocaleInit structs");
		exit;
	}

	if (!(is_bool(options || is_struct(options)))) {
		show_debug_message("I18n ERROR - i18n_create() - options must be a struct");
		exit;
	}

	// Initialize struct members
	var i18n = {
		name: var_name,
		scope: "instance",
		default_locale: default_locale,
		locale: default_locale,
		locales: locales,
		data: {},
		refs: {
			messages: {
				inst: [],
				refs: [],
				keys: [],
				data: []
			}
		},
		debug: false,
		hashed: true,
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
	// Guard clauses
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_update_loader() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!is_bool(use_delta_time)) {
		show_debug_message("I18n ERROR - i18n_update_loader() - Use delta time must be boolean");
		exit;
	}
	
	
	if (struct_exists(i18n, "loader")) {
		if (struct_exists(i18n, "time")) {									// Interval or time is set
			if (i18n.loader.step < i18n.loader.max_step) {
				i18n.loader.update(use_delta_time);
			} else {														// Remove the loader after all files are loaded
				i18n.time = i18n.loader.time;
				struct_remove(i18n, "loader");
			}
		} else if (i18n.loader.time[0] == -1) {								// Load all files and then remove the loader if interval or time isn't set
			for (var i = 0; i < array_length(i18n.loader.files); i++) {
				i18n.loader.load(i18n.loader.files[i], i18n.loader.files_locale[i]);
			}
			
			i18n.loader.time[0] = 0;
			struct_remove(i18n, "loader");
		}
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
	// Guard clauses
	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_add_messages() - Locale must be a string");
		exit;
	}

	if (!is_struct(data)) {
		show_debug_message("I18n ERROR - i18n_add_messages() - Data must be a struct: {key: value, ...}");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_add_messages() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}	

	if (!struct_exists(i18n.data, locale)) {
		show_debug_message("I18n ERROR - i18n_add_messages() - Locale does not exist: " + locale);
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
 * @param {Array<String> | Array<Array<String>>} data Localized dictionaries array (e.g. ["key", "value", ...] or [["key1", "value1"], ["key2", "value2"], ...]).
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_add_dictionaries(locale, data, i18n = false) {
	// Guard clauses
	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_add_dictionaries() - Locale must be a string");
		exit;
	}

	if (!is_array(data)) {
		show_debug_message("I18n ERROR - i18n_add_dictionaries() - Data must be an array of strings or an array of arrays of strings");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_add_dictionaries() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
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
 * @param {Bool} [use_ref=true] Use the first I18nDrawings struct as a reference, instead of creating a new one. Only works if locale is an array.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_add_drawings(locale, preset_name, data, use_ref = true, i18n = false) {
	// Guard clauses
	if (!(is_string(locale) || is_array(locale))) {
		show_debug_message("I18n ERROR - i18n_add_drawings() - Locale must be a string or array of strings");
		exit;
	}

	if (!(is_string(preset_name) || is_array(preset_name))) {
		show_debug_message("I18n ERROR - i18n_add_drawings() - Drawing preset name must be a string or array of strings");
		exit;
	}

	if (!(is_struct(data) || is_array(data))) {
		show_debug_message("I18n ERROR - i18n_add_drawings() - Data must be a struct -> Partial<{font, halign, valign, color, scale, rotation, alpha}> or array of this struct");
		exit;
	}

	if (!is_bool(use_ref)) {
		show_debug_message("I18n ERROR - i18n_add_drawings() - use_ref must be a boolean");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_add_drawings() - i18n must be a i18n struct");
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
			show_debug_message("I18n ERROR - i18n_add_drawings() - Drawing preset name and data must be the same length");
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
			show_debug_message("I18n ERROR - i18n_add_drawings() - Locale does not exist: " + locale[i]);
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
	// Guard clauses
	if (!(is_string(code) || is_array(code))) {
		show_debug_message("I18n ERROR - i18n_add_locales() - Code must be a string or an array of strings");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_add_locales() - i18n must be a i18n struct");
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
			drawings: {},
			options: {}
		};
	}
}


/**
 * @desc Check if i18n is loaded
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Bool} 
 */
function i18n_is_ready(i18n = false) {
	// Guard clauses
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_is_ready() - i18n must be a i18n struct");
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
	// Guard clauses
	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_locale_exists() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_locale_exists() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return struct_exists(i18n.data, locale);
}


/**
 * @desc Check if a message key is exists in the current locale
 * @param {String} key Key (e.g. "hello").
 * @param {String} [locale]="" Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Bool} 
 */
function i18n_key_exists(key, locale = "", i18n = false) {
	// Guard clauses
	if (!is_string(key)) {
		show_debug_message("I18n ERROR - i18n_key_exists() - Key must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_key_exists() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_key_exists() - i18n must be a i18n struct");
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
 */
function i18n_get_locale(i18n = false) {
	// Guard clauses
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_locale() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return i18n.locale;
}


/**
 * @desc Get all initialized locales
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_get_locales(i18n = false) {
	// Guard clauses
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_locales() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return i18n.locales;
}


/**
 * @desc Get all locales code
 * @param {Bool} [include_non_init=false] Include non initialized locales.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Array<Any>} 
 */
function i18n_get_locales_code(include_non_init = false, i18n = false) {
	// Guard clauses
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_locales_code() - i18n must be a i18n struct");
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
 * @returns {Array<Any>} 
 */
function i18n_get_locales_name(i18n = false) {
	// Guard clauses
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_locales_name() - i18n must be a i18n struct");
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
 * @param {Array<Any> | Struct | Real | Undefined} data The additional data for the message. Array (index-based) = [val1, val2, ...], or Struct (name-based) = {key1: val1, key2: val2, ... [, child: {key1: val1, ...}]} (child struct need to be set if it's an interpolation and it have additional data), or Real (pluralization) = number.
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_get_messages(key, data = undefined, locale = "", i18n = false) {
	// Guard clauses
	if (!(is_string(key) || is_array(key))) {
		show_debug_message("I18n ERROR - i18n_get_messages() - key must be a string");
		exit;
	}

	if (!is_undefined(data) && !(is_array(data) || is_struct(data) || is_real(data))) {
		show_debug_message($"I18n ERROR - i18n_get_messages() - data must be an array, struct, or real");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_get_messages() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_messages() - i18n must be a i18n struct");
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
	if (struct_exists(i18n.data, locale)) {
		for (var i = 0; i < array_length(key); i++) {
			if (struct_exists(i18n.data[$ locale].messages, key[i])) {
				array_push(result, (!i18n.hashed)
									? i18n.data[$ locale].messages[$ key[i]]
									: struct_get_from_hash(i18n.data[$ locale].messages, variable_get_hash(key[i])));
			} else if (struct_exists(i18n.data[$ i18n.default_locale].messages, key[i])) {
				array_push(result, (!i18n.hashed) 
									? i18n.data[$ i18n.default_locale].messages[$ key[i]] 
									: struct_get_from_hash(i18n.data[$ i18n.default_locale].messages, variable_get_hash(key[i])));
				if (i18n.debug) {
					show_debug_message($"I18n WARNING - i18n_get_messages() - {key[i]} message key doesn't exists in {locale} locale, use default locale instead");
				}
			} else {
				array_push(result, i18n.default_message);
				if (i18n.debug) {
					show_debug_message($"I18n ERROR - i18n_get_messages() - {key[i]} message key doesn't exists in {locale} locale");
				}
			}

			
			// Use selected pluralization
			var raw_plural = string_split(result[i], i18n.plural_delimiter);

			if (array_length(raw_plural) > 1) {
				if (is_real(data)) {					// Pluralization by index
					if (data >= i18n.plural_start_at && data <= array_length(raw_plural) - 1 + i18n.plural_start_at) {
						result[i] = string_trim(raw_plural[floor(data - i18n.plural_start_at)]);
					} else if (i18n.debug) {
						show_debug_message($"I18n ERROR - i18n_get_messages() - Pluralization index out of range");
					}
				} else if (is_struct(data)) {			// Pluralization by struct (need "plural" key (e.g {plural: 1}, {plural: function(number) {return number}, plural_value: 1}, ...))
					if (struct_exists(data, "plural")) {
						if (struct_exists(data, "plural_value")) {
							if (is_real(data.plural)) {
								if (data.plural >= i18n.plural_start_at && data.plural <= array_length(raw_plural) - 1 + i18n.plural_start_at) {
									result[i] = string_trim(raw_plural[floor(data.plural - i18n.plural_start_at)]);
								} else if (i18n.debug) {
									show_debug_message($"I18n ERROR - i18n_get_messages() - Pluralization index out of range");
								}
							} else if (is_method(data.plural)) {
								var plural_result = data.plural(data.plural_value);

								if (is_real(plural_result)) {
									if (plural_result >= i18n.plural_start_at && plural_result <= array_length(raw_plural) - 1 + i18n.plural_start_at) {
										result[i] = string_trim(raw_plural[floor(plural_result - i18n.plural_start_at)]);
									} else if (i18n.debug) {
										show_debug_message($"I18n ERROR - i18n_get_messages() - Pluralization index out of range");
									}
								} else if (i18n.debug) {
									show_debug_message($"I18n ERROR - i18n_get_messages() - Pluralization method must return a real number");
								}
							}
						} else if (i18n.debug) {
							show_debug_message($"I18n ERROR - i18n_get_messages() - Pluralization struct doesn't have a 'plural_value' key");
						}
					} else if (i18n.debug) {
						show_debug_message($"I18n WARNING - i18n_get_messages() - Pluralization struct doesn't have a 'plural' key");
					}
				} else if (i18n.debug) {
					show_debug_message($"I18n ERROR - i18n_get_messages() - Pluralization data must be a real number or a struct");
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
									var replace_str = string_split(result_str, " ");
									
									// Replace result with the dictionary
									for (var k = 0; k < array_length(replace_str); k++) {
										if (struct_exists_from_hash(i18n.data[$ i18n.locale].dictionaries, variable_get_hash(replace_str[k]))) {
											result_str = string_replace(result_str, replace_str[k], struct_get_from_hash(i18n.data[$ i18n.locale].dictionaries, variable_get_hash(replace_str[k])));
										} else if (i18n.debug) {
											show_debug_message($"I18n WARNING - i18n_get_messages() - {replace_str[k]} dictionary doesn't exists in {i18n.locale} locale");
										}
									}
									
									// Update the position of the next placeholder
									for (var k = j+1; k < array_length(end_at); k++) {
										start_at[k] += string_length(result_str) - string_length(placeholder);
										end_at[k] += string_length(result_str) - string_length(placeholder);
									}
								}

								result[i] = string_replace(result[i], placeholder, result_str);
							} else if (i18n.debug) {
								show_debug_message($"I18n ERROR - i18n_get_messages() - {current_str} placeholder doesn't exists in {i18n.locale} locale");
							}
							
						} else if (intp_type[j] == 2) {			// Key interpolation
							current_str = string_copy(result[i], start_at[j] + 2, end_at[j] - start_at[j] - 3);
							placeholder = string_repeat(i18n.linked_start, 2) + current_str + string_repeat(i18n.linked_end, 2);
							
							var child = struct_exists(data, "child_" + string_replace_all(current_str, ".", "_")) 
										? data[$ "child_" + string_replace_all(current_str, ".", "_")]
										: (struct_exists(data, "child") ? data.child : undefined);
							
							if (struct_exists(i18n.data[$ i18n.locale].messages, current_str)) {
								result_str = i18n_get_messages(current_str, child, i18n.locale, i18n);
								
								for (var k = j+1; k < array_length(end_at); k++) {
									start_at[k] += string_length(result_str) - string_length(placeholder);
									end_at[k] += string_length(result_str) - string_length(placeholder);
								}
								result[i] = string_replace(result[i], placeholder, result_str);
							} else if (struct_exists(i18n.data[$ i18n.default_locale].messages, current_str)) {
								result_str = i18n_get_messages(current_str, child, i18n.default_locale, i18n);
								
								for (var k = j+1; k < array_length(end_at); k++) {
									start_at[k] += string_length(result_str) - string_length(placeholder);
									end_at[k] += string_length(result_str) - string_length(placeholder);
								}
								result[i] = string_replace(result[i], placeholder, result_str);
								
								if (i18n.debug) {
									show_debug_message($"I18n WARNING - i18n_get_messages() - message key {current_str} doesn't exists in {i18n.locale} locale, use default locale instead");
								}
							} else if (i18n.debug) {
								show_debug_message($"I18n ERROR - i18n_get_messages() - message key {current_str} doesn't exists in {i18n.locale} locale");
							}
						}
					}
				}
			}
		}

		return ((array_length(result) == 1) ? result[0] : result);
	} 

	show_debug_message($"I18n ERROR - i18n_get_messages() - {locale} locale doesn't exists");
	return i18n.default_message;
}


/**
 * @desc Get all drawing presets name from a locale
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Array<String> | Array} 
 */
function i18n_get_drawing_presets(locale = "", i18n = false) {
	// Guard clauses
	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_get_drawing_presets() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_drawing_presets() - i18n must be a i18n struct");
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

	show_debug_message($"I18n ERROR - i18n_get_drawing_presets() - {locale} locale doesn't exists");
	return [];
}


/**
 * @desc Update a drawing preset
 * @param {String} preset_name Drawing preset name (e.g "title").
 * @param {Array<Any> | Struct | Struct.I18nDrawings} data The data to update the drawing preset with (e.g. ["font", fArial], [["font", fArial], ["alpha", 1], ...], {font: fArial, alpha: 1, ...}).
 * @param {String} [locale]="" Locale (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_drawings(preset_name, data, locale = "", i18n = false) {
	// Guard clauses
	if (!is_string(preset_name)) {
		show_debug_message("I18n ERROR - i18n_update_drawings() - Preset name must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_update_drawings() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_update_drawings() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!(is_array(data) || is_struct(data))) {
		show_debug_message("I18n ERROR - i18n_update_drawings() - Data must be an array or a struct");
		exit;
	}

	if (locale == "") {
		locale = i18n.locale;
	}
	
	if (!struct_exists(i18n.data[$ locale].drawings, preset_name)) {
		show_debug_message($"I18n ERROR - i18n_update_drawings() - {preset_name} drawing preset doesn't exists");
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
				show_debug_message("I18n ERROR - i18n_update_drawings() - Data must be an array of strings");
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
	// Guard clauses
	if (!(is_string(preset_name) || is_array(preset_name))) {
		show_debug_message("I18n ERROR - i18n_get_drawings() - Preset name must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_get_drawings() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_drawings() - i18n must be a i18n struct");
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
			} else {
				array_push(result, {})
				show_debug_message($"I18n ERROR - i18n_get_drawings() - {preset_name[i]} drawing preset doesn't exists");
			}
		}

		return ((array_length(result) == 1) ? result[0] : result);
	}
	
	show_debug_message($"I18n ERROR - i18n_get_drawings() - {locale} locale doesn't exists");
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
	// Guard clauses
	if (!is_string(preset_name)) {
		show_debug_message("I18n ERROR - i18n_get_drawings_data() - Preset name must be a string");
		exit;
	}

	if (!is_numeric(type)) {
		show_debug_message("I18n ERROR - i18n_get_drawings_data() - Type must be a real");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_get_drawings_data() - Locale must be a string");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_get_drawings_data() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (locale == "") {
		locale = i18n.locale;
	}
	
	if (!struct_exists(i18n.data[$ locale].drawings, preset_name)) {
		show_debug_message($"I18n ERROR - i18n_get_drawings_data() - {preset_name} drawing preset doesn't exists");
		exit;
	}

	// Return the drawing data
	var names = ["font", "halign", "valign", "color", "scale", "rotation", "alpha", "sep", "width"];
	
	return i18n.data[$ locale].drawings[$ preset_name][$ names[type]];
}


/**
 * @desc Create a reference to a message for a dynamic translations
 * @param {String} var_name This variable name (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {String} key Message key (e.g. "hello").
 * @param {Array<Any> | Struct | Real | Undefined} data The additional data for the message. Array (index-based) = [val1, val2, ...], or Struct (name-based) = {key1: val1, key2: val2, ... [, child: {key1: val1, ...}]} (child struct need to be set if it's an interpolation and it have additional data), or Real (pluralization) = number.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {String}
 */
function i18n_create_ref_message(var_name, key, data = undefined, i18n = false) {
	// Guard clauses
	if (!is_string(var_name)) {
		show_debug_message("I18n ERROR - i18n_create_ref_message() - var_name must be a string");
		exit;
	}

	if (!is_string(key)) {
		show_debug_message("I18n ERROR - i18n_create_ref_message() - key must be a string");
		exit;
	}
	
	if (!is_undefined(data) && !(is_real(data) || is_array(data) || is_struct(data))) {
		show_debug_message("I18n ERROR - i18n_create_ref_message() - data must be an array or a struct");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_create_ref_message() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}
										
	var name_split = string_split(var_name, ".", true);		
	
	// Check if it's a global variable
	if (name_split[0] == "global" || name_split[0] == "g") {
		array_push(i18n.refs.messages.inst, "global");
	} else {
		array_push(i18n.refs.messages.inst, id);
	}

	array_push(i18n.refs.messages.refs, var_name);
	array_push(i18n.refs.messages.keys, key);
	array_push(i18n.refs.messages.data, data);

	return i18n_get_messages(key, data, i18n.locale, i18n);
}

/**
 * @desc (INTERNAL) Get a reference to a message
 * @param {Real} index The index of the reference.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Any}
 */
function i18n_get_ref_message(index, i18n = false) {
	// Guard clauses
	if (!is_real(index)) {
		show_debug_message("I18n ERROR - i18n_get_ref_message() - index must be a real");
		exit;
	}
	index = round(index);

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_create_ref_message() - i18n must be a i18n struct");
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
		if (string_digits(name_split[i]) != "") {
			show_debug_message($"I18n ERROR - i18n_get_ref_message() - An array is only supported at the last reference level");
			break;
		}
		
		if (root_ref == "global") {					// e.g ref = "global.text"
			if (!is_struct(current_ref)) {
				if (!variable_global_exists(name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message() - Global variable {name_split[i]} doesn't exist");
					break;
				}
			} else {
				if (!struct_exists(current_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message() - Struct {current_ref} member {name_split[i]} doesn't exist");
					break;
				}
			}

			current_ref = (i == 1) ? variable_global_get(name_split[i]) : current_ref[$ name_split[i]];
		} else {
			if (!is_struct(current_ref)) {
				if (!variable_instance_exists(root_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message() - Instance {root_ref} variable {name_split[i]} doesn't exist");
					break;
				}
			} else {
				if (!struct_exists(current_ref, name_split[i])) {
					show_debug_message($"I18n ERROR - i18n_get_ref_message() - Struct {current_ref} member {name_split[i]} doesn't exist");
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
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_refs(i18n = false) {
	// Guard clauses
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_update_refs() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	var types = struct_get_names(i18n.refs);
	
	for (var i = 0; i < array_length(types); i++) {
		var to_delete = [];

		switch (types[i]) {
			case "messages":
				for (var j = 0; j < array_length(i18n.refs[$ types[i]].inst); j++) {
					var root_ref = i18n.refs[$ types[i]].inst[j];
					var current_ref = i18n.refs[$ types[i]].inst[j];
					var name_split = string_split(i18n.refs[$ types[i]].refs[j], ".", true);
					var to_update = name_split[array_length(name_split) - 1];

					// Guard clauses
					if (root_ref == "global") {					// e.g ref = "global.text"
						if (array_length(name_split) < 2) {
							show_debug_message($"I18n ERROR - i18n_update_refs() - Global variable member hasn't been specified");
							array_push(to_delete, j);
							continue;
						}
					} else if (!instance_exists(root_ref)) {		// e.g ref = "text"
						// show_debug_message($"I18n ERROR - Instance {root_ref} doesn't exist");
						array_push(to_delete, j);
						continue;
					}
					
					// Track valid references
					current_ref = i18n_get_ref_message(j, i18n);

					// Update all references with the new message
					var index = 0;

					if (root_ref == "global") {
						if (array_length(name_split) == 2) {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								show_debug_message($"I18n ERROR - i18n_update_refs() - An array isn't supported as a global variable member");
								continue;
							}

							variable_global_set(to_update, i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n));
						} else {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								index = real(to_update);
								current_ref[index] = i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n);
							} else {
								current_ref[$ to_update] = i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n);
							}
						}
					} else {
						if (array_length(name_split) == 1) {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								show_debug_message(name_split)
								show_debug_message($"I18n ERROR - i18n_update_refs() - An array isn't supported as an instance variable member");
								continue;
							}

							variable_instance_set(root_ref, to_update, i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n));
						} else {
							if (string_digits(to_update) != "" && string_letters(to_update) == "") {
								index = real(to_update);
								current_ref[index] = i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n);
							} else {
								current_ref[$ to_update] = i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n);
							}
						}
					}
				}
			break;
		}

		// Delete invalid refs
		for (var j = array_length(to_delete) - 1; j >= 0; j--) {
			array_delete(i18n.refs[$ types[i]].inst, to_delete[j], 1);
			array_delete(i18n.refs[$ types[i]].refs, to_delete[j], 1);
			array_delete(i18n.refs[$ types[i]].keys, to_delete[j], 1);
			array_delete(i18n.refs[$ types[i]].data, to_delete[j], 1);
		}
	}
}


/**
 * @desc Update pluralization value on reference(s)
 * @param {String} var_name Variable name based on the var_name in i18n_create_ref_message() (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param {Real} value The new pluralization value (e.g. 1).
 * @param {Bool} [update_refs=false] Update i18n references.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_update_plurals(var_name, value, update_refs = false, i18n = false) {
	// Guard clauses
	if (!is_string(var_name)) {
		show_debug_message("I18n ERROR - i18n_update_plurals() - var_name must be a string");
		exit;
	}

	if (!is_real(value)) {
		show_debug_message("I18n ERROR - i18n_update_plurals() - value must be a real");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_update_plurals() - i18n must be a i18n struct");
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
		show_debug_message($"I18n ERROR - i18n_update_plurals() - Reference {var_name} doesn't exist");
		exit;
	}

	var target_ref = i18n_get_ref_message(ref_index, i18n);
	
	// Check if the reference has derived reference(s)
	if (!ref_match) {
		var curr_split = string_split(var_name, ".", true);
		var target_split = string_split(i18n.refs.messages.refs[ref_index], ".", true);

		for (var i = array_length(target_split) - 1; i < array_length(curr_split); i++) {
			if (is_struct(target_ref)) {
				if (struct_exists(target_ref, curr_split[i])) {
					target_ref = target_ref[$ curr_split[i]];
				} else {
					show_debug_message($"I18n ERROR - i18n_update_plurals() - Struct {target_ref} member {curr_split[i]} doesn't exist");
					break;
				}
			} else {
				show_debug_message($"I18n ERROR - i18n_update_plurals() - Reference {var_name} isn't a struct");
				break;
			}
		}
	}

	// Update pluralization value
	if (is_real(value)) {
		i18n.refs.messages.data[ref_index] = value;
	} else if (struct_exists(target_ref, "plural") && struct_exists(target_ref, "plural_value")) {
		target_ref.plural_value = value;
	} else {
		show_debug_message($"I18n ERROR - i18n_update_plurals() - Struct {target_ref} doesn't have a plural or plural_value member");
	}

	// Update i18n references
	if (update_refs) {
		i18n_update_refs(i18n);
	}
}


/**
 * @desc Set default message
 * @param {String} message Default message.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_set_default_message(message, i18n = false) {
	// Guard clauses
	if (!is_string(message)) {
		show_debug_message("I18n ERROR - i18n_set_default_message() - Message must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_set_default_message() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	i18n.default_message = message;
}


/**
 * @desc Change current locale
 * @param {String} code Locale code (e.g. "en").
 * @param {Bool} [update_refs=true] Update i18n references.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_set_locale(code, update_refs = true, i18n = false) {
	// Guard clauses
	if (!is_string(code)) {
		show_debug_message("I18n ERROR - i18n_set_locale() - Code must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_set_locale() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!struct_exists(i18n.data, code)) {
		show_debug_message($"I18n ERROR - i18n_set_locale() - {code} locale doesn't exists");
		exit;
	}

	// Update locale
	i18n.locale = code;

	// Update i18n references
	if (update_refs) {
		i18n_update_refs(i18n);
	}
}


/**
 * @desc Use a drawing preset
 * @param {String} preset_name Drawing preset name (e.g "title").
 * @param {String} [locale=""] Locale code (e.g "en"). Leave it empty to mark it as dynamic locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_use_drawing(preset_name, locale = "", i18n = false) {
	// Guard clauses
	if (!is_string(preset_name)) {
		show_debug_message("I18n ERROR - i18n_use_drawing() - Preset name must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_use_drawing() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_use_drawing() - i18n must be a i18n struct");
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

		if (!is_undefined(preset.font)) {
			draw_set_font(preset.font);
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

	show_debug_message($"I18n ERROR - i18n_use_drawing() - {preset_name} drawing preset doesn't exists");

	return undefined;
}


/**
 * @desc Draw message with a drawing preset
 * @param {Real} x X position.
 * @param {Real} y Y position.
 * @param {String} text The text to draw. Can be any text, including message from i18n_get_message() (e.g. "Hello World!"), or a message reference variable (created by i18n_create_ref_message()). Use "@:" prefix to use this as message key (e.g. "@:hello").
 * @param {Real | Array<Any> | undefined} [data=undefined] Data to pass to the message (e.g. 1, ["Hello World!"]). Struct isn't supported in this function.
 * @param {String} [preset_name=""] Drawing preset name to use (e.g "title").
 * @param {String} [locale=""] Locale code (e.g "en"). Leave it empty to mark it as dynamic locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
function i18n_draw_message(x, y, text, data = undefined, preset_name = "", locale = "", i18n = false) {
	// Guard clauses
	if (!(is_real(x) || is_real(y))) {
		show_debug_message("I18n ERROR - i18n_draw_message() - x and y must be a real");
		exit;
	}

	if (!is_string(text)) {
		show_debug_message("I18n ERROR - i18n_draw_message() - Text must be a string");
		exit;
	}

	if (!is_undefined(data) && !(is_real(data) || is_array(data))) {
		show_debug_message("I18n ERROR - i18n_draw_message() - Data must be a real or array");
		exit;
	}

	if (!is_string(preset_name)) {
		show_debug_message("I18n ERROR - i18n_draw_message() - Preset name must be a string");
		exit;
	}

	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_draw_message() - Locale must be a string");
		exit;
	}
	
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_draw_message() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}
	
	// Get drawing data
	var drawing_data = undefined;

	if (locale == "") {
		locale = i18n.locale;
	}

	if (string_pos("@:", text) == 1) {
		text = i18n_get_messages(string_copy(text, 3, string_length(text) - 2), data, locale, i18n);
	}

	if (preset_name != "") {
		drawing_data = i18n_use_drawing(preset_name, locale, i18n);
	}
	
	// Draw message
	switch (drawing_data.draw_type) {
		case I18N_DRAW_TEXT.NORMAL:
			draw_text(x, y, text);
			break;
			
		case I18N_DRAW_TEXT.EXTENDED:
			draw_text_ext(x, y, text, 
				(is_undefined(drawing_data.sep) ? -1 : drawing_data.sep), 
				(is_undefined(drawing_data.width) ? room_width : drawing_data.width));
			break;
			
		case I18N_DRAW_TEXT.COLORED:
			draw_text_colour(x, y, text, 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 0)] : drawing_data.color)), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 1)] : drawing_data.color)), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 2)] : drawing_data.color)), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 3)] : drawing_data.color)), 
				(is_undefined(drawing_data.alpha) ? 1 : drawing_data.alpha));
			break;

		case I18N_DRAW_TEXT.TRANSFORMED:
			draw_text_transformed(x, y, text, 
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale), 
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale), 
				(is_undefined(drawing_data.rotation) ? 0 : drawing_data.rotation));
			break;
			
		case I18N_DRAW_TEXT.EXT_COLORED:
			draw_text_ext_colour(x, y, text, 
				(is_undefined(drawing_data.sep) ? -1 : drawing_data.sep), 
				(is_undefined(drawing_data.width) ? room_width : drawing_data.width), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 0)] : drawing_data.color)), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 1)] : drawing_data.color)), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 2)] : drawing_data.color)),
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 3)] : drawing_data.color)),
				(is_undefined(drawing_data.alpha) ? 1 : drawing_data.alpha));
			break;
			
		case I18N_DRAW_TEXT.EXT_TRANSFORMED:
			draw_text_ext_transformed(x, y, text, 
				(is_undefined(drawing_data.sep) ? -1 : drawing_data.sep), 
				(is_undefined(drawing_data.width) ? room_width : drawing_data.width), 
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale), 
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale), 
				(is_undefined(drawing_data.rotation) ? 0 : drawing_data.rotation));
			break;

		case I18N_DRAW_TEXT.TRANSFORMED_COLORED:
			draw_text_transformed_colour(x, y, text, 
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale),
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale),
				(is_undefined(drawing_data.rotation) ? 0 : drawing_data.rotation),
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 0)] : drawing_data.color)), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 1)] : drawing_data.color)),
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 2)] : drawing_data.color)),
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 3)] : drawing_data.color)),
				(is_undefined(drawing_data.alpha) ? 1 : drawing_data.alpha));
			break;

		case I18N_DRAW_TEXT.EXT_TRANSFORMED_COLORED:
			draw_text_ext_transformed_colour(x, y, text, 
				(is_undefined(drawing_data.sep) ? -1 : drawing_data.sep), 
				(is_undefined(drawing_data.width) ? room_width : drawing_data.width), 
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale), 
				(is_undefined(drawing_data.scale) ? 1 : drawing_data.scale), 
				(is_undefined(drawing_data.rotation) ? 0 : drawing_data.rotation),
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 0)] : drawing_data.color)), 
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 1)] : drawing_data.color)),
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 2)] : drawing_data.color)),
				(is_undefined(drawing_data.color) ? c_white : 
					(is_array(drawing_data.color) ? drawing_data.color[min(array_length(drawing_data.color) - 1, 3)] : drawing_data.color)),
				(is_undefined(drawing_data.alpha) ? 1 : drawing_data.alpha));
			break;
	}
}

