![Banner](img/Banner.webp)

**A powerful, open-source internationalization (i18n) library for GameMaker 2.3+**

## Features

- Comprehensive multi-language support with JSON-based locale files.
- Automatic locale file loading with configurable timing.
- Flexible translation system:
	- Static translations for fixed text.
	- Dynamic translations with variable interpolation.
	- Real-time translation updates.
- Advanced pluralization with customizable rules.
- Dictionary system for managing related translations.
- Rich text drawing system with:
	- Multiple formatting presets.
	- Custom alignment and positioning.
	- Color and style options.
	- Scale and rotation support.
- Asset localization for sprites, sounds, and other assets.
- Debug mode with detailed logging and validation.
- Optimized performance with optional hashing.

## Supported GameMaker Versions

This library have been tested and working on:

- Windows VM
	- IDE
		- v2024.13.1.193
	- Runtime
		- v2024.13.1.242
- Windows YYC
	- IDE
		- v2024.13.1.193
	- Runtime
		- v2024.13.1.242

It should work on other versions of GameMaker 2.3+ too. Please let me know on the [tested versions page](https://github.com/undervolta/GM-I18n/issues) if you tested it on other versions and it works.

## Installation

1. Download the latest release from the [releases page](https://github.com/undervolta/GM-I18n/releases).
2. Extract the contents of the zip file.
3. Drag and drop the `GM-I18n <version>.yymps` file into GameMaker window.
4. Import the `scI18n` script into your project.

## Usage Example

**Initialize the i18n system**
```gml
// objController - Create Event

// Initialize the i18n system
global.i18n = i18n_create("g.i18n", "en", [
	new I18nLocaleInit("en", "English", "~/langs/en.json"),
	new I18nLocaleInit("id", "Bahasa Indonesia", "~/langs/id.json"),
	new I18nLocaleInit("ja", "日本語", "~/langs/ja.json")
]);

// Create fonts if there's any locale with non-English characters
global.font_ja = font_add(working_directory + "fonts/NotoSansJP-Medium.ttf", 32, 0, 0, 32, 127);
```

**Load the locale files**
```gml
// objController - Step Event

// Load the locale files
i18n_update_loader();
```

**Create message references**
```gml
// objMyObject - Create Event

// Create message references for dynamic translations
test_msg = i18n_create_ref_message("test_msg", "hello");
test_msg_arr = [
	i18n_create_ref_message("test_msg_arr.0", "goodbye"),
	i18n_create_ref_message("test_msg_arr.1", "items.sword")
]
```

**Draw the message**
```gml
// objMyObject - Draw Event

// Draw the message
draw_text(0, 0, test_msg);
draw_text(0, 32, test_msg_arr[0]);

// Draw the message directly using the available message key
i18n_draw_message(x, y, "@:btn_text");
```

**Update the locale**
```gml
// objMyObject - Left Released Event

// Update the locale, all references will be updated automatically
i18n_set_locale("ja);
```


## Documentation

The usage example above is just a basic example. You can do more with this library. You can find the full documentation [here](https://undervolta.github.io/GM-I18n/docs/index.html).

## Questions & Feature Requests

If you have any questions or feature requests, please feel free to open an issue on the [GitHub repository](https://github.com/undervolta/GM-I18n/issues). I'll try my best to answer your questions and implement your feature requests. But, please don't expect too much, I'm not a professional programmer and I'm doing this in my free time.

## Contributing

Pull requests are welcome, as long as you're not breaking the existing code. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to test the code before submitting a pull request. Please also make sure to follow the code style of the project.

## Support

If you like this project, please consider supporting me on [Ko-fi](https://ko-fi.com/undervolta) or [Trakteer](https://trakteer.id/undervolta). Your support is greatly appreciated!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

