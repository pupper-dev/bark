extends Node

func login_username_password(homeserver:String,username:String,password:String):
	var loginDict = {
		"type": "m.login.password",
		"password": password,
		"user": username,
		"device_id": OS.get_unique_id(),
		"initial_device_display_name": "bark"
		}
	var response = await Vector.connect_to_homeserver(homeserver)
	assert(response == OK)
	response = Vector.client.request(Vector.client.METHOD_POST,"/_matrix/client/v3/login",Vector.headers,str(loginDict))
	assert(response == OK)
	var msg = await Vector.readRequestBytes()
	var msgJson = JSON.parse_string(msg)
	print(msgJson)
	Vector.userToken = msgJson.access_token
	Vector.base_url = msgJson.well_known["m.homeserver"].base_url
	Vector.userData['login'] = msgJson
	Vector.userData['login']['home_server'] = homeserver
	Vector.saveUserDict()

func get_joined_rooms():
	var res
	if Vector.userData['login'].has("access_token"):
		if Vector.client.get_status() == HTTPClient.STATUS_CONNECTED:
			res = Vector.client.request(HTTPClient.METHOD_GET, "/_matrix/client/v3/joined_rooms",Vector.headers)
			var msg = await Vector.readRequestBytes()
			return JSON.parse_string(msg)
		else:
			printerr("Vector http client isn't connected yet, try logging in the user first.\nstat: ",Vector.client.get_status())
	else:
		printerr("User token not assigned yet, try logging the user in first.")

func sync(filter:String,full_state:bool,set_presence:String,since:String,timeout:int):
	pass
