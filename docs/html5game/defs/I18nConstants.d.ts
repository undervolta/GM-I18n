/** 
 * GM-I18n v1.0.0
 * https://gm-i18n.lefinitas.com/v1/api-reference/constants
 */


export const enum I18N_DRAWING {
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

export const enum I18N_DRAW_TEXT {
    NORMAL,
    EXTENDED,
    COLORED,
    TRANSFORMED,
    EXT_COLORED,
    EXT_TRANSFORMED,
    TRANSFORMED_COLORED,
    EXT_TRANSFORMED_COLORED
}

export const enum I18N_REF {
    ALL,
    MESSAGES,
    ASSETS
}


// helper data type, not part of the original API
export interface integer { }
export interface Color { }
export interface Asset { }
export interface Font { }
export interface Object { }
export interface Instance { }
export interface Struct { }
export interface fa_left { }
export interface fa_center { }
export interface fa_right { }
export interface fa_top { }
export interface fa_middle { }
export interface fa_bottom { }
