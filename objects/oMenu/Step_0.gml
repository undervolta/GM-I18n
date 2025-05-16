/// @description Simple x animation

if (active) {
	x_mod += (20 - x_mod) / 15;
} else {
	x_mod += (0 - x_mod) / 15;
}

x = xstart + x_mod;
