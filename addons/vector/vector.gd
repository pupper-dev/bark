@icon("res://addons/vector/vector.gd")
## Matrix api handler (must be added as an autoload script named "Vector")

class_name vector
extends Node

# import scripts
var user_script = preload("res://addons/vector/api_handlers/user.gd")
var rooms_script = preload("res://addons/vector/api_handlers/rooms.gd")

# create vars for script objects
var user_api = user_script.new()
var rooms_api = rooms_script.new()

# other vars
var client = HTTPClient.new()
var userToken = ""
var base_url = ""
var home_server = ""
var headers = ["content-type: application/json"]
var syncSince = ""
var timeout = 3000
var joinedRooms
var userData : Dictionary = {}

# matrix enums
const PRESENCE = {"offline":"offline","online":"online","unavailable":"unavailable"}

func connect_to_homeserver(homeServer:String = ""):
	var homeserverurl = "https://{0}".format([
		userData["home_server"] if homeServer == "" and userData.has("home_server") else homeServer
		])
	var response = client.connect_to_host(
		homeserverurl,
		443)
	assert(response == OK)
	while client.get_status() == client.STATUS_CONNECTING or client.get_status() == client.STATUS_RESOLVING:
		client.poll()
		await get_tree().process_frame
	return response

func login_username_password(homeserver:String,username:String,password:String):
	await user_api.login_username_password(homeserver,username,password)
	if userToken != "":
		headers.push_back("Authorization: Bearer {0}".format([userToken]))
		Notify.sendNotification("connecting to base_url")
		while client.get_status() == client.STATUS_CONNECTING or client.get_status() == client.STATUS_RESOLVING:
			Notify.sendNotification('waiting')
			client.poll()
		return true
	else:
		return false

func get_joined_rooms():
	joinedRooms = await user_api.get_joined_rooms()

func readRequestBytes():
	while client.get_status() == client.STATUS_REQUESTING:
		client.poll()
		await get_tree().process_frame
	var readbytes = PackedByteArray()
	while client.get_status() == client.STATUS_BODY:
		client.poll()
		var chunk = client.read_response_body_chunk()
		if chunk.size() == 0:
			pass
		else:
			readbytes = readbytes+chunk
		await get_tree().process_frame
	var msg = readbytes.get_string_from_ascii()
	return msg

func saveUserDict():
	var file = FileAccess.open("user://user.data",FileAccess.WRITE)
	userData["home_server"] = home_server
#	assert(userData.has('home_server'))
#	assert(userData.has('login'), "userData dictionary doesn't have the login data")
	var toStore = var_to_bytes(userData)
	toStore.reverse()
	file.store_var(toStore)

func readUserDict():
	var file = FileAccess.open("user://user.data",FileAccess.READ)
	if file.file_exists("user://user.data"):
		var read = file.get_var()
		read.reverse()
		userData = bytes_to_var(read)
		# user_id, access_token, home_server, device_id, well_known{m.homeserver{base_url}}
		if userData['login'].has("access_token"):
			userToken = userData['login']["access_token"]
			headers.push_back("Authorization: Bearer {0}".format([userToken]))
			home_server = userData['login']['user_id'].split(':')[1]
			base_url = userData['login']['well_known']['m.homeserver']['base_url']
			var res = await connect_to_homeserver(home_server)
			assert(res == OK)
			assert(client.get_status() == HTTPClient.STATUS_CONNECTED)
			return true
	return false

func refresh_token(token:String):
	var res
	if client.get_status() == HTTPClient.STATUS_CONNECTED:
		res = client.request(HTTPClient.METHOD_POST, "/_matrix/client/v3/refresh",headers,str({
			"refresh_token": token
		}))
		var msg = await readRequestBytes()
		var refreshedToken = JSON.parse_string(msg)
	else:
		printerr("Vector client not initialized yet")
