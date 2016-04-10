extends Panel

var selected_index = 0

func _ready():
	get_node("Back").connect("pressed", self, "do_back")
	get_node("Play").connect("pressed", self, "do_play")
	get_node("ItemList").connect("item_selected", self, "update_selected_index")

func populate_level_list(levels):
	var list = get_node("ItemList")
	for l in levels:
		list.add_item(l, null, true)

func update_selected_index(index):
	selected_index = index

func do_play():
	var list = get_node("ItemList")
	if (list.is_selected(selected_index)):
		get_parent().get_parent().load_level(selected_index)
	else:
		print("selected index ", selected_index, " not in list ", list.get_item_count())

func do_back():
	self.hide()