extends Control

@onready var tree : Tree = $Tree
@onready var root = tree.create_item()
@onready var window = $".."

var thread = Thread.new()
var length = 0
var string = ''

func _ready():
	tree.item_selected.connect(func():
#		tree.get_selected().collapsed = !tree.get_selected().collapsed
		)
	setJson(window.json)

func _process(delta):
	if thread.is_started():
		if !thread.is_alive():
			thread.wait_to_finish()


func setJson(json):
	tree.clear()
	length = 0
	root = tree.create_item()
	if typeof(json) == TYPE_STRING:
		json = JSON.parse_string(json)
#	thread.start(add_dictionary.bind(json,root))
	add_dictionary(json,root)

func simple_add_dictionary(data:Dictionary,parent):
	var keys = data.keys()
	var values = data.values()
	
	for i in range(keys.size()):
		await get_tree().process_frame
		var tmp = tree.create_item(parent)
		tmp.set_text(0,keys[i])
		tree.create_item()

func add_dictionary(data:Dictionary,parent):
	var keys = data.keys()
	var values = data.values()
	
	for i in range(keys.size()):
#		await get_tree().process_frame
		var tmp = tree.create_item(parent)
		length+=1
		root.set_text(0,str(length))
		tmp.collapsed = true
		tmp.set_text(0,keys[i])
		if typeof(values[i]) == TYPE_DICTIONARY:
			add_dictionary(values[i],tmp)
		elif typeof(values[i]) == TYPE_STRING:
			var tmpson = JSON.new()
			if tmpson.parse(values[i]) == OK and typeof(tmpson.data) == TYPE_DICTIONARY:
				add_dictionary(tmpson.data,tmp)
			else:
				var tmpval = tree.create_item(tmp)
				length+=1
				root.set_text(0,str(length))
				tmpval.collapsed = true
				tmpval.set_text(0,values[i])
		elif typeof(values[i]) == TYPE_ARRAY:
			add_array(values[i], tmp)
		else:
			var tmpval = tree.create_item(tmp)
			length+=1
			root.set_text(0,str(length))
			tmpval.collapsed = true
			tmpval.set_text(0,str(values[i]))

func add_array(data,parent):
	for v in data:
#		await get_tree().process_frame
		var tmpdebug = str(v)
		var tmpson = JSON.new()
		if typeof(v) == TYPE_DICTIONARY:
			var vp = tree.create_item(parent)
			length+=1
			root.set_text(0,str(length))
			vp.collapsed = true
			vp.set_text(0,'0')
			add_dictionary(v,vp)
		elif typeof(v) == TYPE_STRING:
			if tmpson.parse(v) == OK and typeof(tmpson.data) == TYPE_DICTIONARY:
				var vp = tree.create_item(parent)
				length+=1
				root.set_text(0,str(length))
				vp.collapsed = true
				vp.set_text(0,'0')
				add_dictionary(tmpson.data,vp)
			else:
				var tmp = tree.create_item(parent)
				length+=1
				root.set_text(0,str(length))
				tmp.collapsed = true
				tmp.set_text(0,str(v))
		elif typeof(v) == TYPE_ARRAY:
			var vp = tree.create_item(parent)
			length+=1
			root.set_text(0,str(length))
			vp.collapsed = true
			vp.set_text(0,'0')
			add_array(v,vp)
		else:
			var tmp = tree.create_item(parent)
			length+=1
			root.set_text(0,str(length))
			tmp.collapsed = true
			tmp.set_text(0,str(v))




