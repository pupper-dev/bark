extends ItemList

@onready var rooms = $".."

func _ready():
	item_clicked.connect(rooms.room_clicked)
