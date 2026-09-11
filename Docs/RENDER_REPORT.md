# How the theme actually renders — a report for the theme author

**Why you are reading this.** You wrote the sixteen theme blocks in
`NEWTHEMES.md`. They are merged and live, and every block passes the audit, but
the result on screen does not match what the mocks intended. This document is the
other half of the conversation: **exactly how the engine turns your 38 keys into
pixels**, plus screenshots of the real thing.

Read it, compare against your mock, and hand back a list of concrete changes.
Changes can be to the theme values, to the derivations below, or to the
composition — say which. Nothing here is sacred except the geometry, which is
shared by all sixteen themes and is not a theme's to change.

Screenshots are in `Docs/render_report/`, rendered from the real scenes at
1920x1080:

| File | Screen | Theme |
|---|---|---|
| `01_options_sunset_dark.png` | Options | Sunset Dark |
| `02_options_umbreon_light.png` | Options | Umbreon Light |
| `03_options_bars_hidden.png` | Options, Hide header/footer ON | Sunset Dark |
| `04_deck_builder_code_dark.png` | Deck builder | Code Dark |
| `05_trainer_card_sunset_dark.png` | Trainer card | Sunset Dark |
| `06_main_menu_UNTHEMED.png` | Main menu | **none — see section 6** |
| `07_coin_case_sunset_dark.png` | Coin case | Sunset Dark |

---

## 1. The layer stack

Every themed screen is exactly four layers, bottom to top. There is no fifth.

```
z = -100   ui_field     full-rect shader. base + 2 washes + 2 tints + light bands
z =    0   content      panels, chips, slots, cards, labels, buttons
z =  200   ui_header    full-width shader bar, 92px tall, pinned to the top
z =  200   ui_footer    full-width shader bar, 92px tall, pinned to the bottom
                        (162px on the match board only, to hold the hand)
```

Content lives in the 896px band between the bars. There is no drop shadow under
a bar, no hairline, no separator: the bar meets the field directly.

---

## 2. The field — how your five field keys compose

One shader pass, composited in this order. Order matters; reordering muddies it.

```
col  = field
col  = mix(col, field_glow_left,   radial(uv, (0.20,0.30), (0.95,0.80)) * a)
col  = mix(col, field_glow_right,  radial(uv, (0.88,0.80), (0.95,0.80)) * a)
col  = mix(col, field_glow_top,    radial(uv, (0.50,-0.10), (1.05,0.80)) * a)
col  = mix(col, field_glow_bottom, radial(uv, (0.50, 1.12), (1.05,0.80)) * a)
col  = mix(col, field_texture.rgb, band_ink * field_texture.a)
```

`radial` is `1 - smoothstep(0, 1, length((uv - centre) / radius))` — an ellipse
in UV space, so the washes **stretch with the screen** rather than staying
circular.

Two things worth knowing, because they are the most common surprise:

- **The two washes are treated as OPAQUE** and mixed by their falloff alone.
  Their alpha multiplies the falloff, so an alpha below 1.0 makes them weaker
  everywhere, not translucent in a useful sense. They recolour large areas.
- **The top and bottom tints sit mostly OFF-SCREEN** — centres at y = -0.10 and
  y = 1.12. Only the falloff is visible, as a warming along the top and bottom
  edges. If your mock had a visible glow *blob*, that is not what this draws.

The left wash is centred at 20% across and 30% down; the right at 88% across and
80% down. That diagonal is why the field reads darker top-right and bottom-left.

---

## 3. The chrome bars — how your three stops compose

```
t    = uv.x
grad = t < 0.52 ? mix(grad_a, grad_b, t / 0.52)
                : mix(grad_b, grad_c, (t - 0.52) / 0.48)
col  = mix(grad, chrome_pattern.rgb, band_ink * chrome_pattern.a)
```

**A horizontal three-stop gradient, left to right, with B at 52%.** That is the
only shape available. Your notes already flagged this: Sharpedo's vertical split,
and Umbreon's and Code's flat-with-a-keyline, cannot be expressed. They are
currently rendering as horizontal dark gradients.

There is **no `chrome_line` key**, so Umbreon's brass rule and Sharpedo's copper
rule are absent. Both would be code changes, not theme values.

Header and footer use the **same** shader and the **same** stops, so the footer
is not a mirror or a darker variant. It is the identical bar.

---

## 4. The light bands — shared, not yours to set

You supply only the two colours, `chrome_pattern` and `field_texture`. Everything
else is global and identical in all sixteen themes:

| | Bars | Field |
|---|---|---|
| Band width, shoulder to shoulder | 85px | 230px |
| Spacing, band start to band start | 190px | 520px |
| Angle | 122° | 122° |
| A band passes a point every | 7s | 18s |
| Direction | rightward | leftward |

The profile is `pow(sin(x * PI), 0.45)` across the band — **a flat-topped bar
with feathered shoulders, no hard edge anywhere**. The exponent below 1.0 is what
keeps the middle at near-full strength. Roughly ten bands cross a bar and four
cross the screen.

If the mock showed thin, closely spaced, hard-edged diagonal stripes, that is the
ORIGINAL design and it was deliberately replaced — it read as a barcode. Say so
if you want any of it back.

---

## 5. Buttons — baked art, and two derived things you did not author

Button faces are **baked PNGs**, one folder per theme, regenerated from your
tokens. A face is a rounded rect, 22px radius, with a vertical gradient from
`top` to `bot` and a 5px inset bottom edge in `btn_edge`. Padding is 29px
horizontal, 13px vertical. Hover composites white at 10% over the fill; press
composites black at 18%. Nothing about the geometry changes between states.

Seven variants are baked per theme:

| Variant | Fill | Label |
|---|---|---|
| `primary` | `btn_primary_top` → `btn_primary_bot`, a real gradient | `btn_primary_fg` |
| `secondary` | `btn_secondary`, flat | `btn_secondary_fg` |
| `selected` | **derived** — see below | **derived** |
| `good` / `danger` / `warn` | that token, flat | **derived** |
| `secondary_chrome` | **derived** — see below | `chrome_fg` |
| `disabled` | black at 22%, shared, no bottom edge | the variant's label at 40% |

Three derivations decide colours you did not write. **If the mock disagrees with
any of these, this is the most likely cause.**

**`selected`** is `chrome_grad_b`, unless its luminance is below 0.22, in which
case it falls back to `accent`. Ten of your sixteen themes take the fallback, so
in those the selected state is the accent, not the bar colour. This is also what
`UIKit.selection_colour()` returns, so every hand-painted "this is on" state in
the game follows it.

**Label colour on every semantic fill** is computed, not authored: white if the
fill's luminance is under 0.5, otherwise the fill's own hue at value 0.13. So
your `good`, `danger`, `warn` and the selected fill get a label chosen by the
engine.

**`secondary_chrome`** is a variant you did not author at all. The secondary
button is the only translucent one, so it has no colour of its own — it is
whatever it sits on. Your `btn_secondary` is keyed to the FIELD, which is right
in the content area and wrong in the header and footer, where buttons sit on the
BAR. Five of your light themes pair a pale field with a near-black bar, which
drew a black Cancel button on a black footer. So bar buttons take a separate
face: an 18% white lift on the bar if the label still clears 4.5:1 there,
otherwise a 30% black shade. Labelled in `chrome_fg`.

---

## 6. The main menu is not themed at all

`06_main_menu_UNTHEMED.png`. This screen never went through the UI overhaul. It
is still the pre-theme design: a pure black background, six rainbow gradient
tiles in fixed colours, and the old Kenney font with a black outline and drop
shadow. It has no field, no chrome bars, and reads none of your 38 keys.

**Nothing you write in a theme block will change it.** Converting it is a real
piece of work, not a theme value. Flag whether the mock covered this screen and
what it should look like.

---

## 7. Other things a theme cannot currently reach

Deliberate, and listed so you do not spend effort on them:

- **Energy type colours.** Eleven fixed hues. Hue carries data here.
- **Win green and loss red** on the VS and outro screens, and the five status
  condition colours. Semantic; the player learns them.
- **Modal scrims and drop shadows.** Black in every theme — a shadow is an
  absence of light, not a colour.
- **The shop cash pill.** Gold in every theme.
- **Card art and the message box paper.** The box is coloured per speaker, from
  the NPC's own `message_colour`, not from the theme.
- **Geometry and type.** Bar heights, radii, paddings, and the whole type scale
  are shared. A theme that changed them would change the shape of the game.

The type scale, for reference, since the mocks may assume different sizes:

| Role | Size | Face | Tracking | Case |
|---|---|---|---|---|
| title | 29 | Chakra Petch Bold | 0.11em | UPPER |
| subtitle | 18 | Chakra Petch SemiBold | 0.09em | UPPER |
| name | 19 | Chakra Petch Bold | 0.09em | UPPER |
| button | 17 | Chakra Petch Bold | 0.12em | UPPER |
| chip | 17 | Chakra Petch SemiBold | 0.07em | as written |
| small_label | 14 | IBM Plex Mono Medium | 0.19em | UPPER |
| body | 22 | Chakra Petch Medium | 0 | as written |

---

## 8. Hide header/footer

`03_options_bars_hidden.png`. A new Options toggle. It hides the bars' **paint
only**: the gradient and its bands stop drawing, the bars keep their 92px, and
every title, chip and button inside keeps drawing in the same place, at the same
size, in the same colour. Nothing moves and nothing reflows.

One consequence: `chrome_fg` is white in all sixteen themes, and with the bars
hidden that white text floats over the FIELD. On the eight light themes that is
white on a pale ground. This was specified as "change nothing else", so nothing
compensates. **If you want bar contents to switch to `field_fg` when the banners
are off, say so** — it is a small change and it would make the feature usable on
the light themes.

---

## 9. What to hand back

Per screen or per theme, whichever fits:

1. **What differs from the mock**, concretely — "the field's warm glow should be
   a visible blob at 30% up the right edge, not an edge wash", not "it looks
   flat".
2. **Which layer owns it**, using the section numbers above. Field composition,
   chrome gradient, band geometry, a button derivation, or a theme value.
3. **If it is a theme value**, the new value. If it is a derivation or a
   composition change, say what the rule should be instead — those are code
   changes on this side and I need the rule, not just the desired output.
4. **Anything that needs a key that does not exist** (`chrome_line`,
   `chrome_angle`, hard-stop positions). Name it and say which themes use it, so
   it can be judged against the cost of a 39th key.

Priority order, if it matters: the main menu is entirely unthemed, and that is
the largest visible gap.
