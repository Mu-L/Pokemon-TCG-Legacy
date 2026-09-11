shader_type canvas_item;

// ============================================================
// UI MENU TILE — one big rounded gradient plate on the main menu
// ============================================================
// The main menu is six of these. Each one carries its OWN hue, sampled off the
// theme's menu arc, and draws as a vertical gradient from a lightened top stop
// to a darkened bottom one. See UITheme.menu_tile_colours().
//
// This replaces six painted PNGs. They were fixed rainbow colours that followed
// no theme, and they were the last thing on the main menu that could not change
// with the rest of the game.
//
// ── WHY A SHADER AND NOT A StyleBoxFlat ──────────────────────
// The same reason the buttons are baked art: the project sets
// snap_2d_vertices_to_pixel for the pixel-art overworld, which facets a
// StyleBoxFlat's rounded corners and throws away their antialiasing. A shader
// draws the corner from a signed distance field, so it stays smooth at any size
// — and these tiles are up to 1140px wide, where a faceted corner is obvious.
//
// ── THE EDGE ─────────────────────────────────────────────────
// A single inset line along the bottom, the same idea as the button faces: it
// reads as a physical plate catching light from above rather than as a flat
// rectangle of colour.
// ============================================================

uniform vec4  top_color  : source_color = vec4(0.55, 0.32, 0.88, 1.0);
uniform vec4  bot_color  : source_color = vec4(0.35, 0.18, 0.62, 1.0);
uniform vec4  edge_col   : source_color = vec4(0.0, 0.0, 0.0, 0.28);
uniform float edge_h     = 6.0;
uniform float radius     = 28.0;
uniform vec2  rect_size  = vec2(670.0, 790.0);

// ── HOVER COMES THROUGH modulate, NOT THROUGH A UNIFORM ──────
// The menu already brightens a tile by tweening its container's `modulate`, and
// that tween also drives the icon and the label, so the whole tile lifts as one
// object. A shader that assigns COLOR outright would ignore it — this one reads
// the incoming vertex colour (which carries modulate) and multiplies it back in.
// Locked tiles are greyed the same way.

vec4 over(vec4 s, vec4 d) {
	float a = s.a + d.a * (1.0 - s.a);
	if (a <= 0.0) {
		return vec4(0.0);
	}
	return vec4((s.rgb * s.a + d.rgb * d.a * (1.0 - s.a)) / a, a);
}

void fragment() {
	vec4 node_col = COLOR;
	vec2 p = UV * rect_size;

	vec4 c = mix(top_color, bot_color, UV.y);

	// The inset bottom edge, following the rounded corners rather than cutting
	// straight across. Half a pixel of feather so it does not crawl.
	float e = smoothstep(rect_size.y - edge_h - 0.5, rect_size.y - edge_h + 0.5, p.y);
	c = mix(c, over(edge_col, c), e);

	// Rounded-rect silhouette from a signed distance field.
	vec2  h  = rect_size * 0.5;
	float r  = min(radius, min(h.x, h.y));
	vec2  d  = abs(p - h) - (h - vec2(r));
	float sd = length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0) - r;
	float w  = max(fwidth(sd) * 0.5, 0.0001);
	float mask = 1.0 - smoothstep(-w, w, sd);

	COLOR = vec4(c.rgb * node_col.rgb, c.a * node_col.a * mask);
}
