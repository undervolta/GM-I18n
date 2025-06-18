# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [0.1.1] - 2025-06-18

### Added

- Detailed [documentation](https://gm-i18n.lefinitas.com/).

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

---

[Unreleased]: https://github.com/undervolta/GM-I18n/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/undervolta/GM-I18n/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/undervolta/GM-I18n/commits/v0.1.0
