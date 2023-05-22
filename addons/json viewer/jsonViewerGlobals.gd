extends Node

var jsonViewer = preload("res://addons/json viewer/json viewer.tscn")

func create_json_viewer_window(json):
	assert(
		typeof(json) == TYPE_DICTIONARY or
		typeof(json) == TYPE_STRING
		, "input json type is invalid, please only pass a string or dictionary")
	if typeof(json) == TYPE_STRING:
		json = JSON.parse_string(json)
	
	var tmpsonviewer = jsonViewer.instantiate()
	tmpsonviewer.json = json
	get_tree().root.call_deferred("add_child",tmpsonviewer)
