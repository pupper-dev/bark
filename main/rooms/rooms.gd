extends Control

var card = preload("res://main/card.tscn")
@onready var item_list = $ItemList


func add_items(items):
	if items is Array:
		for i in items:
			var state = await Vector.rooms_api.get_room_state(i)
			var name
			for event in state:
				if event['type'] == "m.room.name":
					name = event['content']['name']
			print('\n\n')
			if name:
				var tmp = item_list.add_item(name)
				item_list.set_item_metadata(tmp,{
					'state': state,
					'room_id': i
				})
			else:
				var tmp = item_list.add_item(i.split(':')[0].right(-1))
				item_list.set_item_metadata(tmp,{
					'state': state,
					'room_id': i
				})
			await get_tree().process_frame
