/*
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


function I18nLocaleInit(
	lang_code: String, 
	lang_name: String, 
	lang_file?: String | String[] 					// file path
) -> Struct.I18nLocaleInit

Struct.I18nLocaleInit {
	code: String,
	file?: String | String[],
	name: String
}


function I18nLoad(
	interval: Real | Real[], 
	i18n_struct: Struct.i18n_create | Boolean		// boolean = global i18n
) -> Struct.I18nLoad 

Struct.I18nLoad {
	i18n: Struct.i18n_create,				
	files: String[],
	files_locale: String[],
	max_step: Integer,
	step: Integer,
	step_index: Integer,
	step_time: Integer[],
	time: Real | Real[],							// real = load time interal, real[] = array of load times

	dt: Function,
	flatten: Function,
	load: Function,
	update: Function
}


function i18n_create(
	var_name: String, 
	default_locale: String,
	locales: Struct.I18nLocaleInit[],
	options?: Struct | Boolean						// boolean = (empty)
) -> Struct.i18n_create 

Struct.i18n_create {
	data: Struct {
		[locale_code: String]: Struct {
			dictionaries: Struct {
				[key: Real]: String 				// key = dictionary name
			},
			drawings: Struct {
				[preset_name: String]: Struct.I18nDrawings	
			},
			messages: Struct {
				[key: String | Real]: String		// key = message
			}
		}
	},
	default_locale: String,							// default/fallback language
	locale: String,									// selected language
	locales: Struct.I18nLocaleInit[],				// available languages
	name: String,									// variable name
	refs: Struct {
		messages: Struct {
			inst: (Id.Instance | "global")[],			
			refs: String[],
			keys: String[],
			data: (Real | Any[] | Struct)[]
		},
		assets: Struct {
			inst: (Id.Instance | "global")[],
			refs: String[],
			assets: Struct[]
		}
	},
	scope: "global" | "instance",

	// Options
	debug?: Boolean ?? false,
	default_msg?: String ?? "",
	hashed: Boolean ?? true,
	linked_end?: String ?? "]",
	linked_start?: String ?? "[",
	plural_delimiter?: String ?? "|",
	plural_start_at?: Integer ?? 0,
	time?: Real | Real[] | Boolean ?? false,		// real = load time interal, real[] = array of load times, boolean = load all files at once

	// Don't touch
	loader: Struct.I18nLoad 						// become undefined after all files are loaded
}


function i18n_update_loader(
	use_delta_time: Boolean ?? false
	i18n: Struct.i18n_create | Boolean, 			// boolean = global i18n
) -> Void


function i18n_add_messages(
	locale: String,
	data: Struct,									// Struct = {key: value}
	i18n?: Struct.i18n_create | Boolean,			// boolean = global i18n
	prefix?: String									// internal use only
) -> Void


function i18n_add_dictionaries(
	locale: String,
	data: [String, Any] | [String, Any][],
	i18n?: Struct.i18n_create | Boolean
) -> Void


function i18n_add_drawings(
	locale: String | String[],
	preset_name: String | String[],						// if preset = string, then data = struct. if preset = string[], then data = struct[]
	data: Struct.I18nDrawings | Struct.I18nDrawings[],	// Struct = {font: Asset.GMFont, halign: Constant.HAlign, valign: Constant.VAlign, color?: Constant.Color, scale?: Real, rotation?: Integer, alpha?: Real}
	use_ref: Boolean ?? true,
	i18n?: Struct.i18n_create | Boolean					// boolean = global i18n
) -> Void

Struct.I18nDrawings {
	alpha?: Real,
	color?: Constant.Color | Constant.Color[],
	font?: Asset.GMFont,
	halign?: Constant.HAlign,
	valign?: Constant.VAlign,

	// Drawing specific
	draw_type?: Constant.I18N_DRAW_TEXT,				// used in i18n_draw_message()
	rotation?: Real ?? undefined,
	scale?: Real ?? undefined,
	sep?: Real ?? -1,
	width?: Real ?? room_width
}


function i18n_add_locales(
	code: String | String[],
	i18n?: Struct.i18n_create | Boolean,			// boolean = global i18n
) -> Void


function i18n_is_ready(
	i18n?: Struct.i18n_create | Boolean
) -> Boolean


function i18n_locale_exists(
	locale: String,
	i18n?: Struct.i18n_create | Boolean
) -> Boolean


function i18n_message_exists(
	key: String,
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> Boolean


function i18n_get_locale(
	i18n?: Struct.i18n_create | Boolean
) -> String


function i18n_get_locales(
	i18n?: Struct.i18n_create | Boolean
) -> Struct.I18nLocaleInit[]


function i18n_get_locales_code(
	i18n?: Struct.i18n_create | Boolean
) -> String[]


function i18n_get_locales_name(
	i18n?: Struct.i18n_create | Boolean
) -> String[]


function i18n_get_messages(
	key: String | String[],
	data?: Real | Any[] | Struct | undefined ?? undefined,
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> String | String[]


function i18n_get_drawing_presets(
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> String[] | []


function i18n_update_drawings(
	preset_name: String,
	data: Any[] | Struct | Struct.I18nDrawings,
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> Void


function i18n_get_drawings(
	preset_name: String | String[],
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> Struct.I18nDrawings | Struct.I18nDrawings[]


function i18n_get_drawings_data(
	preset_name: String,
	type: Constant.I18N_DRAWING,
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> Any


function i18n_create_ref_message(
	var_name: String,
	key: String,
	data?: Real | Any[] | Struct ?? undefined,
	i18n?: Struct.i18n_create | Boolean
) -> String


function i18n_create_ref_asset(
	var_name: String,
	locale_asset: Struct,
	i18n?: Struct.i18n_create | Boolean
) -> Any


function i18n_get_ref_message(
	index: Integer,
	i18n?: Struct.i18n_create | Boolean
) -> Id.Instance | Struct


function i18n_get_ref_asset(
	index: Integer,
	i18n?: Struct.i18n_create | Boolean
) -> Id.Instance | Struct


function i18n_update_refs(
	type: Constant.I18N_REF,
	i18n?: Struct.i18n_create | Boolean
) -> Void


function i18n_update_plurals(
	var_name: String,
	value: Real,
	update_refs?: Boolean ?? false,
	i18n?: Struct.i18n_create | Boolean
) -> Void


function i18n_get_message_from_ref(
	var_name: String,
	ref?: String | Id.Instance | Asset.GMObject ?? "",
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> String


function i18n_get_asset_from_ref(
	var_name: String,
	ref?: String | Id.Instance | Asset.GMObject ?? "",
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> Any


function i18n_set_default_message(
	message: String,
	i18n?: Struct.i18n_create | Boolean
) -> Void


function i18n_set_locale(
	code: String,
	update_refs?: Boolean ?? false,
	i18n?: Struct.i18n_create | Boolean
) -> Void


function i18n_use_drawing(
	preset_name: String,
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> Struct.I18nDrawings | Void


function i18n_draw_message(
	x: Real,
	y: Real,
	text: String,
	data?: Real | Any[] ?? undefined,
	preset_name?: String ?? "",
	locale?: String ?? Function.i18n_get_locale(),
	i18n?: Struct.i18n_create | Boolean
) -> Void

