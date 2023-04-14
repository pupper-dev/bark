extends Panel
@onready var label = $Label
@onready var control = $".."

var targetpos : Vector2

func _process(delta):
	custom_minimum_size = Vector2(label.size.x*1.1,label.size.y*1.5)
	control.custom_minimum_size = custom_minimum_size
	if targetpos != null:
		position.x = lerpf(position.x,targetpos.x,.1)
		position.y = lerpf(position.y,targetpos.y,.1)

func _ready():
	var t = get_tree().create_timer(4)
	t.timeout.connect(func():
		control.queue_free()
		)
	targetpos = position
	position = Vector2(-(size.x+10),position.y)
