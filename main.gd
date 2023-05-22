extends Control
@onready var login = $login
@onready var json_viewer = $"Window/json viewer"
var main_interface = preload("res://main/mainInterface.tscn")
var friends_list

func _ready():
	get_window().min_size = Vector2(400,400)
	Vector.user_logged_in.connect(loggedIn)
	Vector.synced.connect(func(data):
		JsonViewerGlobals.create_json_viewer_window(data)
#		Vector.sync()
		)
	if await Vector.readUserDict():
		loggedIn()


func loggedIn():
	login.button.disabled = true
	login.homeserver.editable = false
	login.username.editable = false
	login.password.editable = false
	login.hide()
#	Vector.get_joined_rooms()
	Vector.sync()
	add_child(main_interface.instantiate())
