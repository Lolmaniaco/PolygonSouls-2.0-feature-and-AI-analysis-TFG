extends Control

@onready var label: RichTextLabel = $RichTextLabel


func _ready():
	label.bbcode_enabled = true


func setText(new_text: String):
	label.text = new_text
