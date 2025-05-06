/// @description Insert description here

show_debug_message($"is ready = {i18n_is_ready()}");
show_debug_message($"get locale = {i18n_get_locale()}");
show_debug_message($"get locales = {i18n_get_locales()}");
show_debug_message($"get locales code = {i18n_get_locales_code()}");
show_debug_message($"get locales name = {i18n_get_locales_name()}");

show_debug_message($"get messages = {i18n_get_messages("lang")}")
show_debug_message($"get messages = {i18n_get_messages(["nested.a", "nested.b"])}")
show_debug_message($"get drawing preset = {i18n_get_drawing_presets()}")
show_debug_message($"get drawing = {i18n_get_drawings("preset1")}")
show_debug_message($"get drawing = {i18n_get_drawings(["preset1", "preset2"])}")

//show_debug_message($"")