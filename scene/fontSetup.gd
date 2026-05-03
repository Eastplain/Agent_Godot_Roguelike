extends Node
# 启动时强制设中文字体

func _ready():
	var font = load("res://resource/font/simhei.ttf")
	if font:
		ThemeDB.get_default_theme().default_font = font
		ThemeDB.get_default_theme().default_font_size = 16
