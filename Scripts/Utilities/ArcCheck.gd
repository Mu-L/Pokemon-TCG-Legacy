extends SceneTree
const EXPECT := {
	"sunset":   ["7B3FD4","C241DC","E443BB","E8437F","E83F44","E8703B"],
	"tide":     ["3535C4","2A5EBD","2089B5","20ACA0","27A366","2E9A3A"],
	"canopy":   ["1B8079","228553","2A8A2F","53952A","90A820","BC9016"],
	"gengar":   ["2A1747","3E2166","532A86","6A34A2","833EBA","9A55C4"],
	"shuppet":  ["0F131A","19212C","242F3F","2F4460","366196","3C7FCE"],
	"code":     ["04100F","082422","0A3836","0B5956","088A83","00BFB4"],
	"umbreon":  ["141309","27220E","3B3011","604B1A","93742A","C49C3C"],
	"sharpedo": ["C79A2E","152844","1F3C61","2C527E","3B679A","4C7CB4"],
}
func _init() -> void:
	var ui = load("res://Scripts/Global_Scripts/UI_Theme.gd").new()
	var worst := 0
	for look in EXPECT.keys():
		ui.current = look + "_dark"
		var got: Array = ui.menu_tile_colours()
		var row := ""
		for i in 6:
			var g: Color = got[i]
			var e := Color(EXPECT[look][i])
			var d: int = int(round(maxf(absf(g.r-e.r), maxf(absf(g.g-e.g), absf(g.b-e.b))) * 255.0))
			worst = maxi(worst, d)
			row += "%s vs %s (d%d)  " % [g.to_html(false), EXPECT[look][i], d]
		print(look, ": ", row)
	print("worst channel delta: ", worst, "/255")
	quit(0)
