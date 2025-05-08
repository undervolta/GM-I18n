global.i18n_name = "";


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

	// Fill the missing intervals
	if (array_length(time) < array_length(files)) {
		repeat (array_length(files) - array_length(time)) {
			array_push(time, time[array_length(time) - 1]);
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
 * @param {Constant.Colour} [draw_color] Text color.
 * @param {Real} [draw_scale] Text scale.
 * @param {Real} [draw_rotation] Text rotation.
 * @param {Real} [draw_alpha] Text opacity.
 */
function I18nDrawings(draw_font = undefined, draw_halign = undefined, draw_valign = undefined, draw_color = undefined, draw_scale = undefined, draw_rotation = undefined, draw_alpha = undefined) constructor  {
	font = draw_font;
	halign = draw_halign;
	valign = draw_valign;
	color = draw_color;
	scale = draw_scale;
	rotation = draw_rotation;
	alpha = draw_alpha;
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
		hashed: true,
		default_message: ""
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
 * @desc Add localized drawing presets to a locale in the i18n struct
 * @param {String | Array<String>} locale Locale code (e.g. "en").
 * @param {String | Array<String>} preset_name Drawing preset name (e.g. "default").
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
		show_debug_message("I18n ERROR - i18n_add_drawings() - Drawing preset name and data must be the same length");
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
function i18n_exist_locale(locale, i18n = false) {
	// Guard clauses
	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - i18n_exist_locale() - Locale must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_exist_locale() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	return struct_exists(i18n.data, locale);
}


/**
 * @desc Check if key exists
 * @param {String} key Key (e.g. "hello").
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Bool} 
 */
function i18n_exist_key(key, i18n = false) {
	// Guard clauses
	if (!is_string(key)) {
		show_debug_message("I18n ERROR - i18n_exist_key() - Key must be a string");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n_exist_key() - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}
	
	return struct_exists(i18n.data[$ i18n.locale].messages, key);
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

	if (!is_undefined(data) && !(is_array(data) || is_struct(data))) {
		show_debug_message("I18n ERROR - i18n_get_messages() - data must be an array or a struct");
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
				show_debug_message($"I18n WARNING - i18n_get_messages() - {key[i]} message key doesn't exists in {locale} locale, use default locale instead");
			} else {
				array_push(result, i18n.default_message);
				show_debug_message($"I18n ERROR - i18n_get_messages() - {key[i]} message key doesn't exists in {locale} locale");
			}
			
			// Replace placeholders
			if (!is_undefined(data)) {
				var intp_type = [];			// 1 = {placeholder}, 2 = [[interpolation]]
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
						} else if (string_char_at(result[i], j) == "}" && intp_type[array_length(intp_type) - 1] == 1) {
							array_push(end_at, j);
						}
						
						// Key interpolation
						if (string_char_at(result[i], j) == "[")  {
							if (j+1 <= string_length(result[i]) && array_length(start_at) == array_length(end_at)) {
								if (string_char_at(result[i], j+1) == "[") {
									array_push(start_at, j);
									array_push(intp_type, 2);
								}
							}
						} else if (string_char_at(result[i], j) == "]" && intp_type[array_length(intp_type) - 1] == 2) {
							if (j+1 <= string_length(result[i])) {
								if (string_char_at(result[i], j+1) == "]") {
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

						if (intp_type[j] == 1) {
							current_str = string_copy(result[i], start_at[j] + 1, end_at[j] - start_at[j] - 1);
							placeholder = string("{" + current_str + "}");
							
							if (struct_exists(data, current_str)) {
								result_str = data[$ current_str];
								for (var k = j+1; k < array_length(end_at); k++) {
									start_at[k] += string_length(result_str) - string_length(placeholder);
									end_at[k] += string_length(result_str) - string_length(placeholder);
								}
								
								result[i] = string_replace(result[i], placeholder, result_str);
							} else {
								show_debug_message($"I18n ERROR - i18n_get_messages() - {current_str} placeholder doesn't exists");
							}
							
						} else if (intp_type[j] == 2) {
							current_str = string_copy(result[i], start_at[j] + 2, end_at[j] - start_at[j] - 3);
							placeholder = string("[[" + current_str + "]]");
							
							if (struct_exists(i18n.data[$ i18n.locale].messages, current_str)) {
								result_str = i18n_get_messages(current_str, struct_exists(data, "child") ? data.child : undefined, i18n.locale, i18n);
								
								for (var k = j+1; k < array_length(end_at); k++) {
									start_at[k] += string_length(result_str) - string_length(placeholder);
									end_at[k] += string_length(result_str) - string_length(placeholder);
								}
								result[i] = string_replace(result[i], placeholder, result_str);
							} else if (struct_exists(i18n.data[$ i18n.default_locale].messages, current_str)) {
								result_str = i18n_get_messages(current_str, struct_exists(data, "child") ? data.child : undefined, i18n.default_locale, i18n);
								
								for (var k = j+1; k < array_length(end_at); k++) {
									start_at[k] += string_length(result_str) - string_length(placeholder);
									end_at[k] += string_length(result_str) - string_length(placeholder);
								}
								result[i] = string_replace(result[i], placeholder, result_str);
								
								show_debug_message($"I18n WARNING - i18n_get_messages() - {current_str} interpolation doesn't exists in {i18n.locale} locale, use default locale instead");
							} else {
								show_debug_message($"I18n ERROR - i18n_get_messages() - {current_str} interpolation doesn't exists");
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
 * @desc Get all drawing presets from a locale
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
 * @desc Get drawing preset(s) from a locale
 * @param {String | Array<String>} preset_name Drawing preset name (e.g. "default").
 * @param {String} [locale]="" The locale that you want to get (e.g. "en"). Leave it empty to use the current locale.
 * @param {Bool | Struct.i18n_create} [i18n]=false I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns {Any}
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
	return [];
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
	
	if (!is_undefined(data) && !(is_array(data) || is_struct(data))) {
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
					for (var k = ((root_ref == "global")); k < (array_length(name_split) - 1); k++) {
						if (string_digits(name_split[k]) != "") {
							show_debug_message($"I18n ERROR - i18n_update_refs() - An array is only supported at the last reference level");
							array_push(to_delete, j);
							break;
						}
						
						if (root_ref == "global") {					// e.g ref = "global.text"
							if (!is_struct(current_ref)) {
								if (!variable_global_exists(name_split[k])) {
									show_debug_message($"I18n ERROR - i18n_update_refs() - Global variable {name_split[k]} doesn't exist");
									array_push(to_delete, j);
									break;
								}
							} else {
								if (!struct_exists(current_ref, name_split[k])) {
									show_debug_message($"I18n ERROR - i18n_update_refs() - Struct {current_ref} member {name_split[k]} doesn't exist");
									array_push(to_delete, j);
									break;
								}
							}

							current_ref = (k == 1) ? variable_global_get(name_split[k]) : current_ref[$ name_split[k]];
						} else {
							if (!is_struct(current_ref)) {
								if (!variable_instance_exists(root_ref, name_split[k])) {
									show_debug_message($"I18n ERROR - i18n_update_refs() - Instance {root_ref} variable {name_split[k]} doesn't exist");
									array_push(to_delete, j);
									break;
								}
							} else {
								if (!struct_exists(current_ref, name_split[k])) {
									show_debug_message($"I18n ERROR - i18n_update_refs() - Struct {current_ref} member {name_split[k]} doesn't exist");
									array_push(to_delete, j);
									break;
								}
							}
							
							current_ref = (k == 0) ? variable_instance_get(root_ref, name_split[k]) : current_ref[$ name_split[k]];
						}
					}

					// Update all references with the new message
					var index = 0;

					if (root_ref == "global") {
						if (array_length(name_split) == 2) {
							if (string_digits(to_update) != "") {
								show_debug_message($"I18n ERROR - i18n_update_refs() - An array isn't supported as a global variable member");
								continue;
							}

							variable_global_set(to_update, i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n));
						} else {
							if (string_digits(to_update) != "") {
								show_debug_message("found array")
								index = real(to_update);
								current_ref[index] = i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n);
							} else {
								current_ref[$ to_update] = i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n);
							}
						}
					} else {
						if (array_length(name_split) == 1) {
							if (string_digits(to_update) != "") {
								show_debug_message($"I18n ERROR - i18n_update_refs() - An array isn't supported as an instance variable member");
								continue;
							}

							variable_instance_set(root_ref, to_update, i18n_get_messages(i18n.refs[$ types[i]].keys[j], i18n.refs[$ types[i]].data[j], i18n.locale, i18n));
						} else {
							if (string_digits(to_update) != "") {
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

