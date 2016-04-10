extends Panel

func _ready():
	get_node("Back").connect("pressed", self, "do_back")
	var file = File.new()
	file.open("res://credits.txt", File.READ)
	while(!file.eof_reached()):
		get_node("RichTextLabel").add_text(file.get_line())
		get_node("RichTextLabel").newline()

func do_back():
	self.hide()