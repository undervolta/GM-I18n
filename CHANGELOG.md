# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.0.0] - 2025-07-19

### Added

- Helper functions:
  - `binary_search()`
  - `binary_search_insert_pos()`
- Core functions:
  - `i18n_cache_exists()`
  - `i18n_choose()`
  - `i18n_clear_cache()`
  - `i18n_clear_messages()`
  - `i18n_create_cache()`
  - `i18n_flatten_keys()`
  - `i18n_get_cache_id()`
  - `i18n_get_cache_id_from_ref()`
  - `i18n_load_messages()`
  - `i18n_remove_messages()`
  - `i18n_unload_messages()`
  - `i18n_update_cache()`
  - `i18n_use_cache()`
- Definition files:
  - `I18nConstants.d.ts`
  - `I18nConstructors.d.ts`
  - `I18nFunctions.d.ts`

## Fixed

- Font asset in the drawing presets (HTML5 export) aren't recognized if the fonts haven't been loaded yet.

## Changed

- Definition files (for offline guide/documentation) are now written in TypeScript and moved to the `.zip` package file, instead of inside the `.yymps` file.
- Debug option is now showing the parameters value in the console.
- `I18nDrawings` constructor now accept a `is_template` parameter to mark it as a drawing template.
- `draw_font` parameter in `I18nDrawings` constructor now accept string as the font name.
- Struct member in `I18nDrawings` constructor now validate the input if it's marked as a normal drawing preset (`is_template` is false).
- `draw_type` struct member in `I18nDrawings` constructor is now more efficient.
- Add `cached` option in `i18n_create()` function to enable message caching.
- Add `cache` struct member in `I18n` struct to store the cache data.
- `i18n_update_loader()` function now also update the font asset in the drawing presets if the font name is a string.
- `i18n_get_messages()` function now accept `create_cache` parameter to create cache for the message(s).
- `i18n_get_messages()` and `i18n_draw_message()` functions now will use the available cache first if the `cached` option is enabled, and create it if the cache doesn't exists and `create_cache` is enabled.
- `i18n_draw_message()` function now set the available drawing preset directly if the `preset` parameter is provided without calling `i18n_use_drawing()` function.
- `draw_text*` built-in functions in the `i18n_draw_message()` function is now more efficient.

---

## [0.1.1] - 2025-06-18

### Added

- Detailed [documentation](https://gm-i18n.lefinitas.com/).
- Demo for Windows and HTML5.

### Fixed

- `i18n_get_message_from_ref()` and `i18n_get_asset_from_ref()` functions won't recognize the reference, even if the `ref` parameter is correct.
- Pluralization in `i18n_get_messages()` function won't accept `plural` as a number type without setting the `plural_value`.
- Dictionary in `i18n_get_messages()` function always use current locale, even if it's marked as dynamic locale.

### Changed

- Dictionary accept a full string as the key (even if it contains space), instead of only accept a single word.

### Removed

- Basic documentation.

---

## [0.1.0] - 2025-05-20

### Added

- Initial release.
- Core features implemented.
- Basic documentation.
- Basic tests and demo.


[Unreleased]: https://github.com/undervolta/GM-I18n/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/undervolta/GM-I18n/compare/v0.1.1...v1.0.0
[0.1.1]: https://github.com/undervolta/GM-I18n/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/undervolta/GM-I18n/commits/v0.1.0