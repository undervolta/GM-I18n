/** 
 * GM-I18n v1.0.0
 * https://gm-i18n.lefinitas.com/v1/api-reference/export functions
 */


/**
 * Search the target value index in array using binary search.
 * @param array Array to search.
 * @param target Target value to search.
 * @returns Index of the target value if found, -1 otherwise.
 */
export function binary_search(
	array: any[],
	target: any
): number

/**
 * Search the index where target value should be inserted using binary search.
 * @param array Array to search.
 * @param target Target value to search.
 * @returns Index of the target value if found, -1 otherwise.
 */
export function binary_search_insert_pos(
	array: any[],
	target: any
): number


/**
 * Add localized dictionaries to a locale in the I18n struct.
 * @param locale Locale code (e.g. "en").
 * @param data Localized dictionaries array (e.g. ["key", "value"] or [["key1", "value1"], ["key2", "value2"], ...]).
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_add_dictionaries(
	locale: string,
	data: [string, string] | [string, string][],    // [key, value] or [[key1, value1], [key2, value2], ...]
	i18n?: I18n | boolean                           // default = false (using global i18n struct)
): void

/**
 * Add localized drawing presets to a locale in the I18n struct.
 * @param locale Locale code (e.g. "en").
 * @param preset_name Drawing preset name (e.g "title").
 * @param data Struct of I18nDrawings or array of these structs (e.g. new I18nDrawings(...)).
 * @param use_ref Use the first I18nDrawings struct as a reference, instead of creating a new one. Only works if locale is an array.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_add_drawings(
	locale: string | string[],
	preset_name: string | string[],
	data: I18nDrawings | I18nDrawings[],
	use_ref?: boolean,            // default = true
	i18n?: I18n | boolean         // default = false (using global i18n struct)
): void

/**
 * Add locale(s) with empty data to the i18n struct
 * @param code Locale code(s) (e.g. "en", ["en", "fr"]).
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_add_locales(
	code: string | string[],
	i18n?: I18n | boolean         // default = false (using global i18n struct)
): void

/**
 * Add localized messages to a locale in the I18n struct.
 * @param locale Locale code (e.g. "en").
 * @param data Localized messages struct (e.g. {key: "value", ...}).
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @param prefix (INTERNAL USE ONLY) Prefix to add to the message keys.
 */
export function i18n_add_messages(
	locale: string,
	data: {
		[key: string]: string
	},
	i18n?: I18n | boolean,         	// default = false (using global i18n struct),
	prefix?: string             	// default = ""
): void

/**
 * Check if a cache exists in the I18n struct.
 * @param cache_id Id of the cache to check. Can be get from i18n_get_cache_id().
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns True if the cache exists, false otherwise.
 */
export function i18n_cache_exists(
	cache_id: number,
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): boolean

/**
 * Clear all caches in the I18n struct.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_clear_cache(
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Clear all messages in the I18n struct for a specific locale or all locales.
 * @param locale Locale code (e.g. "en"). Leave it empty to remove the message(s) from all locales. Pass "all" to remove the message(s) from all locales.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_clear_messages(
	locale: string | string[],
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Choose a value from a struct based on a locale.
 * @param data The available data to choose from (e.g. {en: "Choose me!", fr: "Choisissez-moi!"}).
 * @param locale Locale code (e.g. "en").
 * @param single_use Delete the `data` struct after choosing it?
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns The chosen value.
 */
export function i18n_choose(
	data: {
		[locale_code: string]: any
	},
	locale?: string,                // default = "" (use the current locale)
	single_use?: boolean,           // default = false
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): any

/**
 * Create an i18n struct and initialize it.
 * @param var_name Variable name that will be assigned to the i18n struct (e.g. "i18n", "global.i18n").
 * @param default_locale Default locale code (e.g. "en").
 * @param locales Array of I18nLocaleInit structs (e.g. [new I18nLocaleInit("en", "English")]).
 * @param options Optional struct with additional options (e.g. {hashed: true, time: 1}).
 * @returns The created I18n struct.
 */
export function i18n_create(
	var_name: string,                           // variable name to store the i18n system
	default_locale: string,                     // default/fallback language code
	locales: I18nLocaleInit[],                  // array of `I18nLocaleInit` struct to initialize the available locales
	options?: boolean | {                       // default = false (no options)
		debug?: boolean,                        // toggle debug mode, default = false
		default_message?: string,               // default message, default = ""
		hashed: boolean,                        // enable hashed message, default = true
		linked_end?: string,                    // linked message end delimiter, default = "]"
		linked_start?: string,                  // linked message start delimiter, default = "["
		plural_delimiter?: string,              // plural message delimiter, default = "|"
		plural_start_at?: number,               // plural message starting index, default = 0
		time?: number | number[] | boolean      // locale files loading interval, default = false (load all files at once)
	}
): I18n

/**
 * Create a message cache in the I18n struct.
 * @param key Message key (e.g. "title").
 * @param data Additional data to pass to the message (e.g. {name: "John"}).
 * @param locale Locale code (e.g. "en").
 * @param value Direct value to set in cache (e.g. "Hello World!"). Leave it empty to get the value from the message.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_create_cache(
	key: string,
	data?: number | any[] | { [key: string]: any },
	locale?: string,                                // default = "" (use the current locale)
	value?: string,
	i18n?: I18n | boolean                           // default = false (using global i18n struct)
): void

/**
 * Create an asset reference for a dynamic asset.
 * @param var_name This variable name (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param locale_asset Struct of localized asset (e.g. {en: sprSplashEn, fr: sprSplashFr, ...}).
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns The asset based on the passed parameters.
 */
export function i18n_create_ref_asset(
	var_name: string,
	locale_asset: { [locale_code: string]: Asset },
	i18n?: I18n | boolean                           // default = false (using global i18n struct)
): Asset

/**
 * Create a message reference for a dynamic translated message.
 * @param var_name This variable name (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param key Message key (e.g. "title").
 * @param data Additional data to pass to the message (e.g. {name: "John"}).
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns The message based on the passed parameters.
 */
export function i18n_create_ref_message(
	var_name: string,
	key: string,
	data?: number | any[] | { [key: string]: any },
	i18n?: I18n | boolean                           // default = false (using global i18n struct)
): string

/**
 * Draw a localized message.
 * @param x The x position to draw the message.
 * @param y The y position to draw the message.
 * @param text The text to draw. Can be any text, including message from i18n_get_message() (e.g. "Hello World!"), or a message reference variable (created by i18n_create_ref_message()). Use "@:" prefix to use this as message key (e.g. "@:hello").
 * @param data Data to pass to the message (e.g. 1, ["Hello World!"]). Struct isn't supported in this function.
 * @param preset_name Drawing preset name (e.g. "default"). Leave it empty if you don't want to use a drawing preset.
 * @param locale Locale code (e.g. "en").
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_draw_message(
	x: number,
	y: number,
	text: string,
	data?: number | any[],
	preset_name?: string,
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Flatten a struct into i18n messages.
 * @param data_struct The struct to flatten (e.g. {hello: "Hello", goodbye: "Goodbye"}).
 * @param locale Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @param prefix (INTERNAL USE ONLY) The prefix to use for the keys (e.g. "greetings").
 * @param direct_write If true, write the messages directly to the I18n struct. If false, return an array of the flattened keys.
 */
export function i18n_flatten_keys(
	data_struct: {
		[key: string]: string
	},
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean,          // default = false (using global i18n struct)
	prefix?: string,				// default = "" (internal use)
	direct_write?: boolean			// default = false (internal use)
): undefined | string[]

/**
 * Get a static asset that created using i18n_create_ref_asset().
 * @param var_name Variable name based on the var_name in i18n_create_ref_asset() function (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param ref Reference name or instance id based on the ref in i18n_create_ref_asset() function. Recommended to pass "global" if the reference is created in a global variable, or pass the instance id if the reference is created in an instance.
 * @param locale Locale code (e.g. "en").
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns The asset based on the passed parameters.
 */
export function i18n_get_asset_from_ref(
	var_name: string,
	ref: "global" | Instance | Object,
	locale?: string,                    // default = "" (use the current locale)
	i18n?: I18n | boolean               // default = false (using global i18n struct)
): Asset

/**
 * Get the cache id from a message
 * @param key Message key (e.g. "title").
 * @param data Data to pass to the message (e.g. 1, ["Hello World!"]). Struct isn't supported in this function.
 * @param locale Locale code (e.g. "en").
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns The cache id.
 */
export function i18n_get_cache_id(
	key: string,
	data?: string,                	// default = undefined
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): integer

/**
 * Get the cache id from a message reference.
 * @param var_name Variable name based on the var_name in i18n_create_ref_message() (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param ref Reference name or instance id based on the ref in i18n_create_ref_message() function. Recommended to pass "global" if the reference is created in a global variable, or pass the instance id if the reference is created in an instance.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns The cache id.
 */
export function i18n_get_cache_id_from_ref(
	var_name: string,
	ref: "global" | Instance | Object,
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): integer

/**
 * Get all drawing presets name from a locale in the I18n struct.
 * @param locale Locale code (e.g. "en").
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Array of drawing presets name.
 */
export function i18n_get_drawing_presets(
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): string[]

/**
 * Get drawing preset(s) struct from a locale.
 * @param preset_name Drawing preset name (e.g "title", ["title", "subtitle"]).
 * @param locale Locale code (e.g. "en").
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns I18nDrawings struct or array of I18nDrawings struct.
 */
export function i18n_get_drawings(
	preset_name: string | string[],
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): I18nDrawings | I18nDrawings[]

/**
 * Get drawing data from a preset in a locale.
 * @param preset_name Drawing preset name (e.g "title").
 * @param type Drawing data type (e.g. I18N_DRAWING.FONT).
 * @param locale Locale code (e.g. "en").
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Drawing data.
 */
export function i18n_get_drawings_data(
	preset_name: string,
	type: I18N_DRAWING,             // I18N_DRAWING enum
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): number | Font | undefined

/**
 * Get current locale code.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Current locale code.
 */
export function i18n_get_locale(
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): string

/**
 * Get all initialized locales in the I18n struct.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Array of I18nLocaleInit struct.
 */
export function i18n_get_locales(
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): I18nLocaleInit[]

/**
 * Get all locales code in the I18n struct.
 * @param include_non_init Include non initialized locales.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Array of locales code.
 */
export function i18n_get_locales_code(
	include_non_init?: boolean,     // default = false
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): string[]

/**
 * Get all initialized locales name in the I18n struct.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Array of locales name.
 */
export function i18n_get_locales_name(
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): string[]

/**
 * Get a static message that created using i18n_create_ref_message().
 * @param var_name Variable name based on the var_name in i18n_create_ref_message() (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param ref Reference name or instance id based on the ref in i18n_create_ref_message() (e.g. "text"). Recommended to pass "global" if the reference is created in a global variable, or pass the instance id if the reference is created in an instance.
 * @param locale Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns The localized message.
 */
export function i18n_get_message_from_ref(
	var_name: string,
	ref: "global" | Instance | Object,
	locale?: string,                    // default = "" (use the current locale)
	i18n?: I18n | boolean               // default = false (using global i18n struct)
): string

/**
 * Get localized message(s) based on key(s) and data.
 * @param key Message key (e.g. "hello").
 * @param data Additional data for the message.
 * @param locale Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @param create_cache (INTERNAL USE ONLY) Create cache for the message(s).
 * @returns The localized message(s).
 */
export function i18n_get_messages(
	key: string | string[],
	data?: number | any[] | { [key: string]: any },
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean,          // default = false (using global i18n struct)
	create_cache?: boolean          // default = false
): string | string[]

/**
 * (INTERNAL USE ONLY) Get instance or struct reference from an asset reference.
 * @param index The index of the reference.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Instance or struct reference.
 */
export function i18n_get_ref_asset(
	index: integer,
	i18n?: I18n | boolean               // default = false (using global i18n struct)
): Instance | Struct | "global"

/**
 * (INTERNAL USE ONLY) Get instance or struct reference from a message reference.
 * @param index Index of the reference.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Instance or struct reference.
 */
export function i18n_get_ref_message(
	index: integer,
	i18n?: I18n | boolean               // default = false (using global i18n struct)
): Instance | Struct | "global"

/**
 * Check if locale files in the I18n struct are loaded.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_is_ready(
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): boolean

/**
 * Load messages from JSON files into the I18n struct.
 * @param file JSON file(s) to load (e.g. "en.json" or ["en1.json", "en2.json"]).
 * @param locale Locale code (e.g. "en"). Leave it empty to use the file name as the locale code.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_load_messages(
	file: string | string[],
	locale?: string,
	i18n?: I18n | boolean
): void

/**
 * Check if a locale is exist in the I18n struct.
 * @param locale Locale code (e.g. "en").
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_locale_exists(
	locale: string,
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): boolean

/**
 * Check if a message is exist in the I18n struct.
 * @param key Message key (e.g. "hello").
 * @param locale Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_message_exists(
	key: string,
	locale: string,                 // default = "" (use the current locale)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): boolean

/**
 * Remove message(s) from the I18n struct.
 * @param key Message key (e.g. "hello", or ["hello", "world"]).
 * @param locale Locale code (e.g. "en"). Leave it empty to remove the message(s) from all locales. Pass "all" to remove the message(s) from all locales.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_remove_messages(
	key: string | string[], 
	locale?: string | string[], 
	i18n?: I18n | boolean
): void

/**
 * Set the default message when a message is not found.
 * @param message Default message.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_set_default_message(
	message: string,
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Change the current locale.
 * @param code Locale code (e.g. "en").
 * @param update_refs Also update the message references?
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_set_locale(
	code: string,
	update_refs?: boolean,         // default = true
	i18n?: I18n | boolean          // default = false (using global i18n struct)
): void

/**
 * Unload messages from JSON files from the I18n struct.
 * @param file JSON file(s) to unload (e.g. "en.json" or ["en1.json", "en2.json"]).
 * @param locale Locale code (e.g. "en"). Leave it empty to use the file name as the locale code.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_unload_messages(
	file: string | string[],
	locale?: string,
	i18n?: I18n | boolean
): void

/**
 * Update the cache value in the I18n struct.
 * @param cache_id Id of the cache to check. Can be get from i18n_get_cache_id().
 * @param value The new value to set in cache (e.g. "Hello World!"). Leave it empty to update the value based on the cached message key and data.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_update_cache(
	cache_id: number,
	value?: string,
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Update the drawing preset data.
 * @param preset_name Drawing preset name (e.g "title").
 * @param data Data to update the drawing preset with (e.g. ["font", fArial], [["font", fArial], ["alpha", 1], ...], {font: fArial, alpha: 1, ...}).
 * @param locale Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_update_drawings(
	preset_name: string,
	data: [string, (number | Font)] | [string, (number | Font)][] | {
		[key: string]: number | Font
	},
	locale ?: string,                // default = "" (use the current locale)
	i18n ?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Update the I18n loader and fonts in each drawing preset.
 * @param use_delta_time Use time-based increment instead of frame-based increment. 
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_update_loader(
	use_delta_time?: boolean,       // default = false
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Update the plural variable value on a message reference.
 * @param var_name Variable name based on the var_name in i18n_create_ref_message() (e.g. "text"). Structs are supported (e.g. "text.title").
 * @param value The new pluralization value (not the index) (e.g. 1).
 * @param update_refs Also update all references in the I18n struct?
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_update_plurals(
	var_name: string,
	value: number,
	update_refs?: boolean,         // default = false
	i18n?: I18n | boolean          // default = false (using global i18n struct)
): void

/**
 * Update all references in the I18n struct.
 * @param type Type of reference to update (e.g. I18N_REF.MESSAGES).
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 */
export function i18n_update_refs(
	type?: I18N_REF,                // default = I18N_REF.ALL (update both message and asset)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): void

/**
 * Get the value from the message cache.
 * @param cache_id Id of the cache to check. Can be get from i18n_get_cache_id().
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns Value of the cache.
 */
export function i18n_use_cache(
	cache_id: number | number[],
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): string | string[]

/**
 * Use a drawing preset.
 * @param preset_name Drawing preset name (e.g "title").
 * @param locale Locale code (e.g. "en"). Leave it empty to use the current locale.
 * @param i18n I18n struct reference (e.g. i18n), or leave it empty to use the global i18n struct.
 * @returns I18nDrawings struct.
 */
export function i18n_use_drawing(
	preset_name: string,
	locale?: string,                // default = "" (use the current locale)
	i18n?: I18n | boolean           // default = false (using global i18n struct)
): I18nDrawings


// not part of the API
import {
	integer,
	I18N_REF,
	I18N_DRAWING,
	Asset,
	Font,
	Instance,
	Struct,
} from "./I18nConstants"

import {
	I18n,
	I18nLocaleInit,
	I18nDrawings,
} from "./I18nConstructors"
