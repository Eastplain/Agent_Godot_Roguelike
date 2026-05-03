extends Node
# 启动时设置中文字体为全局默认

func _ready():
	var font = load("res://resource/font/simhei.ttf")
	if font:
		var theme = Theme.new()
		theme.default_font = font
		theme.default_font_size = 16
		get_tree().root.theme = theme
