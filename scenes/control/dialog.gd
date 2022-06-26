extends Control

func _ready():
	$dialogBox/RichTextLabel.bbcode_enabled = true

func setText(text):
	$dialogBox/RichTextLabel.set_bbcode(text)
