extends Node

var container = preload("res://main/notify/scenes/container/notifContainer.tscn")
var notif = preload("res://main/notify/scenes/notification/notification.tscn")

var pending = []

var thread = Thread.new()

func sendNotification(message:String):
	var tmpNotif = notif.instantiate()
	tmpNotif.text = message
	pending.push_back(tmpNotif)

func _process(delta):
	checkForContainer()
	if pending.size() > 0:
		var tmpNotif = pending[0]
		var tmpParent = get_tree().get_first_node_in_group("notifContainer")
		if tmpParent:
			tmpParent.call_deferred("add_child",tmpNotif)
			pending.pop_front()

func checkForContainer():
	var tmp = get_tree().get_first_node_in_group("notifContainer")
	if tmp:
		return true
	else:
		get_tree().root.call_deferred("add_child",container.instantiate())
		return true
