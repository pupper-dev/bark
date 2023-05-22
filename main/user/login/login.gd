extends Control
@onready var homeserver = $Panel/VBoxContainer/homeserver
@onready var username = $Panel/VBoxContainer/username
@onready var password = $Panel/VBoxContainer/password
@onready var button = $Panel/VBoxContainer/Button

func _ready():
	button.pressed.connect(func():
		login()
			)

func login():
	var validated = true
	# validate input fields
	if homeserver.text == "":
		Notify.sendNotification("Please make sure to enter a valid homeserver")
		validated = false
	if username.text == "":
		Notify.sendNotification("Please make sure to enter a valid username")
		validated = false
	if password.text == "":
		Notify.sendNotification("Please make sure to enter the correct password")
		validated = false
	if validated:
		button.disabled = true
		homeserver.editable = false
		username.editable = false
		password.editable = false
		if await Vector.login_username_password(
			homeserver.text,
			username.text,
			password.text
		):
			get_tree().get_first_node_in_group("main").loggedIn()
	
