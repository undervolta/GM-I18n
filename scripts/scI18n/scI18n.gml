global.i18n_name = "";


/**
 * @desc description
 * @param {String} lang_code Description
 * @param {String} lang_name Description
 * @param {String | Array<String>} [lang_file]="" Description
 */
function I18nLocaleInit(lang_code, lang_name, lang_file = "") constructor {
	// Guard clauses
	if (!is_string(lang_code)) {
		show_debug_message("I18n ERROR - Locale code must be a string");
		exit;
	}
	if (!is_string(lang_name)) {
		show_debug_message("I18n ERROR - Locale name must be a string");
		exit;
	}

	// Struct members
	code = lang_code;
	name = lang_name;

	if (lang_file != "") {
		if (!(is_string(lang_file) || is_array(lang_file))) {
			show_debug_message("I18n ERROR - Locale file must be a string or an array of strings");
			exit;
		}
		file = lang_file;
	} 
}


/**
 * @desc description
 * @param {Real | Array<Real> | Undefined} interval Description
 * @param {Struct.i18n_create | Bool} [i18n_struct]=false Description
 */
function I18nLoad(interval, i18n_struct = false) constructor {
	// Guard clauses
	if (!is_numeric(interval)) {
		show_debug_message("I18n ERROR - Load interval must be numeric");
		exit;
	}
	
	i18n = i18n_struct;
	if (!(is_struct(i18n_struct) || is_bool(i18n_struct))) {
		show_debug_message("I18n ERROR - i18n must be a i18n struct");
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

	// Load all files later in i18n_update_loader() if interval is not set
	if (time == 0) {
		time = [-1];	
		/*for (var i = 0; i < array_length(files); i++) {
			self.load(files[i], files_locale[i]);
		}
		exit;*/
	}

	// Calculate max step and step time	
	if (is_array(time)) {
		if (array_length(time) < array_length(files)) {
			repeat (array_length(files) - array_length(time)) {
				array_push(time, time[array_length(time) - 1]);
			}
		}

		for (var i = 0; i < array_length(files); i++) {
			max_step += time[i] * game_get_speed(gamespeed_fps);
		}
	} else {
		max_step = time * game_get_speed(gamespeed_fps) * array_length(files);
	}

	for (var i = 0; i < array_length(files); i++) {
		array_push(step_time, (i == 0)
							? (time[i] * game_get_speed(gamespeed_fps))
							: (step_time[i - 1] + (time[i] * game_get_speed(gamespeed_fps))));
	}

	static dt = function() {
		return ((delta_time/1000000) / (1/60));
	}
	
	static update = function(use_delta_time = false) {
		step += (use_delta_time) ? (1 * dt()) : 1;

		if (floor(step) >= step_time[step_index]) {
			load(files[step_index], files_locale[step_index]);
			step_index++;
		}
	}

	static load = function(filename, locale) {
		// Guard clauses
		if (!is_string(filename)) {
			show_debug_message("I18n ERROR - JSON filename must be a string");
			exit;
		}

		if (string_pos(".json", filename) == 0) {
			show_debug_message($"I18n ERROR - \"{filename}\" is not a valid file");
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
			show_debug_message("I18n ERROR - JSON file does not exist: " + file_loc);
			exit;
		}
		
		var file = file_text_open_read(file_loc);
		if (file == -1) {
			show_debug_message("I18n ERROR - Could not open JSON file: " + file_loc);
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
			show_debug_message("I18n ERROR - Failed to parse JSON: " + string(e));
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
					struct_set(i18n.data[$ locale].messages, key, value);
					i18n.data[$ locale].messages[$ key] = value;
				} else {
					struct_set_from_hash(i18n.data[$ locale].messages, variable_get_hash(key), value);
				}
			}
		}
	}
}

/**
 * @desc description
 * @param {Asset.GMFont} [font] Description
 * @param {Constant.HAlign} [halign] Description
 * @param {Constant.VAlign} [valign] Description
 * @param {Constant.Colour} [color] Description
 * @param {Real} [scale] Description
 * @param {Real} [rotation] Description
 * @param {Real} [alpha] Description

 */
function I18nDrawings(font = undefined, halign = undefined, valign = undefined, color = undefined, scale = undefined, rotation = undefined, alpha = undefined) constructor  {
	font = font;
	halign = halign;
	valign = valign;
	color = color;
	scale = scale;
	rotation = rotation;
	alpha = alpha;
}

/**
 * @desc description
 * @param {String} var_name Description
 * @param {String} default_locale Description
 * @param {Array<Struct.I18nLocaleInit>} locales Description
 * @param {Bool | Struct} [options]=false Description
 * @returns {Struct} Description
 */
function i18n_create(var_name, default_locale, locales, options = false) {
	// Guard clauses
	if (!(is_string(var_name) && is_string(default_locale))) {
		show_debug_message("I18n ERROR - var_name and default_locale must be strings");
		exit;
	}

	if (!is_array(locales)) {
		show_debug_message("I18n ERROR - locales must be an array of I18nLocaleInit structs");
		exit;
	}

	if (!(is_bool(options || is_struct(options)))) {
		show_debug_message("I18n ERROR - options must be a struct");
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
		refs: [],
		hashed: true
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
	
	show_debug_message(i18n);
	return i18n;
}


/**
 * @desc description
 * @param {Bool} [use_delta_time]=false Description
 * @param {Struct.i18n_create | Bool} [i18n]=false Description
 */
function i18n_update_loader(use_delta_time = false, i18n = false) {
	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}

	if (!is_bool(use_delta_time)) {
		show_debug_message("I18n ERROR - Use delta time must be boolean");
		exit;
	}

	if (!struct_exists(i18n, "loader")) {
		show_debug_message("I18n ERROR - i18n must have a loader");
		exit;
	}

	if (struct_exists(i18n, "time") && i18n.loader.step < i18n.loader.max_step) {
		i18n.loader.update(use_delta_time);
	}
}


/**
 * @desc description
 * @param {String} locale Description
 * @param {Struct} data Description
 * @param {Bool | Struct.i18n_create} [i18n]=false Description
 */
function i18n_add_messages(locale, data, i18n = false) {
	// Guard clauses
	if (!is_string(locale)) {
		show_debug_message("I18n ERROR - Locale must be a string");
		exit;
	}

	if (!is_struct(data)) {
		show_debug_message("I18n ERROR - Data must be a struct -> {key: value, ...}");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n must be a i18n struct");
		exit;
	} else if (is_bool(i18n)) {
		i18n = variable_global_get(variable_global_get("i18n_name"));
	}	

	// Set data
	var keys = struct_get_names(data);
	for (var i = 0; i < array_length(keys); i++) {
		var key = keys[i];

		if (!i18n.hashed) {
			i18n.data[$ locale].messages[$ key] = data[$ key];
		} else {
			struct_set_from_hash(i18n.data[$ locale].messages, variable_get_hash(key), data[$ key]);
		}
	}
}


/**
 * @desc description
 * @param {String | Array<String>} locale Description
 * @param {String | Array<String>} preset_name Description
 * @param {Struct.I18nDrawings} data Description
 * @param {Bool | Struct.i18n_create} [i18n]=false Description
 */
function i18n_add_drawings(locale, preset_name, data, i18n = false) {
	// Guard clauses
	if (!(is_string(locale) || is_array(locale))) {
		show_debug_message("I18n ERROR - Locale must be a string or array of strings");
		exit;
	}

	if (!(is_string(preset_name) || is_array(preset_name))) {
		show_debug_message("I18n ERROR - Drawing preset name must be a string or array of strings");
		exit;
	}

	if (!(is_struct(data) || is_array(data))) {
		show_debug_message("I18n ERROR - Data must be a struct -> Partial<{font, halign, valign, color, scale, rotation, alpha}> or array of this struct");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n must be a i18n struct");
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
		show_debug_message("I18n ERROR - Drawing preset name and data must be the same length");
		exit;
	}

	// Set data
	if (!is_array(locale)) {
		locale = [locale];
	}

	for (var i = 0; i < array_length(locale); i++) {
		for (var j = 0; j < array_length(preset_name); j++) {
			var names = struct_get_names(data[j]);

			for (var k = 0; k < array_length(names); k++) {
				i18n.data[$ locale[i]].drawings[$ preset_name[j]][$ names[k]] = data[j][$ names[k]];
			}
		}
	}
}


/**
 * @desc description
 * @param {String | Array<String>} code Description
 * @param {Bool | Struct.i18n_create} [i18n]=false Description
 */
function i18n_add_locales(code, i18n = false) {
	// Guard clauses
	if (!(is_string(code) || is_array(code))) {
		show_debug_message("I18n ERROR - Code must be a string or an array of strings");
		exit;
	}

	if (!(is_struct(i18n) || is_bool(i18n))) {
		show_debug_message("I18n ERROR - i18n must be a i18n struct");
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
