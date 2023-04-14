extends ItemList


func _ready():
	item_clicked.connect(func(item, pos, button):
		var members = []
		for i in get_item_metadata(item)['state']:
			if i['type'] == 'm.room.member':
				if i['content'].has('displayname'):
					Notify.sendNotification("user: "+str(i['content']['displayname']))
			print('\n\n',i,'\n\n')
			await get_tree().process_frame
		)
