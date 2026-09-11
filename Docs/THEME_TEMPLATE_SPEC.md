# Pokémon TCG Legacy — UI theme template spec

**Purpose of this document.** You have a set of candidate colour themes. This
spec is the contract they must conform to before they can be dropped into the
game. Read it, convert each of your themes into the block shape in section 3,
run the checklist in section 6, and hand back what section 8 asks for.

Everything here is taken from the live code as of 2026-09-11. The single file
that matters is `Scripts/Global_Scripts/UI_Theme.gd`. Do not restate the spec
back — produce theme blocks.

---

## 1. What a theme is, and what it is not

A theme in this game is **39 key/value pairs and nothing else**. It is one entry
in the `THEMES` dictionary in `UI_Theme.gd`. There is no per-theme stylesheet, no
per-theme scene, no per-theme asset.

**A theme changes colour only.** Geometry, motion, type and spacing are shared by
every theme and live outside the dictionary:

| Shared, never per-theme | Where it lives |
|---|---|
| Type scale: sizes, faces, tracking, casing | `TYPE` |
| Bar heights, radii, paddings, animation timings | `METRICS` |
| Light-band width, spacing, angle, cadence, profile | the `CHEVRON_*` constants |
| Energy type colours | `ENERGY_COLOUR` |

The last one is a hard rule. Energy colours are the one place in this UI where
hue carries data rather than decoration, so Fire is the same red in every theme.
**Do not put energy colours in a theme block.**

Two of the 39 keys are not colours: `silhouette_invert` (bool) and
`silhouette_alpha` (float).

---

## 2. The two design rules a new theme must obey

These are written into the code as comments. They exist because the first pass
invented values per theme and the result did not line up.

### The button rule

**primary** is a gradient from the theme's signature stop down to its deep stop.
Where the chrome bar carries real colour, those are literally `chrome_grad_b`
over `chrome_grad_a`, so the confirm button is the header bar's own two colours.
Where the chrome bar is deliberately unsaturated, there is no signature stop to
borrow, so primary derives from `accent` instead: a mid-strength version of the
accent over a darkened one. **Primary must never be a colour that appears
nowhere else in the theme.**

**secondary** is a flat 10% tint of the field's own polarity. White at 0.10 on a
dark field, black at 0.10 on a light field. Its label must **not** be pure white,
because a secondary whose label matches primary's exactly stops reading as the
lesser of the two choices.

Primary is a **gradient** and the `selected` state is **flat**. That difference is
the only thing keeping them apart, so never give primary a flat fill.

### The chevron rule

Both chrome bars and the field are crossed by thin diagonal stripes that drift in
opposite directions. **A theme supplies only their colour**, through
`chrome_pattern` and `field_texture`. The width, spacing, angle and cadence are
global and identical in every theme: 3px of ink every 17px on the bars, 18px
every 74px on the field, at 115 degrees, hard-edged.

They are a fine TEXTURE, not broad bands of light. A version with wide feathered
bands was tried and reverted. The two colours are alpha tints laid over what is
behind them, around 0.045–0.07 on the bars and 0.022–0.05 on the field. On a
light field, tint them toward the theme's OWN hue rather than to neutral black —
that is what the light variants do.

**If they read as too busy, lower the alpha.** Do not widen them and do not space
them further apart.

---

## 3. The 39 keys

Group order and comments below are the order they appear in the file. Keep that
order in what you hand back.

### Chrome — the header and footer bars

| Key | What it is | Constraint |
|---|---|---|
| `chrome_grad_a` | Gradient stop at 0%, the left end of the bar | Deep / dark end |
| `chrome_grad_b` | Gradient stop at 52% | **See the warning below** |
| `chrome_grad_c` | Gradient stop at 100%, the right end | Usually the warmest stop |
| `chrome_fg` | Every label, title and icon sitting on the bar | Must clear 4.5:1 against all three stops |
| `chrome_pattern` | The chevrons crossing the bar | Alpha tint, around 0.045–0.07 |
| `chrome_line` | 1px keyline on the bar edge facing the content | Transparent for a vivid gradient bar; a real colour for a flat dark one, where it is the only thing separating bar from field |

> **`chrome_grad_b` is doing a second job.** `UIKit.selection_colour()` and the
> `selected` button variant both read it, so it is also **the** "this option is
> on" colour across the whole game. It must be vivid enough to carry white text
> at 17px and to stand out as a selected state. A theme whose header is
> deliberately dark or desaturated will produce an invisible selection. If that
> is true of any of your themes, say so in your hand-back rather than working
> around it — see section 7.

### Field — the play area and content background

| Key | What it is | Constraint |
|---|---|---|
| `field` | The base fill behind every screen | Sets the theme's light/dark polarity |
| `field_glow_top` | Low-alpha tint warming the top edge | Carries its own alpha, around 0.15–0.20 |
| `field_glow_bottom` | Low-alpha tint warming the bottom edge | Carries its own alpha, around 0.14–0.18 |
| `field_glow_left` | Large opaque wash, left of centre | Opaque; a near neighbour of `field` |
| `field_glow_right` | Large opaque wash, right of centre | Opaque; a near neighbour of `field` |
| `field_texture` | The light bands crossing the field | Alpha tint, around 0.03–0.04 |
| `field_fg` | Primary text on the field | Must clear 4.5:1 against `field` |
| `field_mute` | Secondary and de-emphasised text | Must clear 3:1 against `field` |

The two washes are **opaque** colours that fade to nothing across an ellipse, so
they recolour large areas. The two glows are **low-alpha** accents that only
warm the edges. Getting that backwards makes the field muddy rather than deep.
Keep both washes close to `field`; they add depth, not a second background.

### Surfaces and lines

| Key | What it is | Constraint |
|---|---|---|
| `panel` | Fill of any raised panel | Alpha tint of field polarity, around 0.05–0.07 |
| `line` | Dividers and rules | Alpha tint, around 0.12–0.15 |
| `slot` | Outline of an empty card or item slot | Alpha tint, around 0.16 |
| `slot_fill` | Interior of an empty slot | Very low alpha, around 0.03 |
| `chip_bg` | Background of a small pill or chip | Semi-opaque, derived from `field` |
| `chip_line` | Chip border | Alpha tint, around 0.18 |
| `chip_fg` | Text inside a chip | Must clear 4.5:1 against `chip_bg` |

### Accents and semantics

| Key | What it is | Constraint |
|---|---|---|
| `accent` | Player side, payable costs, selection, active Pokémon | The theme's lead accent |
| `accent_2` | Opponent side, Pokémon Powers, damage blocks | Must be clearly distinct from `accent` in hue, not only in lightness — it is how the player tells their side from the opponent's |
| `good` | Remaining HP, prices, save and confirm | Reads as green or positive |
| `danger` | Destructive actions | Reads as red |
| `warn` | A toggle that is currently on | Reads as amber |

`good`, `danger` and `warn` become flat button fills, so each must carry its own
label text. Pick a foreground per fill when you propose them.

### Status conditions

| Key | Condition |
|---|---|
| `status_psn` | Poisoned |
| `status_cnf` | Confused |
| `status_par` | Paralysed |
| `status_asl` | Asleep |
| `status_brn` | Burned |

These are the closest thing to data colours outside `ENERGY_COLOUR`. The player
learns them. **Recommendation: keep all five identical across every theme**, the
way the current parked themes do. Change them only if a theme's field makes one
unreadable, and flag it if you do.

### Buttons

| Key | What it is | Constraint |
|---|---|---|
| `btn_primary_top` | Top of the primary gradient | The signature stop, per the button rule |
| `btn_primary_bot` | Bottom of the primary gradient | The deep stop, per the button rule |
| `btn_primary_fg` | Primary label | 4.5:1 against the gradient's midpoint |
| `btn_secondary` | Secondary fill | Flat 0.10 tint of field polarity |
| `btn_secondary_fg` | Secondary label | Never pure white; 4.5:1 against `field` |
| `btn_edge` | Inset bottom edge on every button face | Black at 0.22–0.35 |

### Locked collection tiles

| Key | Type | Constraint |
|---|---|---|
| `silhouette_invert` | bool | **`true` for a light field, `false` for a dark one.** Get this wrong and locked cards become invisible |
| `silhouette_alpha` | float | Around 0.30–0.34 |

---

## 4. Fill-in template

Copy this per theme. Every key must be present; there is no inheritance and no
default. A missing key returns magenta at runtime.

```gdscript
	"<theme_id>": {
		# Chrome — the header and footer bars
		"chrome_grad_a":     Color("RRGGBB"),
		"chrome_grad_b":     Color("RRGGBB"),
		"chrome_grad_c":     Color("RRGGBB"),
		"chrome_fg":         Color("RRGGBB"),
		"chrome_pattern":    Color(1.0, 1.0, 1.0, 0.060),
		"chrome_line":       Color(0.0, 0.0, 0.0, 0.0),

		# Field — the play area / content background
		"field":             Color("RRGGBB"),
		"field_glow_top":    Color(r, g, b, 0.18),
		"field_glow_bottom": Color(r, g, b, 0.16),
		"field_glow_left":   Color("RRGGBB"),
		"field_glow_right":  Color("RRGGBB"),
		"field_texture":     Color(1.0, 1.0, 1.0, 0.026),
		"field_fg":          Color("RRGGBB"),
		"field_mute":        Color("RRGGBB"),

		# Surfaces and lines
		"panel":             Color(1.0, 1.0, 1.0, 0.065),
		"line":              Color(1.0, 1.0, 1.0, 0.14),
		"slot":              Color(1.0, 1.0, 1.0, 0.16),
		"slot_fill":         Color(1.0, 1.0, 1.0, 0.03),
		"chip_bg":           Color(r, g, b, 0.62),
		"chip_line":         Color(1.0, 1.0, 1.0, 0.18),
		"chip_fg":           Color("RRGGBB"),

		# Accents and semantics
		"accent":            Color("RRGGBB"),
		"accent_2":          Color("RRGGBB"),
		"good":              Color("RRGGBB"),
		"danger":            Color("RRGGBB"),
		"warn":              Color("RRGGBB"),

		# Status conditions
		"status_psn":        Color("C93A9B"),
		"status_cnf":        Color("E07A2E"),
		"status_par":        Color("D8A82A"),
		"status_asl":        Color("6E7BC4"),
		"status_brn":        Color("E2603A"),

		# Buttons
		"btn_primary_top":   Color("RRGGBB"),
		"btn_primary_bot":   Color("RRGGBB"),
		"btn_primary_fg":    Color("RRGGBB"),
		"btn_secondary":     Color(1.0, 1.0, 1.0, 0.10),
		"btn_secondary_fg":  Color("RRGGBB"),
		"btn_edge":          Color(0.0, 0.0, 0.0, 0.30),

		# Locked collection tiles
		"silhouette_invert": false,
		"silhouette_alpha":  0.34,
	},
```

Notes on the literals. `Color("RRGGBB")` is an opaque hex. `Color(r, g, b, a)`
takes floats in 0..1 and is the form to use whenever alpha is involved. The
white and black alpha tints above are already correct for a **dark** field; on a
light field flip every `1.0, 1.0, 1.0` to `0.0, 0.0, 0.0` and nudge the alpha up
slightly, because a dark tint on light reads weaker than the reverse.

---

## 5. Reference implementation

This is `spectrum_night`, the shipped theme, verbatim. Use it as the worked
example of every rule above. Note `btn_primary_top` equals `chrome_grad_b` and
`btn_primary_bot` equals `chrome_grad_a`, which is the button rule in action.

```gdscript
	"spectrum_night": {
		# Chrome — the header and footer bars
		"chrome_grad_a":     Color("7B3FD4"),   # 0%
		"chrome_grad_b":     Color("E8459B"),   # 52%
		"chrome_grad_c":     Color("F5793B"),   # 100%
		"chrome_fg":         Color("FFFFFF"),
		"chrome_pattern":    Color(1.0, 1.0, 1.0, 0.060),
		"chrome_line":       Color(0.0, 0.0, 0.0, 0.0),

		# Field — the play area / content background
		"field":             Color("171126"),
		"field_glow_top":    Color(0.910, 0.271, 0.608, 0.18),   # E8459B @18%
		"field_glow_bottom": Color(0.961, 0.475, 0.231, 0.16),   # F5793B @16%
		"field_glow_left":   Color("241740"),
		"field_glow_right":  Color("3A1533"),
		"field_texture":     Color(1.0, 1.0, 1.0, 0.026),
		"field_fg":          Color("F4EDFA"),
		"field_mute":        Color("C9BBE0"),

		# Surfaces and lines
		"panel":             Color(1.0, 1.0, 1.0, 0.065),
		"line":              Color(1.0, 1.0, 1.0, 0.14),
		"slot":              Color(1.0, 1.0, 1.0, 0.16),
		"slot_fill":         Color(1.0, 1.0, 1.0, 0.03),
		"chip_bg":           Color(0.078, 0.047, 0.133, 0.62),   # 140C22 @62%
		"chip_line":         Color(1.0, 1.0, 1.0, 0.18),
		"chip_fg":           Color("E7DCF5"),

		# Accents and semantics
		"accent":            Color("FF7FC4"),   # player side, payable, selection, active
		"accent_2":          Color("FFA45C"),   # opponent side, powers, damage blocks
		"good":              Color("67D79B"),   # remaining HP, prices, confirm
		"danger":            Color("E5484D"),   # destructive actions
		"warn":              Color("EFC44F"),   # toggle-on state

		# Status conditions
		"status_psn":        Color("C93A9B"),
		"status_cnf":        Color("E07A2E"),
		"status_par":        Color("D8A82A"),
		"status_asl":        Color("6E7BC4"),
		"status_brn":        Color("E2603A"),

		# Buttons
		"btn_primary_top":   Color("E8459B"),   # == chrome_grad_b
		"btn_primary_bot":   Color("7B3FD4"),   # == chrome_grad_a
		"btn_primary_fg":    Color("FFFFFF"),
		"btn_secondary":     Color(1.0, 1.0, 1.0, 0.10),
		"btn_secondary_fg":  Color("D9CBEC"),
		"btn_edge":          Color(0.0, 0.0, 0.0, 0.30),

		# Locked collection tiles
		"silhouette_invert": false,
		"silhouette_alpha":  0.34,
	},
```

Three further themes are already parked in the file and also conform:
`spectrum` (the light counterpart), `dusk` (muted, primary derived from accent
because its chrome is near black) and `circuit` (teal on near black, same
reason). Read them for how the rules bend on an unsaturated chrome bar.

---

## 6. Validation checklist

Run every theme through this before handing it back. State the result per theme.

1. **All 39 keys present**, in the order given in section 3.
2. **Contrast.** `chrome_fg` clears 4.5:1 against all three chrome stops.
   `field_fg` clears 4.5:1 and `field_mute` clears 3:1 against `field`.
   `chip_fg` clears 4.5:1 against `chip_bg` composited over `field`.
   `btn_primary_fg` clears 4.5:1 against the primary gradient's midpoint.
   `btn_secondary_fg` clears 4.5:1 against `btn_secondary` composited over `field`.
3. **The button rule holds.** Primary's two stops each appear elsewhere in the
   theme. Secondary is a 0.10 tint of field polarity with a non-white label.
4. **`silhouette_invert` matches the field's polarity.**
5. **`chrome_grad_b` works as a selection colour** — vivid, and able to carry
   white text at 17px. Flag it if it cannot.
6. **`accent` and `accent_2` differ in hue,** not just lightness.
7. **Alpha tints match the field's polarity** — white tints on dark, black on light.
8. **No energy colours, no type sizes, no metrics, no band geometry** in the block.

---

## 7. Resolved — what your 39 keys now reach

Earlier drafts of this spec listed three unresolved gaps. **All three are now
built, and none of them adds a key.** This section is here so you know what your
39 values are driving, and so you do not try to solve these yourself.

**The splash, the VS screen and the message box now follow the theme.** They used
to be fixed dictionaries painted in Spectrum Night's pink, purple and orange.
They are derived now, so your theme reaches them automatically:

| Was fixed | Now derives from |
|---|---|
| The boot splash mark's four stops | `chrome_grad_a` / `_b` / `_c` |
| The splash rule and wordmark | `accent`, `chrome_fg`, `field_fg` |
| The splash's two buttons | `btn_secondary` and the `btn_primary_*` gradient |
| The VS intro band and the word inside it | the chrome gradient, lightened for the word |
| Each trainer's side accent and floor glow | `accent` for the player, `accent_2` for the opponent |
| The message box background and border | `field`, deepened, and `line` |

**What stays fixed, on purpose.** Win is green and loss is red in every theme,
like the five status conditions and the eleven energy types: the player learns
the colour, and a theme that made a loss green would be misleading. The modal
scrim and the drop shadows stay black, because a shadow is an absence of light
rather than a colour. The shop's cash pill stays gold. Do not try to theme these.

**The selection colour needs no 39th token.** `chrome_grad_b` is both the
header's middle stop and the global "this is on" fill. A theme whose chrome bar
is near black or desaturated would produce an invisible selected state, so the
code now measures it: if `chrome_grad_b` is too dark to carry a label, the
selection falls back to `accent`. Label colour on every semantic fill is likewise
computed from the fill's own luminance rather than assumed to be white.

**So build to the 39 keys and nothing else.** If a theme of yours would look
wrong under any of the derivations above, say so in your hand-back rather than
inventing a key — the derivation is the thing that should change, and that is a
code fix on this side.

---

## 7a. Check your work with the audit tool

There is a validator in the repo that runs every check in section 6 against every
theme in the file. Once your themes are merged, it is run with:

```
"C:\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless \
    --path "C:\Pokemon TCG Legacy" --script Scripts/Utilities/Theme_Audit.gd
```

It reports per theme, and distinguishes **FAIL** (a broken theme: a missing key,
unreadable text, an inverted silhouette) from **WARN** (a judgement call you may
have made deliberately). Only FAIL sets the exit code.

The sixteen shipped themes pass with zero failures. Aim for the same.

Since the first round it also measures one pair the earlier spec did not: the
secondary button that sits on a chrome bar. That button is the only translucent
variant, so it has no colour of its own and takes a separate baked face keyed to
the BAR's contrast rather than the field's. You do not author it and it is not a
39th key — but it is why a theme pairing a pale field with a near-black bar is
safe now, where before it drew a black Cancel button on a black footer.
You cannot run this yourself, but knowing exactly what it measures is the point:
**the checklist in section 6 is not advisory, it is executable.**

---

## 8. What to hand back

For each theme:

1. A **theme id** in `snake_case`, and a short display name.
2. The **complete 39-key block**, in section 4's shape and section 3's order,
   ready to paste into `THEMES`.
3. **One line per key you deviated on**, saying why. Especially any status
   colour you changed.
4. The **section 6 checklist result**, including any contrast pair that failed
   and what you did about it.
5. A flag if **`chrome_grad_b` will not work as that theme's selection colour.**

Then, once across all themes:

6. Anything you could not express in 39 keys, if there is anything — see the note
   at the end of section 7.

Hand back the blocks as text. Do not edit `UI_Theme.gd` — the merge, the
`Build_UI_Themes.gd` rebuild and the audit run happen on this side.

**You do not need to supply a display name, a picker entry, or any wiring.** The
Options screen builds its theme row by walking the themes dictionary, so a theme
becomes a selectable button the moment it is added, and its id is title-cased for
the label if no nicer name is given. Give a display name only where title-casing
the id would read badly.
