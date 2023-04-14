extends Control
@onready var login = $login
var friends_scene = preload("res://main/rooms/rooms.tscn")
var messages = preload("res://main/messages/messages.tscn")
@onready var h_box_container = $HBoxContainer
var friends_list
func _ready():
	get_window().min_size = Vector2(400,400)
#	if await Vector.readUserDict():
#		loggedIn()

func loggedIn():
	Notify.sendNotification("Already logged in, connecting.")
	login.button.disabled = true
	login.homeserver.editable = false
	login.username.editable = false
	login.password.editable = false
	login.hide()
	friends_list = friends_scene.instantiate()
	h_box_container.add_child(friends_list)
	await Vector.get_joined_rooms()
	friends_list.add_items(Vector.joinedRooms['joined_rooms'])
	h_box_container.add_child(messages.instantiate())
