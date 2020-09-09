extends Node2D


var deathSound = load("res://Scenes/DeathNoise.tscn")
#var soundZoomScale = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#func scrolled (direction):
#	var sounds = get_tree().get_nodes_in_group("base")
#	for sound in sounds:
#		if sound.is_in_group("sound"):
#			sound.volume_db = sound.volume_db + (0.05 * direction)


func playDeath(atLocation):
	#print ("Death at ", atLocation)
	var soundInstance = deathSound.instance()
	get_tree().get_root().add_child(soundInstance)
	soundInstance.set_name("Death Noise")
	soundInstance.position = atLocation
	soundInstance.play()


func playSound(soundToPlay):
	if self.has_node(soundToPlay):
		self.get_node(soundToPlay).play()
