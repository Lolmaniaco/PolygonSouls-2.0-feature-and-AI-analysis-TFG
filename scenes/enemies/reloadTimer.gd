extends Timer

var fireRate = 1
# Called when the node enters the scene tree for the first time.
func _ready():
		pass # Replace with function body.

func weakenedEnemy():
	fireRate = 2
	
func _process(delta):
	randomize()
	wait_time = fireRate * rand_range(0.6, 1.1)
	
