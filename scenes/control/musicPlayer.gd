extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var exploringMusic = load("res://music/AAOCG - mIRC 6 x - KeyGen Sound - by Done.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	playMusic()
	
func playMusic():
	$music.stream = exploringMusic
	
#	$music.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
