extends Control

@onready var item_list = $ItemList

func _ready():
	if Vector.joinedRooms:
		add_items(Vector.joinedRooms)
	Vector.got_room_state.connect(func(state):
		if state != null:
			var name
			var avatar
			var roomId
			for event in state:
				roomId = event['room_id']
				if event['type'] == "m.room.name":
					name = event['content']['name']
				if event['type'] == 'm.room.avatar':
					var tmp = HTTPRequest.new()
					get_tree().get_first_node_in_group("requestParent").add_child(tmp)
					var avatarUrl = event['content']['url']
					var avatarServer = avatarUrl.split('/')[2]
					var mediaId = avatarUrl.split('/')[3]
					tmp.download_file = "res://cache/avatars/"+roomId
					tmp.request(
						"{0}_matrix/media/v3/download/{1}/{2}".format([Vector.base_url,avatarServer,mediaId]),
						Vector.headers,
						HTTPClient.METHOD_GET
						)
					await tmp.request_completed
					print(FileAccess.file_exists("res://cache/avatars/"+roomId))
				await get_tree().process_frame
			var tmp
			if name:
				tmp = item_list.add_item(name)
				item_list.set_item_metadata(tmp,{
					'state': state,
					'room_id': roomId
				})
			else:
				tmp = item_list.add_item(roomId.split(':')[0].right(-1))
				item_list.set_item_metadata(tmp,{
					'state': state,
					'room_id': roomId
				})
			
		)

func add_items(items):
	if items is Array:
		for i in items:
			var state = Vector.api.get_room_state(i)

func room_clicked(item,pos,button):
	var roomdata : Dictionary = item_list.get_item_metadata(item)
	if button == 1:
		JsonViewerGlobals.create_json_viewer_window(roomdata)
