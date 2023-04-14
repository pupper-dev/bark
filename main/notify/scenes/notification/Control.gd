extends Control

var text : String
@onready var label = $Panel/Label

func _ready():
	label.text = text
