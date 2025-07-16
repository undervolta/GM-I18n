/** 
 * GM-I18n v1.0.0
 * https://gm-i18n.lefinitas.com/v1/api-reference/constructors
 */


// Constructors that can be used to create structs (using `new` keyword)
/**
 * Creates a I18nLocaleInit struct for initializing a locale.
 * @param lang_code Locale code (e.g. "en").
 * @param lang_name Locale name (e.g. "English").
 * @param lang_file Path to locale file(s), which will be loaded on initialization automatically (e.g. "~/langs/en.json").
 * @returns I18nLocaleInit struct.
 */
export function I18nLocaleInit(
	lang_code: string,
	lang_name: string,
	lang_file?: string | string[]       // default = ""
): I18nLocaleInit


/**
 * (INTERNAL) Struct constructor for loading locale files.
 * @param interval Time interval in seconds to load the next file.
 * @param i18n_struct I18n struct reference.
 * @returns I18nLoad struct.
 */
export function I18nLoad(
	interval: number | number[],
	i18n_struct?: I18n | boolean        // default = false (using global i18n struct)
): I18nLoad


export function I18nDrawings(
	draw_font?: Font | string,			// string = the name of the font
	draw_halign?: fa_left | fa_center | fa_right,
	draw_valign?: fa_top | fa_middle | fa_bottom,
	draw_color?: Color | Color[],		// color constants, or color gradient [c1, c2, c3, c4]
	draw_scale?: number,
	draw_rotation?: number,
	draw_alpha?: number,                // 0 - 1
	text_sep?: number,                  // default = -1
	text_width?: number,                // default = room_width,
	is_template?: boolean               // mark this drawing as a template, default = false
): I18nDrawings


// Structs' members/fields
export type I18nLocaleInit = {
	code: string;
	name: string;
	file?: string | string[];
}

export type I18nLoad = {
	i18n: I18n;
	files: string[];
	files_locale: string[];
	max_step: integer;               // integer
	step: integer;                   // integer
	step_index: integer;             // integer
	step_time: integer[];            // integer[]
	time: number | number[];
	dt: () => number;
	update: (
		use_delta_time?: boolean    // default = false
	) => void;
	load: (
		filename: string,
		locale: string
	) => void;
	flatten: (
		struct: {
			[key: string]: string
		},
		i18n: I18n,
		locale?: string,            // default = ""
		prefix?: string             // default = ""
	) => void;
}

export type I18nDrawings = {
	alpha?: number;                     // 0 - 1
	color?: number | number[];          // color constants, or color gradient [c1, c2, c3, c4]
	draw_type: I18N_DRAW_TEXT;
	font?: Font;
	halign?: fa_left | fa_center | fa_right;
	rotation?: number;
	scale?: number;
	sep: number;                        // default = -1
	valign?: fa_top | fa_middle | fa_bottom;
	width: number                      	// default = room_width
}

export type I18n = {
    cache: {
        ids: integer[];
        values: string[];
        keys: string[];
        data: any[];
        locales: string[]
    };
    cached: boolean;                	// enable message caching
    data: {
        [locale_code: string]: {
            dictionaries: {
                [key: number]: string               // key = dictionary key (hashed automatically)
            };
            drawings: {
                [preset_name: string]: I18nDrawings
            };
            messages: {
                [key: string | number]: string      // key = message key
            };
        }
    };
    debug: boolean;                     // debug mode
    default_locale: string;             // default/fallback language
    default_message: string;            // default message
    drawing_presets: I18nDrawings[];    // drawing presets in all locales (become undefined after all files are loaded and all fonts are converted)
    hashed: boolean;                    // enable hashed message
    linked_end: string;                 // linked message end delimiter
    linked_start: string;               // linked message start delimiter
    loader: I18nLoad;                   // locale files loader (become undefined after all files are loaded)
    locale: string;                     // selected/current language
    locales: I18nLocaleInit[];          // available locales from `locales` parameter
    name: string;                       // variable name to store the i18n system
    plural_delimiter: string;           // plural message delimiter
    plural_start_at: number;            // plural message starting index
    refs: {
        messages: {
            inst: (Instance | "global")[];
            refs: string[];
            keys: string[];
            data: number | any[] | {
				[key: string]: any;
			}[];
        };
        assets: {
            inst: (Instance | "global")[];
            refs: string[];
            assets: {[key: string]: Asset}[]
        }
    };
    scope: "global" | "instance";       // scope of the i18n system
    time: number | number[] | boolean;  // locale files loading interval
}


// not part of the API
import {
	integer,
	I18N_DRAW_TEXT,
	fa_left,
	fa_center,
	fa_right,
	fa_top,
	fa_middle,
	fa_bottom,
	Asset,
	Font,
	Instance,
	Color
} from "./I18nConstants"
