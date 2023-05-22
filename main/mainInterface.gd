extends HSplitContainer

@onready var rooms = $rooms
@onready var room_container = $roomContainer

func _ready():
	Vector.got_joined_rooms.connect(func():
		# print(Vector.joinedRooms)
		rooms.add_items(Vector.joinedRooms)
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
