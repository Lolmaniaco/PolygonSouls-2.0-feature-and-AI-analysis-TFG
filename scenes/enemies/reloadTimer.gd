extends Timer

var fireRate = 1
# Called when the node enters the scene tree for the first time.
func _ready():
		pass # Replace with function body.

func weakenedEnemy():
	fireRate = 2
	
func _process(_delta):
	randomize()
	wait_time = fireRate * randf_range(0.6, 1.1)
	
