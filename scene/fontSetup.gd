extends Node
# 启动时强制设中文字体
# HTML5 导出时 [gui] theme/custom_font 可能不生效，这里做双重保障

func _ready():
	var font = load("res://resource/font/simhei.ttf")
	if font:
		ThemeDB.get_default_theme().default_font = font
		ThemeDB.get_default_theme().default_font_size = 20
		print("[FontSetup] font loaded and applied: simhei.ttf")
	else:
		printerr("[FontSetup] FAILED to load res://resource/font/simhei.ttf")
		# 尝试用 UID 加载
		font = load("uid://c7yvs0x6tnq3v")
		if font:
			ThemeDB.get_default_theme().default_font = font
			ThemeDB.get_default_theme().default_font_size = 20
			print("[FontSetup] fallback: loaded via UID")
		else:
			printerr("[FontSetup] CRITICAL: all font loading attempts failed")
